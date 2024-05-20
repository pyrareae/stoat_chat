// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: %{CURRENT_YEAR} %{AUTHOR} <%{EMAIL}>

import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.19 as Kirigami
import org.kde.stoat_chat_qml_kirigami 1.0

Kirigami.ApplicationWindow {
    id: root

    title: i18n("stoat_chat_qml_kirigami")

    pageStack.initialPage: page

    function send() {
    }

    Kirigami.Page {
        id: page

        Layout.fillWidth: true
        Layout.fillHeight: true
        height: root.height

        title: i18n("Stoat Chat")

        ColumnLayout {
            width: parent.width
            height: parent.height
            ListView {
                Layout.fillHeight: true
                id: chatList
                width: page.width
                model: App.messages

                delegate: Item {
                    required property string
                    height: childrenRect.height
                    Rectangle {
                        height: childrenRect.height
                        Text{
                            color: Kirigami.Theme.textColor
                            text: message
                        }
                    }

                }
            }
            RowLayout {
                width: page.width

                Controls.TextField {
                    Layout.fillWidth: true
                    id: mainInput
                    Keys.onPressed: {
                        if (event.key == Qt.Key_enter) {send()}
                    }
                }

                Controls.Button {
                    text: ">>"
                    id: submitButton
                    onClicked: {send()}
                }
            }
        }
    }
}
