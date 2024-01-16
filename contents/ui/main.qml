import QtQuick 2.1
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.5
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents

import "lyrics.js" as Json_lyrics

Item {
    id: root

    readonly property int flush_time: Plasmoid.configuration.flush_time

    Plasmoid.compactRepresentation: Plasmoid.fullRepresentation
    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation
    Plasmoid.fullRepresentation: Item {
        Layout.preferredWidth: lyric_line.implicitWidth
        Layout.preferredHeight: lyric_line.implicitWidth
        Label {
            id: lyric_line;
            text: "";
            color: theme.textColor;
            anchors.fill: parent
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }

        Timer {
            interval: flush_time; running: true; repeat: true
            onTriggered: get_lyric();
        }

        property string lyric_cache: ''
        property int id_cache: 0
        property bool cached: false

        function get_lyric() {
            var xhr= new XMLHttpRequest();
            xhr.open('GET', 'http://127.0.0.1:27232/player', false);
            xhr.send(null);
            if (200 == xhr.status) {
                var tracker = get_id_progress(xhr.responseText);

                if (tracker.id == -1) return

                select_lyric(tracker);
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

            if (tracker.id != id_cache) {
                cached = false
            }

            if (!cached) {
                var xhr= new XMLHttpRequest();
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
                        /* get .lrc*/
                        var begin = raw_json.indexOf("\"lrc\":") + 6
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

                        /* cache lyric */
                        if (!(raw_json == undefined || raw_json == null || raw_json == '')) {
                            var lyric_text = raw_json;
                            if (id_cache != tracker.id) {
                                var relace = lyric_text.replace(/\\n/g,'\n')
                                lyric_cache = relace
                                id_cache = tracker.id
                            }
                        }
                    }
                }
            }

            if (!(lyric_cache == undefined || lyric_cache == null || lyric_cache == '')) {
                var lyric_obj = new Lyrics(lyric_cache);
                var last_time = 0
                var last_text = ""
                var flag = false
                for (var i = 0; i < lyric_obj.length; i++) {
                    if ((last_time <= tracker.progress) &&  (tracker.progress < lyric_obj.lyrics_all[i].timestamp)) {
                        if (last_text != '') {
                            lyric_line.text = last_text
                        }
                        flag = true
                        cached = true
                    }
                    last_time = lyric_obj.lyrics_all[i].timestamp
                    last_text = lyric_obj.lyrics_all[i].text
                    if (flag) {
                        break
                    }
                }

                if(!flag) {
                    lyric_line.text = last_text
                }
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
                return {id: obj.currentTrack.id, progress: obj.progress};
            } else {
                return {id: -1, progress: 0};
            }
        }
    }
}
