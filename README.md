Meta layer for Boot to Qt Software Stack
========================================

Boot to Qt (b2qt) is the reference distro used in Qt Embedded development [1].
It combines Poky, Qt and various BSP meta layers to provide an integrated
solution for building device images and toolchains with the latest Qt version.

Currently used dependencies, meta repositories and their revisions are shown in
scripts/manifest.xml

[1] https://doc.qt.io/embedded.html#boot2qt

Sources
-------

Git: git://code.qt.io/yocto/meta-boot2qt
Web: http://code.qt.io/cgit/yocto/meta-boot2qt.git
Gerrit: https://codereview.qt-project.org/#/admin/projects/yocto/meta-boot2qt

Contributing
------------

To contribute to this layer you should submit the patches for review using
Qt Gerrit (https://codereview.qt-project.org).

More information about Qt Gerrit and how to use it:
https://wiki.qt.io/Gerrit_Introduction
https://wiki.qt.io/Setting_up_Gerrit

Layer maintainers
-----------------

Samuli Piippo <samuli.piippo@qt.io>

Setting up build environment
----------------------------

Use the Google repo tool to initialize the Yocto environment:

  cd <BuildDir>
  repo init -u git://code.qt.io/yocto/boot2qt-manifest -m <manifest>
  repo sync

Where manifest is one of the XML manifest files available in the
https://code.qt.io/cgit/yocto/boot2qt-manifest.git/tree/ repository.
A separate manifest file is available for each release and all the
development branches have manifests that follow the latest changes.

For more information about using Boot to Qt, see:
https://doc.qt.io/Boot2Qt/index.html
