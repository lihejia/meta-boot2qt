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

inherit nopackages abi-arch siteinfo

FILESEXTRAPATHS:prepend := "${BOOT2QTBASE}/files/qbsp:"

SRC_URI = "\
    file://base_package.xml \
    file://base_installscript.qs \
    file://image_package.xml \
    file://toolchain_package.xml \
    file://toolchain_installscript.qs \
    file://license_package.xml \
    "

INHIBIT_DEFAULT_DEPS = "1"
do_qbsp[depends] += "\
    p7zip-native:do_populate_sysroot \
    installer-framework-native:do_populate_sysroot \
    ${@d.getVar('QBSP_SDK_TASK', True) + ':do_populate_sdk' if d.getVar('QBSP_SDK_TASK', True) else ''}  \
    ${@d.getVar('QBSP_IMAGE_TASK', True) + ':do_image_complete' if d.getVar('QBSP_IMAGE_TASK', True) else ''}  \
    "

QBSP_VERSION ?= "${PV}${VERSION_AUTO_INCREMENT}"
QBSP_INSTALLER_COMPONENT ?= "${@d.getVar('MACHINE').replace('-','')}"
QBSP_INSTALL_PATH ?= "/Extras/${MACHINE}"

QBSP_LICENSE_FILE ??= ""
QBSP_LICENSE_NAME ??= ""

QBSP_FORCE_CONTAINER_TOOLCHAIN ?= "false"
QBSP_FORCE_CONTAINER_TOOLCHAIN:sdkmingw32 = "false"

TOOLCHAIN_HOST_TYPE = "linux"
TOOLCHAIN_HOST_TYPE:sdkmingw32 = "windows"

VERSION_AUTO_INCREMENT = "-${DATETIME}"
VERSION_AUTO_INCREMENT[vardepsexclude] = "DATETIME"

DEPLOY_CONF_NAME ?= "${MACHINE}"
RELEASEDATE = "${@time.strftime('%Y-%m-%d',time.gmtime())}"

IMAGE_PACKAGE = "${QBSP_IMAGE_TASK}-${MACHINE}.7z"
SDK_NAME = "${DISTRO}-${SDK_MACHINE}-${QBSP_SDK_TASK}-${MACHINE}.${SDK_POSTFIX}"
SDK_POSTFIX = "sh"
SDK_POSTFIX:sdkmingw32 = "tar.xz"
REAL_MULTIMACH_TARGET_SYS = "${TUNE_PKGARCH}${TARGET_VENDOR}-${TARGET_OS}"
SDK_MACHINE = "${@d.getVar('SDKMACHINE') or '${SDK_ARCH}'}"

B = "${WORKDIR}/build"

patch_installer_files() {
    LICENSE_DEPENDENCY=""
    if [ -n "${QBSP_LICENSE_FILE}" ]; then
        LICENSE_DEPENDENCY="${QBSP_INSTALLER_COMPONENT}.license"
    fi

    sed -e "s#@NAME@#${QBSP_NAME}#" \
        -e "s#@TARGET@#${DEPLOY_CONF_NAME}#" \
        -e "s#@QBSP_VERSION@#${QBSP_VERSION}#" \
        -e "s#@RELEASEDATE@#${RELEASEDATE}#" \
        -e "s#@MACHINE@#${MACHINE}#" \
        -e "s#@SYSROOT@#${REAL_MULTIMACH_TARGET_SYS}#" \
        -e "s#@TARGET_SYS@#${TARGET_SYS}#" \
        -e "s#@ABI@#${ABI}#" \
        -e "s#@BITS@#${SITEINFO_BITS}#" \
        -e "s#@INSTALLPATH@#${QBSP_INSTALL_PATH}#" \
        -e "s#@SDKPATH@#${SDKPATH}#" \
        -e "s#@SDKFILE@#${SDK_NAME}#" \
        -e "s#@LICENSEDEPENDENCY@#${LICENSE_DEPENDENCY}#" \
        -e "s#@LICENSEFILE@#$(basename ${QBSP_LICENSE_FILE})#" \
        -e "s#@LICENSENAME@#${QBSP_LICENSE_NAME}#" \
        -e "s#@TOOLCHAIN_HOST_SYSROOT@#${SDK_SYS}#" \
        -e "s#@FORCE_CONTAINER_TOOLCHAIN@#${QBSP_FORCE_CONTAINER_TOOLCHAIN}#" \
        -e "s#@TOOLCHAIN_HOST_TYPE@#${TOOLCHAIN_HOST_TYPE}#" \
        -e "s#@DOCKER_ARCH@#${@'arm64' if d.getVar('SDKMACHINE') == 'aarch64' else 'amd64'}#" \
        -e "s#@VERSION@#${PV}#" \
        -e "s#@YOCTO@#${DISTRO_VERSION} (${DISTRO_CODENAME})#" \
        -i ${1}/*
}

prepare_qbsp() {
    # Toolchain component
    if [ -e ${DEPLOY_DIR}/sdk/${SDK_NAME} ]; then
        COMPONENT_PATH="${B}/pkg/${QBSP_INSTALLER_COMPONENT}.toolchain"
        mkdir -p ${COMPONENT_PATH}/meta
        mkdir -p ${COMPONENT_PATH}/data

        cp ${WORKDIR}/toolchain_package.xml ${COMPONENT_PATH}/meta/package.xml
        cp ${WORKDIR}/toolchain_installscript.qs ${COMPONENT_PATH}/meta/installscript.qs
        patch_installer_files ${COMPONENT_PATH}/meta

        if [ "${SDK_POSTFIX}" = "${SDK_POSTFIX:sdkmingw32}" ]; then
            cp ${DEPLOY_DIR}/sdk/${SDK_NAME} ${COMPONENT_PATH}/data/toolchain.${SDK_POSTFIX}
        else
            7za a -mx=0 ${COMPONENT_PATH}/data/toolchain.7z ${DEPLOY_DIR}/sdk/${SDK_NAME}
        fi
    fi

    # Image component, only if we have the qbsp-image
    if [ -e ${DEPLOY_DIR_IMAGE}/${IMAGE_PACKAGE} ]; then
        COMPONENT_PATH="${B}/pkg/${QBSP_INSTALLER_COMPONENT}.system"
        mkdir -p ${COMPONENT_PATH}/meta
        mkdir -p ${COMPONENT_PATH}/data

        cp ${WORKDIR}/image_package.xml ${COMPONENT_PATH}/meta/package.xml
        patch_installer_files ${COMPONENT_PATH}/meta

        cp ${DEPLOY_DIR_IMAGE}/${IMAGE_PACKAGE} ${COMPONENT_PATH}/data/image.7z
    fi

    # License component
    if [ -n "${QBSP_LICENSE_FILE}" ]; then
        COMPONENT_PATH="${B}/pkg/${QBSP_INSTALLER_COMPONENT}.license"
        mkdir -p ${COMPONENT_PATH}/meta

        cp ${WORKDIR}/license_package.xml ${COMPONENT_PATH}/meta/package.xml
        cp ${QBSP_LICENSE_FILE} ${COMPONENT_PATH}/meta/
        patch_installer_files ${COMPONENT_PATH}/meta
    fi

    # Base component
    COMPONENT_PATH="${B}/pkg/${QBSP_INSTALLER_COMPONENT}"
    mkdir -p ${COMPONENT_PATH}/meta

    cp ${WORKDIR}/base_package.xml ${COMPONENT_PATH}/meta/package.xml
    cp ${WORKDIR}/base_installscript.qs ${COMPONENT_PATH}/meta/installscript.qs
    patch_installer_files ${COMPONENT_PATH}/meta
}

create_qbsp() {
    prepare_qbsp

    # Repository creation
    repogen -p ${B}/pkg ${B}/repository

    mkdir -p ${DEPLOY_DIR}/qbsp
    rm -f ${DEPLOY_DIR}/qbsp/${PN}-${SDK_MACHINE}-${MACHINE}-${PV}.qbsp

    cd ${B}/repository
    7za a ${DEPLOY_DIR}/qbsp/${PN}-${SDK_MACHINE}-${MACHINE}-${PV}.qbsp *
}

python do_qbsp() {
    bb.build.exec_func('create_qbsp', d)
}

addtask qbsp after do_unpack before do_build

do_qbsp[cleandirs] += "${B}"

do_configure[noexec] = "1"
do_compile[noexec] = "1"
do_populate_sysroot[noexec] = "1"
do_populate_lic[noexec] = "1"
