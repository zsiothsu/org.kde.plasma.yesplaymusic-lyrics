import QtQuick 
import QtQuick.Controls as QtControls
import QtQuick.Layouts as QtLayouts
import QtQuick.Dialogs 
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid 
import org.kde.kcmutils as KCM
KCM.SimpleKCM {
    id: config_page
    width: childrenRect.width
    height: childrenRect.height

    property alias cfg_flush_time: config_flush_time.value
    property alias cfg_time_offset: config_time_offset.value
    property alias cfg_text_color: text_color.selectedColor
    property alias cfg_text_font: text_font.selectedFont
    property alias cfg_first_language: first_language_text.text
    property alias cfg_second_language: second_language_text.text
    property alias cfg_second_language_wrapping: second_language_wrapping_text.text
    property alias cfg_text_align : text_align_text.text
    QtLayouts.ColumnLayout {
        anchors.left: parent.left

        QtLayouts.RowLayout {
            QtControls.Label {
                text: i18n("flush time: ")
            }

            QtControls.SpinBox {
                id: config_flush_time
                from: 10;
                to: 2000;
                value: cfg_flush_time
                stepSize: 10
            }

            QtControls.Label {
                text: i18n("ms (0~2000ms)")
            }
        }

        QtLayouts.RowLayout {
            QtControls.Label {
                text: i18n("time offset: ")
            }

            QtControls.SpinBox {
                id: config_time_offset
                from: -2000;
                to: 2000;
                value: cfg_time_offset
                stepSize: 500
            }

            QtControls.Label {
                text: i18n("ms (-2000~2000ms)")
            }
        }

        QtLayouts.RowLayout {
            QtControls.Label {
                text: i18n("color: ")
            }

            Rectangle {
                height: 20
                width: 20
                border.color: "black"
                color: text_color.selectedColor
                radius: 5
                MouseArea {
                    anchors.fill: parent
                    onClicked: text_color.open()
                }
            }

            ColorDialog {
                id: text_color
                title: "set text color"
            }
        }

        QtLayouts.RowLayout {
            QtControls.Label {
                id: font_layout
                text: i18n("font: ")
            }

            QtControls.Button {
                id: font_button
                text: cfg_text_font || i18n("default")
                onClicked: text_font.open()
            }

            FontDialog {
                id: text_font
                selectedFont: cfg_text_font
                onAccepted: {
                    font_button.text = text_font.selectedFont
                    cfg_text_font = text_font.selectedFont
                    text_font.close()
                }
                onRejected: {
                    text_font.close()
                }
            }
        }

        QtLayouts.RowLayout {
            QtControls.Label {
                id: first_language_layout
                text: i18n("first language: ")
            }

            QtControls.Label {
                id: first_language_text
                visible: false
            }

            // QtControls.ButtonGroup {
            //     id: first_language
            //     buttons: first_language_column.children
            //     onClicked: cfg_first_language = button.text
            // }

            Column {
                id: first_language_column

                QtControls.RadioButton {
                    text: "original"
                    checked: (first_language_text.text === text) || (first_language_text.text === "")
                    onClicked: first_language_text.text = "original"
                }
                QtControls.RadioButton {
                    text: "translated"
                    checked: first_language_text.text === text
                    onClicked: first_language_text.text = "translated"
                }
                QtControls.RadioButton {
                    text: "romaji"
                    checked: first_language_text.text === text
                    onClicked: first_language_text.text = "romaji"
                }
            }
        }
        QtLayouts.RowLayout {
            QtControls.Label {
                id: second_language_wrapping
                text: i18n("second language wrapping: ")
            }
            QtControls.Label {
                id: second_language_wrapping_text
                visible: false
            }
            Column {
                id: second_language_wrapping_column

                QtControls.RadioButton {
                    text: "disable"
                    checked: second_language_wrapping_text.text === text
                    onClicked: second_language_wrapping_text.text = "disable"
                }
                QtControls.RadioButton {
                    text: "enable"
                    checked: second_language_wrapping_text.text === text
                    onClicked: second_language_wrapping_text.text = "enable"
                }
            }
        }
        QtLayouts.RowLayout {
            QtControls.Label {
                id: second_language_layout
                text: i18n("second language: ")
            }

            QtControls.Label {
                id: second_language_text
                visible: false
            }

            // QtControls.ButtonGroup {
            //     id: second_language
            //     buttons: second_language_column.children
            //     onClicked: cfg_second_language = button.text
            // }

            Column {
                id: second_language_column

                QtControls.RadioButton {
                    text: "disable"
                    checked: (second_language_text.text === text) || (second_language_text.text === "")
                    onClicked: second_language_text.text = "disable"
                }
                QtControls.RadioButton {
                    text: "original"
                    checked: second_language_text.text === text
                    onClicked: second_language_text.text = "original"
                }
                QtControls.RadioButton {
                    text: "translated"
                    checked: second_language_text.text === text
                    onClicked: second_language_text.text = "translated"
                }
                QtControls.RadioButton {
                    text: "romaji"
                    checked: second_language_text.text === text
                    onClicked: second_language_text.text = "romaji"
                }
            }
        }
            QtLayouts.RowLayout {
                QtControls.Label {
                    id: text_align
                    text: i18n("text align: ")
                }
                QtControls.Label {
                    id: text_align_text
                    text: cfg_text_align
                    visible: false
                }

                Column {
                    QtControls.RadioButton {
                        text: "Left"
                        checked: cfg_text_align === "Left"
                        onClicked: cfg_text_align = "Left"
                    }
                    QtControls.RadioButton {
                        text: "Center"
                        checked: cfg_text_align === "Center"
                        onClicked: cfg_text_align = "Center"
                    }
                    QtControls.RadioButton {
                        text: "Right"
                        checked: cfg_text_align === "Right"
                        onClicked: cfg_text_align = "Right"
                    }
                }
            }
    }
}