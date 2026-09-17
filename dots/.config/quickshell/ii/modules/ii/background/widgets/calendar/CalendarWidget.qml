import QtQuick
import QtQuick.Layouts
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import qs.modules.common.widgets.widgetCanvas
import qs.modules.ii.background.widgets

AbstractBackgroundWidget {
    id: root
    configEntryName: "calendar"
    hoverEnabled: true

    readonly property real cardWidth: 132 * 3 + 12 * 2
    readonly property real cardHeight: 120 * 2 + 12

    implicitWidth: card.implicitWidth
    implicitHeight: card.implicitHeight

    readonly property var today: new Date()

    function getMonthMatrix(date) {
        const year  = date.getFullYear()
        const month = date.getMonth()
        const firstOfMonth   = new Date(year, month, 1)
        const startOffset    = (firstOfMonth.getDay() + 6) % 7
        const daysInMonth    = new Date(year, month + 1, 0).getDate()
        const daysInPrevMonth = new Date(year, month, 0).getDate()

        let cells = []
        for (let i = 0; i < startOffset; i++)
            cells.push({ day: daysInPrevMonth - startOffset + i + 1, currentMonth: false, isToday: false })

        for (let d = 1; d <= daysInMonth; d++) {
            const isToday = d === today.getDate()
                && month === today.getMonth()
                && year  === today.getFullYear()
            cells.push({ day: d, currentMonth: true, isToday: isToday })
        }

        let nextDay = 1
        while (cells.length < 42) {
            cells.push({ day: nextDay++, currentMonth: false, isToday: false })
        }

        let weeks = []
        for (let i = 0; i < cells.length; i += 7)
            weeks.push(cells.slice(i, i + 7))
        return weeks
    }

    component DayCell: Rectangle {
        property int day: 0
        property bool currentMonth: true
        property bool isToday: false
        property bool bold: false

        implicitWidth: 28
        implicitHeight: 28
        radius: 14
        color: isToday ? Appearance.colors.colPrimary : "transparent"

        StyledText {
            anchors.centerIn: parent
            text: parent.day
            font.pixelSize: Appearance.font.pixelSize.smaller
            font.weight: parent.bold || parent.isToday ? Font.Bold : Font.Normal
            color: parent.isToday
                ? Appearance.colors.colOnPrimary
                : Appearance.colors.colOnLayer0
            opacity: parent.currentMonth ? 1.0 : 0.3
        }
    }

    Rectangle {
        id: card
        implicitWidth: root.cardWidth
        implicitHeight: root.cardHeight
        radius: Appearance.rounding?.verylarge ?? 30
        color: Appearance.colors.colPrimaryContainer

        // Simple tinted background in place of FastBlurred (no live wallpaper blur)
        Rectangle {
            anchors.fill: parent
            radius: card.radius
            color: Appearance.colors.colLayer1
            opacity: 0.55
            visible: Config.options.background.widgets.blurWidgets
        }

        StyledDropShadow { target: card }

        // 2x3 (big calendar variant)
        RowLayout {
            anchors { fill: parent; margins: 16 }
            spacing: 16

            ColumnLayout {
                Layout.preferredWidth: 110
                Layout.fillHeight: true
                spacing: 2

                MaterialShapeWrappedMaterialSymbol {
                    shape: MaterialShape.Shape.Gem
                    color: Appearance.colors.colPrimary
                    colSymbol: Appearance.colors.colOnPrimary
                    text: "calendar_month"
                    iconSize: 22
                    fill: 1
                    padding: 6
                    implicitWidth: 44
                    implicitHeight: 44
                }

                Item { Layout.fillHeight: true }

                StyledText {
                    text: root.today.toLocaleDateString(Qt.locale(), "MMMM").toUpperCase()
                    font.pixelSize: Appearance.font.pixelSize.normal
                    font.weight: Font.Bold
                    color: Appearance.colors.colOnPrimaryContainer
                    opacity: 0.6
                }
                StyledText {
                    text: root.today.toLocaleDateString(Qt.locale(), "dddd")
                    font.pixelSize: Appearance.font.pixelSize.larger
                    font.weight: Font.DemiBold
                    color: Appearance.colors.colOnPrimaryContainer
                    opacity: 0.8
                }

                StyledText {
                    text: root.today.getDate()
                    font.pixelSize: 66
                    font.weight: Font.Bold
                    color: Appearance.colors.colPrimary
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: ColorUtils.transparentize(Appearance.colors.colLayer0, 0.8)
                radius: (Appearance.rounding?.verylarge ?? 30) - 8

                ColumnLayout {
                    anchors { fill: parent; margins: 10 }
                    spacing: 4

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: 10
                        spacing: 4
                        Repeater {
                            model: ["Mo","Tu","We","Th","Fr","Sa","Su"]
                            delegate: StyledText {
                                Layout.preferredWidth: 24
                                horizontalAlignment: Text.AlignHCenter
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                font.weight: Font.Bold
                                color: Appearance.colors.colOnPrimaryContainer
                                opacity: 0.6
                                text: modelData
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillHeight: true
                        Layout.alignment: Qt.AlignHCenter
                        spacing: -3

                        Repeater {
                            model: root.getMonthMatrix(root.today)
                            delegate: RowLayout {
                                required property var modelData
                                spacing: 4
                                Repeater {
                                    model: parent.modelData
                                    delegate: DayCell {
                                        required property var modelData
                                        day: modelData.day
                                        currentMonth: modelData.currentMonth
                                        isToday: modelData.currentMonth && modelData.day === root.today.getDate()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

