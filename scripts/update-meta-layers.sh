#!/bin/bash
############################################################################
##
## Copyright (C) 2021 The Qt Company Ltd.
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

# Checkout latest revision of all or selected meta layers and update the sha1s to the manifest.xml

MANIFEST=$(dirname $(realpath $0))/manifest.xml

REPOS=${@:-$(repo list -n)}
REPOS=${REPOS//meta-boot2qt}

repo sync $REPOS -n
repo forall $REPOS -c "\
 git checkout \$REPO_REMOTE/\$REPO_UPSTREAM ; \
 echo \$REPO_PROJECT has \$(git rev-list --count \$REPO_LREV..HEAD) new commits; \
 if [ \"\$(git describe --abbrev=0 \$REPO_LREV)\" != \"\$(git describe --abbrev=0 HEAD)\" ]; then \
  echo \"  new tag available: \$(git describe --abbrev=0 HEAD)\"; \
 fi ; \
 sed -e s/\$REPO_LREV/\$(git rev-parse HEAD)/ \
     -e \"/\$REPO_PROJECT/,/revision/s|\$REPO_RREV|\$(git rev-parse HEAD)|\" \
     -i ${MANIFEST}"
