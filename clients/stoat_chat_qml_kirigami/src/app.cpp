// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: %{CURRENT_YEAR} %{AUTHOR} <%{EMAIL}>

#include "app.h"
#include <KSharedConfig>
#include <KWindowConfig>
#include <QQuickWindow>
#include <thread>
#include <iostream>
#include <memory>

#include "./vendor/easywsclient.cpp"
#include <qjsondocument.h>
#include <boost/format.hpp>

// void App::restoreWindowGeometry(QQuickWindow *window, const QString &group) const
// {
//     KConfig dataResource(QStringLiteral("data"), KConfig::SimpleConfig, QStandardPaths::AppDataLocation);
//     KConfigGroup windowGroup(&dataResource, QStringLiteral("Window-") + group);
//     KWindowConfig::restoreWindowSize(window, windowGroup);
//     KWindowConfig::restoreWindowPosition(window, windowGroup);
// }
//
// void App::saveWindowGeometry(QQuickWindow *window, const QString &group) const
// {
//     KConfig dataResource(QStringLiteral("data"), KConfig::SimpleConfig, QStandardPaths::AppDataLocation);
//     KConfigGroup windowGroup(&dataResource, QStringLiteral("Window-") + group);
//     KWindowConfig::saveWindowPosition(window, windowGroup);
//     KWindowConfig::saveWindowSize(window, windowGroup);
//     dataResource.sync();
// }

using namespace easywsclient;

Q_INVOKABLE App::App(QObject *parent) : QObject(parent) {

};

void App::startClient() {
    ws = std::unique_ptr<WebSocket>(WebSocket::from_url("ws://localhost:8887"));

    wsThread = std::make_unique<std::thread>([=](){
        while (ws->getReadyState() != WebSocket::CLOSED) {
            WebSocket::pointer wsp = &*ws; // <-- because a unique_ptr cannot be copied into a lambda
            ws->poll();
            ws->dispatch([wsp, this](const std::string & message) {
                printf(">>> %s\n", message.c_str());
                QJsonDocument json = QJsonDocument::fromJson(QByteArray::fromStdString(message));
                if (json["type"] == "history") {

                } else if (json["type"] == "message") {
//                     this->m_messages.append(boost::format("[%1%]<%2%> %3%") % json["data"]["time"] % json["data"]["nick"] % json["data"]["text"]);
                    this->m_messages.append(json["data"]["text"].toString());
                }
            });
        }
    });

    wsThread->detach();
};
