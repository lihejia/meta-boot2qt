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

IMAGE_CMD:teziimg:append() {
    ${IMAGE_CMD_TAR} --transform 's,^,${IMAGE_NAME}-Tezi_${TEZI_VERSION}/,' -rhf ${IMGDEPLOYDIR}/${IMAGE_NAME}-Tezi_${TEZI_VERSION}.tar TEZI_B2QT_EULA.TXT Built_with_Qt.png
    ln -fs ${TEZI_IMAGE_NAME}-Tezi_${TEZI_VERSION}.tar ${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}.tezi.tar
}

def rootfs_tezi_json_b2qt(d, flash_type, flash_data, json_file, uenv_file):
    import json
    from collections import OrderedDict
    from datetime import datetime

    qtversion = d.getVar('QT_VERSION')
    deploydir = d.getVar('DEPLOY_DIR_IMAGE')
    data = OrderedDict({ "config_format": d.getVar('TEZI_CONFIG_FORMAT'), "autoinstall": False })

    # Use image recipes SUMMARY/DESCRIPTION...
    data["name"] = d.getVar('SUMMARY')
    data["description"] = d.getVar('DESCRIPTION')
    data["version"] = "Qt " + qtversion
    data["release_date"] = datetime.strptime(d.getVar('DATE', False), '%Y%m%d').date().isoformat()
    data["u_boot_env"] = uenv_file
    if os.path.exists(os.path.join(deploydir, "prepare.sh")):
        data["prepare_script"] = "prepare.sh"
    if os.path.exists(os.path.join(deploydir, "wrapup.sh")):
        data["wrapup_script"] = "wrapup.sh"
    if os.path.exists(os.path.join(deploydir, "marketing.tar")):
        data["marketing"] = "marketing.tar"
    data["license_title"] = "QT DEMO IMAGE END USER LICENSE AGREEMENT"
    data["license"] = "TEZI_B2QT_EULA.TXT"
    data["icon"] = "Built_with_Qt.png"

    product_ids = d.getVar('TORADEX_PRODUCT_IDS')
    if product_ids is None:
        bb.fatal("Supported Toradex product ids missing, assign TORADEX_PRODUCT_IDS with a list of product ids.")

    dtmapping = d.getVarFlags('TORADEX_PRODUCT_IDS')
    data["supported_product_ids"] = []

    # If no varflags are set, we assume all product ids supported with single image/U-Boot
    if dtmapping is not None:
        for f, v in dtmapping.items():
            dtbflashtypearr = v.split(',')
            if len(dtbflashtypearr) < 2 or dtbflashtypearr[1] == flash_type:
                data["supported_product_ids"].append(f)
    else:
        data["supported_product_ids"].extend(product_ids.split())

    if flash_type == "rawnand":
        data["mtddevs"] = flash_data
    elif flash_type == "emmc":
        data["blockdevs"] = flash_data

    with open(os.path.join(d.getVar('IMGDEPLOYDIR'), json_file), 'w') as outfile:
        json.dump(data, outfile, indent=4)
    bb.note("Toradex Easy Installer metadata file {0} written.".format(json_file))

python rootfs_tezi_run_json:append() {
    # rewrite image.json with our data
    rootfs_tezi_json_b2qt(d, flash_type, flash_data, "image-%s.json" % d.getVar('IMAGE_BASENAME'), uenv_file)
}
