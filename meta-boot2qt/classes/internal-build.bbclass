############################################################################
##
## Copyright (C) 2022 The Qt Company Ltd.
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

python enable_internal_build () {
    import socket
    try:
        socket.gethostbyname('yocto-cache.ci.qt.io')
    except:
        return

    # enable qtsaferenderer for internal builds
    e.data.appendVar('DISTRO_FEATURES_BACKFILL', ' qtsaferenderer')
    # enable commercial modules and qmlcompiler
    e.data.setVar('QT_COMMERCIAL_MODULES', '1')

    e.data.setVar('QT_INTERNAL_BUILD', "1")
    e.data.prependVar('SSTATE_MIRRORS', "file://.* http://yocto-cache.ci.qt.io/sstate-caches/${DISTRO_CODENAME}/PATH")
    e.data.setVar("BB_HASHSERVE_UPSTREAM", "yocto-cache.ci.qt.io:8686")
    e.data.prependVar('PREMIRRORS', "\
        ftp://.*/.*   http://yocto-cache.ci.qt.io/sources/ \n \
        http://.*/.*  http://yocto-cache.ci.qt.io/sources/ \n \
        https://.*/.* http://yocto-cache.ci.qt.io/sources/ \n \
        bzr://.*/.*   http://yocto-cache.ci.qt.io/sources/ \n \
        cvs://.*/.*   http://yocto-cache.ci.qt.io/sources/ \n \
        git://.*/.*   http://yocto-cache.ci.qt.io/sources/ \n \
        gitsm://.*/.* http://yocto-cache.ci.qt.io/sources/ \n \
        hg://.*/.*    http://yocto-cache.ci.qt.io/sources/ \n \
        osc://.*/.*   http://yocto-cache.ci.qt.io/sources/ \n \
        p4://.*/.*    http://yocto-cache.ci.qt.io/sources/ \n \
        svn://.*/.*   http://yocto-cache.ci.qt.io/sources/ \n \
        ")
}

addhandler enable_internal_build
enable_internal_build[eventmask] = "bb.event.ConfigParsed"
