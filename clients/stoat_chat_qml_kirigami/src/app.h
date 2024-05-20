// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: %{CURRENT_YEAR} %{AUTHOR} <%{EMAIL}>

#pragma once

#include <QObject>
#include <memory>
#include <thread>
#include "./vendor/easywsclient.hpp"
#include "./message.h"


class QQuickWindow;

class App : public QObject
{
    Q_OBJECT

public:
    std::unique_ptr<std::thread> wsThread;
    std::unique_ptr<easywsclient::WebSocket> ws;
    QVector<QString> m_messages;

    Q_INVOKABLE App(QObject *parent=nullptr);
    // Restore current window geometry
//     Q_INVOKABLE void restoreWindowGeometry(QQuickWindow *window, const QString &group = QStringLiteral("main")) const;
    // Save current window geometry
//     Q_INVOKABLE void saveWindowGeometry(QQuickWindow *window, const QString &group = QStringLiteral("main")) const;
    void startClient();
    Q_PROPERTY(QVector<QString> messages MEMBER m_messages);
};
