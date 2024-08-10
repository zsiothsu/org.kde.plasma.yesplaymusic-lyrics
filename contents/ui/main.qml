import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

import "lyrics.js" as Json_lyrics

PlasmoidItem {
    id: root

    readonly property int config_flush_time: Plasmoid.configuration.flush_time
    readonly property int config_time_offset: Plasmoid.configuration.time_offset
    readonly property string config_text_color: Plasmoid.configuration.text_color
    readonly property string config_text_font: Plasmoid.configuration.text_font
    readonly property string cfg_first_language: Plasmoid.configuration.first_language
    readonly property string cfg_second_language: Plasmoid.configuration.second_language
    readonly property string cfg_second_language_wrapping: Plasmoid.configuration.second_language_wrapping
    readonly property string cfg_text_align: Plasmoid.configuration.text_align

    compactRepresentation: fullRepresentation
    preferredRepresentation: Plasmoid.fullRepresentation
    fullRepresentation: Item {
        Layout.preferredWidth: lyric_line.implicitWidth > lyric_second_line.implicitWidth ? lyric_line.implicitWidth : lyric_second_line.implicitWidth
        Layout.preferredHeight: lyric_line.implicitHeight > lyric_second_line.implicitHeight ? lyric_line.implicitHeight : lyric_second_line.implicitHeight
        ColumnLayout {
            id: contentLayout
            anchors.fill: parent
            spacing: 5
            Label {
                Layout.fillWidth: true
                id: lyric_line;
                text: root.lyric_line_text
                color: config_text_color
                horizontalAlignment: cfg_text_align === "Left" ? Text.AlignLeft :
                        cfg_text_align === "Right" ? Text.AlignRight :
                        Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font: config_text_font || theme.defaultFont
            }
            Label {
                Layout.fillWidth: true
                id: lyric_second_line
                visible: plasmoid.configuration.second_language_wrapping !== "disable"
                opacity: visible ? 1 : 0
                text: root.lyric_second_line_text
                color: config_text_color
                horizontalAlignment: cfg_text_align === "Center" ? Text.AlignHCenter :
                        cfg_text_align === "Right" ? Text.AlignRight :
                        Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                font: config_text_font || theme.defaultFont
                //切换双语过渡动画效果
                Behavior on opacity {
                    NumberAnimation {
                        duration: 250
                    }
                }
            }
        }

        Timer {
            interval: config_flush_time; running: true; repeat: true
            onTriggered: get_lyric();
        }

        property string lyric_original_cache: ''
        property string lyric_translated_cache: ''
        property string lyric_romaji_cache: ''
        property real id_original_cache: 0
        property real id_translated_cache: 0
        property real id_romaji_cache: 0
        property bool valid_original_cache: false
        property bool valid_translated_cache: false
        property bool valid_romaji_cache: false
        property bool no_translated_cache: false
        property bool no_romaji_cache: false

        property int timeout_count: 0

        function get_lyric() {
            var xhr = new XMLHttpRequest();
            xhr.open('GET', 'http://127.0.0.1:27232/player', false);
            xhr.send(null);
            if (200 == xhr.status) {
                var tracker = get_id_progress(xhr.responseText);

                if (tracker.id == -1) return

                timeout_count = 0
                select_lyric(tracker);
            } else {
                if (timeout_count < 5) {
                    timeout_count++
                }
                if (timeout_count >= 5) {
                    lyric_line.text = ""
                    lyric_second_line.text = ""
                    id_original_cache = 0
                    id_translated_cache = 0
                    id_romaji_cache = 0
                }
            }
        }

        function get_lyric_by_time(lyrics, time) {
            var lyric_obj = new Lyrics(lyrics)
            var last_time = 0
            var last_text = ""
            var flag = false
            var real_time = time + config_time_offset / 1000
            var target_line = ""
            if (real_time < 0 || real_time < lyric_obj.lyrics_all[0].timestamp) {
                real_time = lyric_obj.lyrics_all[0].timestamp
            }
            for (var i = 0; i < lyric_obj.length; i++) {
                if ((last_time <= real_time) && (real_time < lyric_obj.lyrics_all[i].timestamp)) {
                    target_line = last_text
                    flag = true
                }
                last_time = lyric_obj.lyrics_all[i].timestamp
                last_text = lyric_obj.lyrics_all[i].text
                if (flag) {
                    break
                }
            }
            if (!flag) {
                return last_text
            } else {
                return target_line
            }
        }

        function select_lyric(tracker) {
            /*
             *  the response of api http://127.0.0.1:10754/lyric?id=
             * {
             *      "sgc": false,
             *      "sfy": false,
             *      "qfy": false,
             *      "transUser": {
             *          "id": 2090794,
             *          "status": 99,
             *          "demand": 1,
             *          "userid": 59957287,
             *          "nickname": "虎纹鲨鱼子",
             *          "uptime": 1493869287084
             *      },
             *      "lyricUser": {
             *          "id": 2090785,
             *          "status": 99,
             *          "demand": 0,
             *          "userid": 59957287,
             *          "nickname": "虎纹鲨鱼子",
             *          "uptime": 1493869287084
             *      },
             *      "lrc": {
             *          "version": 16,
             *          "lyric": "[00:19.83]流れる星(ひかり)を\n[00:18.62]\n[00:26.19]ただ 重ねる指を\n"
             *      },
             *      "klyric": {
             *          "version": 0,
             *          "lyric": ""
             *      },
             *      "tlyric": {
             *          "version": 7,
             *          "lyric": "[by:虎纹鲨鱼子]\n[00:11.13]\n[00:19.83]向着流星祈愿\n[00:26.19]看，只要双手合十\n"
             *      },
             *      "romalrc": {
             *          "version": 4,
             *          "lyric": "[by:虎纹鲨鱼子]\n[00:11.13]\n[00:19.83]na ga re ru ho shi wo\n[00:26.19]ta da ka sa ne ru yu bi wo\n"
             *      },
             *      "code": 200
             *  }
             *
             * we can use lrc.lyric
             */
            // default display of song title and artist
            lyric_line.text = tracker.name
            lyric_second_line.text = tracker.artist
            if (tracker.id != id_original_cache) {
                lyric_original_cache = ""
                id_original_cache = -1
                valid_original_cache = false
            }
            if (tracker.id != id_translated_cache) {
                lyric_translated_cache = ""
                id_translated_cache = -1
                valid_translated_cache = false
            }
            if (tracker.id != id_romaji_cache) {
                lyric_romaji_cache = ""
                id_romaji_cache = -1
                valid_romaji_cache = false
            }


            if (
                !valid_original_cache
                || (!valid_translated_cache && !no_translated_cache)
                || (!valid_romaji_cache && !no_romaji_cache)
            ) {
                var xhr = new XMLHttpRequest();
                xhr.open('GET', 'http://127.0.0.1:10754/lyric?id=' + tracker.id)
                xhr.send()
                xhr.onreadystatechange = function () {
                    if (xhr.readyState === 4 || xhr.status === 200) {
                        var raw_json = xhr.responseText

                        /*
                         * note:
                         * For some reasons, JSON.parse will report
                         * "Syntax Error" while parsing response text.
                         * so, manually parsing JSON here
                         */
                        var lyrics = extract_lyrics(raw_json)
                        /* cache lyric */
                        if (lyrics.original !== "") {
                            lyric_original_cache = lyrics.original
                            id_original_cache = tracker.id
                            valid_original_cache = true
                        }
                        if (lyrics.translated != "") {
                            lyric_translated_cache = lyrics.translated
                            id_translated_cache = tracker.id
                            valid_translated_cache = true
                        } else if (valid_original_cache) {
                            no_translated_cache = true
                        }
                        if (lyrics.romaji != "") {
                            lyric_romaji_cache = lyrics.romaji
                            id_romaji_cache = tracker.id
                            valid_romaji_cache = true
                        } else if (valid_original_cache) {
                            no_romaji_cache = true
                        }
                    }
                }
            }

            if (valid_original_cache) {
                // select original tor other types
                var target_lyrics = ""
                var target_type = ""
                var second_lyrics = ""
                var second_type = ""
                if (cfg_first_language === "romaji" && valid_romaji_cache) {
                    target_lyrics = lyric_romaji_cache
                    target_type = "romaji"
                } else if (cfg_first_language === "translated" && valid_translated_cache) {
                    target_lyrics = lyric_translated_cache
                    target_type = "translated"
                } else {
                    target_lyrics = lyric_original_cache
                    target_type = "original"
                }
                if (cfg_second_language === "romaji" && valid_romaji_cache) {
                    second_lyrics = lyric_romaji_cache
                    second_type = "romaji"
                } else if (cfg_second_language === "translated" && valid_translated_cache) {
                    second_lyrics = lyric_translated_cache
                    second_type = "translated"
                } else if (cfg_second_language === "original") {
                    second_lyrics = lyric_original_cache
                    second_type = "original"
                } else {
                    second_type = target_type
                }

                var ret_lyric = get_lyric_by_time(target_lyrics, tracker.progress)

                if (ret_lyric === "" || ret_lyric === null || ret_lyric === undefined) {
                    switch (target_type) {
                        case "original":
                            valid_original_cache = false
                            return
                        case "translated":
                            valid_translated_cache = false
                            return
                        case "romaji":
                            valid_romaji_cache = false
                            return
                    }
                }

                var line = ret_lyric

                if (cfg_second_language != "disable" && second_type != target_type) {
                    var second_lyric = get_lyric_by_time(second_lyrics, tracker.progress)
                    if (second_lyric === "" || second_lyric === null || second_lyric === undefined) {
                        switch (second_type) {
                            case "original":
                                valid_original_cache = false
                                return
                            case "translated":
                                valid_translated_cache = false
                                return
                            case "romaji":
                                valid_romaji_cache = false
                                return
                        }
                    }
                    if (cfg_second_language_wrapping != "disable")
                        lyric_second_line.text = second_lyric
                    else
                        line = line + " " + second_lyric
                } else {
                    lyric_second_line.text = "";
                }
                lyric_line.text = line;
            }
        }

        function extract_lyrics(raw_json) {
            return {
                original: extract_translated_lyrics(raw_json, "original"),
                translated: extract_translated_lyrics(raw_json, "translated"),
                romaji: extract_translated_lyrics(raw_json, "romaji")
            }
        }

        function extract_translated_lyrics(raw_json, type) {
            /* get .lrc*/
            var begin = 0
            if (type === "romaji") {
                if (raw_json.indexOf("\"romalrc\":") != -1)
                    begin = raw_json.indexOf("\"romalrc\":") + 10
                else
                    return ""
            } else if (type === "translated") {
                if (raw_json.indexOf("\"tlyric\":") != -1)
                    begin = raw_json.indexOf("\"tlyric\":") + 9
                else
                    return ""
            } else {
                begin = raw_json.indexOf("\"lrc\":") + 6
            }
            raw_json = raw_json.substring(begin)

            /* get .lrc.lyric */
            begin = raw_json.indexOf("\"lyric\":") + 9
            raw_json = raw_json.substring(begin)
            begin = 0

            /* get right " */
            var end = begin
            for (var i = 0; i < raw_json.length; i++) {
                if (raw_json[i] == '\\' || raw_json[i] == '\"') {
                    if (raw_json[i] == '\\') {
                        i = i + 1
                    } else {
                        end = i
                        break
                    }
                }
            }
            raw_json = raw_json.substring(begin, end)

            if (!(raw_json == undefined || raw_json == null || raw_json == '')) {
                // replace escape character
                var replace = raw_json.replace(/\\n/g, '\n')
                replace = replace.replace(/\\\"/g, "\"")
                replace = replace.replace(/\\\\/g, "\\")
                return replace
            } else {
                return ""
            }
        }

        function get_id_progress(ypm_res) {
            /*
             *  the response of api http://127.0.0.1:27232/player
             *
             *  {
             *      "currentTrack": {
             *      "name": "broKen NIGHT",
             *      "id": 476081900,
             *      "pst": 0,
             *      "t": 0,
             *      "ar": [{
             *          "id": 16152,
             *          "name": "Aimer",
             *          "tns": [],
             *          "alias": []
             *      }],
             *      "alia": ["PS Vitaゲーム「Fate/hollow ataraxia」OPテーマ"],
             *      "pop": 40,
             *      ......
             *      "progress":61.662793
             *  }
             *
             *  all we need is "currentTrack"."id" and "progress"
             */

            if (!(ypm_res == undefined || ypm_res == null || ypm_res == '')) {
                var obj = JSON.parse(ypm_res);
                const names = obj.currentTrack.ar.map(artist => artist.name).join('/');
                return {id: obj.currentTrack.id, progress: obj.progress, name: obj.currentTrack.name, artist: names};
            } else {
                return {id: -1, progress: 0};
            }
        }
    }
}
