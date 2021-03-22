############################################################################
##
## Copyright (C) 2016 The Qt Company Ltd.
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

DESCRIPTION = "B2Qt Automotive Qt5 image"
LICENSE = "The-Qt-Company-Commercial"
LIC_FILES_CHKSUM = "file://${BOOT2QTBASE}/licenses/The-Qt-Company-Commercial;md5=213dc233cc25f71b1447fbe95ec90adf"

DEPLOY_CONF_TYPE = "Qt Automotive Suite $QT_VERSION"

IMAGE_FEATURES += "\
        package-management \
        ssh-server-dropbear \
        tools-debug \
        tools-profile \
        debug-tweaks \
        hwcodecs \
        "

inherit core-image qbsp-image
inherit consistent_timestamps

IMAGE_INSTALL += "\
    packagegroup-b2qt-embedded-base \
    packagegroup-b2qt-embedded-tools \
    ${@bb.utils.contains("DISTRO_FEATURES", "gstreamer010", "packagegroup-b2qt-embedded-gstreamer010", "", d)} \
    ${@bb.utils.contains("DISTRO_FEATURES", "gstreamer", "packagegroup-b2qt-embedded-gstreamer", "", d)} \
    packagegroup-b2qt-qt5-modules \
    packagegroup-b2qt-automotive-addons \
    "
