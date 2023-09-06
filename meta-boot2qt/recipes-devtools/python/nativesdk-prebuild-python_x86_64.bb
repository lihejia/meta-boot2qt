############################################################################
##
## Copyright (C) 2017 The Qt Company Ltd.
## Contact: https://www.qt.io/licensing/
##
## This file is part of the Boot to Qt meta layer.
##
## $QT_BEGIN_LICENSE:GPL$
## Commercial License Usage
## Licensees holding valid commercial Qt licenses may use this file in
## accordance with the commercial license agreement provided with the
## Software or, alternatively, in accordance with the terms contained in
## a written agreement between you and The Qt Company. For licensing terms
## and conditions see https://www.qt.io/terms-conditions. For further
## information use the contact form at https://www.qt.io/contact-us.
##
## GNU General Public License Usage
## Alternatively, this file may be used under the terms of the GNU
## General Public License version 3 or (at your option) any later version
## approved by the KDE Free Qt Foundation. The licenses are as published by
## the Free Software Foundation and appearing in the file LICENSE.GPL3
## included in the packaging of this file. Please review the following
## information to ensure the GNU General Public License requirements will
## be met: https://www.gnu.org/licenses/gpl-3.0.html.
##
## $QT_END_LICENSE$
##
############################################################################

require nativesdk-prebuild-python.inc

COMPATIBLE_HOST = "x86_64.*-mingw.*"

SRC_URI = "\
    https://download.qt.io/development_releases/prebuilt/python/Python35-win-x64.7z \
    https://www.python.org/ftp/python/${PV}/python-${PV}-embed-amd64.zip;name=bin \
    https://download.qt.io/development_releases/prebuilt/python/python-${PV}-modules-amd64.7z;name=modules \
    "

SRC_URI[sha256sum] = "43e38c8a05dcbc2effd1915dbe2dc2be6e701ebf3eb00d6e45197ee773978124"
SRC_URI[bin.sha256sum] = "faefbd98f61c0d87c5683eeb526ae4d4a9ddc369bef27870cfe1c8939329d066"
SRC_URI[modules.sha256sum] = "64ef161e9e6a96a2f59582a133a86414ff4b135f367d733dc351d54d970fff9f"
