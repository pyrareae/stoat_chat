// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: %{CURRENT_YEAR} %{AUTHOR} <%{EMAIL}>

#pragma once

#include <QObject>

class Message : public QObject
{
    Q_OBJECT

public:
    Q_PROPERTY(QString nick MEMBER m_nick);
    Q_PROPERTY(QString message MEMBER m_message);
    Q_PROPERTY(QString timestamp MEMBER m_timestamp);

    QString m_nick;
    QString m_message;
    QString m_timestamp;
};
