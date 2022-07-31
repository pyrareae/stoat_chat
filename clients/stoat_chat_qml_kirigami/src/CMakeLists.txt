# SPDX-License-Identifier: BSD-3-Clause
# SPDX-FileCopyrightText: %{CURRENT_YEAR} %{AUTHOR} <%{EMAIL}>

add_executable(stoat_chat_qml_kirigami
    main.cpp
    about.cpp
    app.cpp
    resources.qrc)

target_link_libraries(stoat_chat_qml_kirigami
    Qt5::Core
    Qt5::Gui
    Qt5::Qml
    Qt5::Quick
    Qt5::QuickControls2
    Qt5::Svg
    KF5::I18n
    KF5::CoreAddons
    KF5::ConfigCore
    KF5::ConfigGui)

if (ANDROID)
    kirigami_package_breeze_icons(ICONS
        list-add
        help-about
        application-exit
        applications-graphics
    )
endif()

kconfig_add_kcfg_files(stoat_chat_qml_kirigami GENERATE_MOC stoat_chat_qml_kirigamiconfig.kcfgc)
install(TARGETS stoat_chat_qml_kirigami ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
