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
    property alias cfg_translate: tranlate_button_text.text

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
                id: tranlate_button_layout
                text: i18n("translate: ")
            }

            QtControls.Label {
                id: tranlate_button_text
                visible: false
            }

            QtControls.ButtonGroup {
                id: tranlate_button
                buttons: tranlate_button_column.children
                onClicked: cfg_translate = button.text
            }

            Column {
                id: tranlate_button_column
                QtControls.RadioButton {
                    text: "original"
                    checked: (tranlate_button_text.text === text) || (tranlate_button_text.text === "")
                    onClicked: tranlate_button_text.text = "original"
                }
                QtControls.RadioButton {
                    text: "translated"
                    checked: tranlate_button_text.text === text
                    onClicked: tranlate_button_text.text = "translated"
                }
                QtControls.RadioButton {
                    text: "romaji"
                    checked: tranlate_button_text.text === text
                    onClicked: tranlate_button_text.text = "romaji"
                }
            }
        }
    }
}