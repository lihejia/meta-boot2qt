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

IMAGE_FSTYPES += "wic.xz"

DEPLOY_CONF_IMAGE_TYPE = "wic.xz"

QBSP_IMAGE_CONTENT += "\
    ${IMAGE_LINK_NAME}.${DEPLOY_CONF_IMAGE_TYPE} \
    ${IMAGE_LINK_NAME}.conf \
    ${IMAGE_LINK_NAME}.info \
    "

QBSP_LICENSE_FILE ?= "${FSL_EULA_FILE}"
QBSP_LICENSE_NAME ?= "NXP Semiconductors Software License Agreement"

# Use gstreamer from meta-freescale
PREFERRED_VERSION_gstreamer1.0:use-nxp-bsp              ?= "1.20.0.imx"
PREFERRED_VERSION_gstreamer1.0-plugins-base:use-nxp-bsp ?= "1.20.0.imx"
PREFERRED_VERSION_gstreamer1.0-plugins-good:use-nxp-bsp ?= "1.20.0.imx"
PREFERRED_VERSION_gstreamer1.0-plugins-bad:use-nxp-bsp  ?= "1.20.0.imx"
PREFERRED_VERSION_gstreamer1.0-libav:use-nxp-bsp        ?= "1.20.0"
PREFERRED_VERSION_gstreamer1.0-rtsp-server:use-nxp-bsp  ?= "1.20.0"

MACHINE_GSTREAMER_1_0_PLUGIN:append:imxgpu = " imx-gst1.0-plugin"

GPULESS_FEATURES = "wayland opengl vulkan webengine"
DISTRO_FEATURES:remove:mx6ul-generic-bsp = "${GPULESS_FEATURES}"
DISTRO_FEATURES:remove:mx7-generic-bsp = "${GPULESS_FEATURES}"

BBMASK += "meta-freescale/dynamic-layers/qt6-layer/recipes-qt/qt6"