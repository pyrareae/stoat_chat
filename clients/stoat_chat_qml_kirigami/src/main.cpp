/*
    SPDX-License-Identifier: GPL-2.0-or-later
    SPDX-FileCopyrightText: %{CURRENT_YEAR} %{AUTHOR} <%{EMAIL}>
*/

#include <QApplication>
#include <QQmlApplicationEngine>
#include <QUrl>
#include <QtQml>

#include "about.h"
#include "app.h"
#include "version-stoat_chat_qml_kirigami.h"
#include <KAboutData>
#include <KLocalizedContext>
#include <KLocalizedString>

#include "stoat_chat_qml_kirigamiconfig.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc, argv);
    QCoreApplication::setOrganizationName(QStringLiteral("KDE"));
    QCoreApplication::setApplicationName(QStringLiteral("stoat_chat_qml_kirigami"));

    KAboutData aboutData(
                         // The program name used internally.
                         QStringLiteral("stoat_chat_qml_kirigami"),
                         // A displayable program name string.
                         i18nc("@title", "stoat_chat_qml_kirigami"),
                         // The program version string.
                         QStringLiteral(STOAT_CHAT_QML_KIRIGAMI_VERSION_STRING),
                         // Short description of what the app does.
                         i18n("Application Description"),
                         // The license this code is released under.
                         KAboutLicense::GPL,
                         // Copyright Statement.
                         i18n("(c) %{CURRENT_YEAR}"));
    aboutData.addAuthor(i18nc("@info:credit", "%{AUTHOR}"),
                        i18nc("@info:credit", "Author Role"),
                        QStringLiteral("%{EMAIL}"),
                        QStringLiteral("https://yourwebsite.com"));
    KAboutData::setApplicationData(aboutData);

    QQmlApplicationEngine engine;

    auto config = stoat_chat_qml_kirigamiConfig::self();

    qmlRegisterSingletonInstance("org.kde.stoat_chat_qml_kirigami", 1, 0, "Config", config);

    AboutType about;
    qmlRegisterSingletonInstance("org.kde.stoat_chat_qml_kirigami", 1, 0, "AboutType", &about);

    App application;
    qmlRegisterSingletonInstance("org.kde.stoat_chat_qml_kirigami", 1, 0, "App", &application);

    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));
    engine.load(QUrl(QStringLiteral("qrc:///main.qml")));

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    application.startClient();
    return app.exec();
}
