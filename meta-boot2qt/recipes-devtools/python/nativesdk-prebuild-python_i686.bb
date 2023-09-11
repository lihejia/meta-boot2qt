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

COMPATIBLE_HOST = "i686.*-mingw.*"

SRC_URI = "\
    https://download.qt.io/development_releases/prebuilt/python/Python35-win-x86.7z \
    https://www.python.org/ftp/python/${PV}/python-${PV}-embed-win32.zip;name=bin \
    https://download.qt.io/development_releases/prebuilt/python/python-${PV}-modules-win32.7z;name=modules \
    "

SRC_URI[sha256sum] = "b60c49227c6e920904d784681c16ee3591a18824c3abb89613813f93fde1c1f2"
SRC_URI[bin.sha256sum] = "75f05800fbe4a8cd6672b268ca53244838684561e03c60c668a7dccb050eb954"
SRC_URI[modules.sha256sum] = "fd078a2888b2bd7daf46901dbe3c4bcab320c44540639f786e0d2b36ba30ac02"
