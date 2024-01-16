import QtQuick 2.0
import QtQuick.Controls 1.0 as QtControls
import QtQuick.Layouts 1.0 as QtLayouts
import QtQuick.Dialogs 1.2

Item {
    id: config_page
    width: childrenRect.width
    height: childrenRect.height

    property alias cfg_flush_time: config_flush_time.value
    property alias cfg_text_color: text_color.color
    property alias cfg_text_font: text_font.font

    QtLayouts.ColumnLayout {
        anchors.left: parent.left

        QtLayouts.RowLayout {
            QtControls.Label {
                text: i18n("flush time: ")
            }

            QtControls.SpinBox {
                id: config_flush_time
                minimumValue: 10;
                maximumValue: 2000;
                value: cfg_flush_time
                stepSize: 10
            }

            QtControls.Label {
                text: i18n("ms")
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
                color: text_color.color
                radius: 5
                MouseArea {
                    anchors.fill: parent
                    onClicked: text_color.open()
                }
            }

            ColorDialog {
                id: text_color
                title: "set text color"
                currentColor: cfg_text_color
                onAccepted: {
                    cfg_text_color = colorDialog.color
                }
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
                font: cfg_text_font
                onAccepted: {
                    font_button.text = text_font.font
                    cfg_text_font = text_font.font
                    text_font.close()
                }
                onRejected: {
                    text_font.close()
                }
            }
        }
    }
}