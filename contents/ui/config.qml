import QtQuick 2.0
import QtQuick.Controls 1.0 as QtControls
import QtQuick.Layouts 1.0 as QtLayouts

Item {
    id: config_page
    width: childrenRect.width
    height: childrenRect.height

    property alias cfg_flush_time: config_flush_time.value

    QtLayouts.ColumnLayout {
        anchors.left: parent.left

        QtLayouts.RowLayout {
            QtControls.Label {
                text: i18n("flush time:")
            }

            QtControls.SpinBox {
                id: config_flush_time
                minimumValue: 10;
                maximumValue: 2000;
                value: 100
                stepSize: 10
            }

            QtControls.Label {
                text: i18n("ms")
            }
        }
    }
}