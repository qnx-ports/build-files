// Copyright (C) 2023 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

QT += quick quick3d

target.path = $$[QT_INSTALL_EXAMPLES]/quick3d/particles3d
INSTALLS += target

SOURCES += \
    main.cpp

RESOURCES += \
    qml.qrc

OTHER_FILES += \
    doc/src/*.*
