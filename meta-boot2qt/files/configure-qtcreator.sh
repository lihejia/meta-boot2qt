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

set -e

ABI="arm-linux-poky-elf-32bit"
CONFIG=""

printUsage ()
{
    echo "Usage: $0 --config <environment-setup-file> [--remove] [--qtcreator <path>] [--name <basename>]"
}

while test -n "$1"; do
  case "$1" in
    "--remove")
      REMOVEONLY=1
      ;;
    "--qtcreator")
      shift
      QTCREATOR=$1
      ;;
    "--config")
      shift
      CONFIG=$1
      ;;
    "--name")
      shift
      NAME=$1
      ;;
    *)
      printUsage
      exit 0
      ;;
  esac
  shift
done

if [ ! -f "$CONFIG" ]; then
   printUsage
   exit 1
fi

if [ -z "${QTCREATOR}" ]; then
    SDKTOOL="${HOME}/Qt/Tools/QtCreator/libexec/qtcreator/sdktool"
else
    SDKTOOL="${QTCREATOR}/libexec/qtcreator/sdktool"
fi
if [ ! -x ${SDKTOOL} ]; then
    echo "Cannot find 'sdktool' from QtCreator"
    printUsage
    exit 1
fi

source $CONFIG

MKSPEC="devices/linux-oe-generic-g++"
MKSPECPATH=$(find ${OECORE_TARGET_SYSROOT} -name $(basename ${MKSPEC}) 2>/dev/null || true)
if [ ! -d "${MKSPECPATH}" ]; then
    echo "Error: could not find mkspec ${MKSPEC} from the toolchain"
    exit 1
fi

MACHINE=$(grep '^MACHINE' ${MKSPECPATH}/../../qdevice.pri | cut -d'=' -f2 | tr -d ' ')

RELEASE=$(qmake -query QT_VERSION)

NAME=${NAME:-"Custom Qt ${RELEASE} ${MACHINE}"}
BASEID="byos.${RELEASE}.${MACHINE}"

${SDKTOOL} rmKit --id ${BASEID}.kit 2>/dev/null || true
${SDKTOOL} rmQt --id ${BASEID}.qt || true
${SDKTOOL} rmTC --id ProjectExplorer.ToolChain.Gcc:${BASEID}.gcc || true
${SDKTOOL} rmTC --id ProjectExplorer.ToolChain.Gcc:${BASEID}.g++ || true
${SDKTOOL} rmDebugger --id ${BASEID}.gdb 2>/dev/null || true
${SDKTOOL} rmCMake --id ${BASEID}.cmake 2>/dev/null || true

if [ -n "${REMOVEONLY}" ]; then
    echo "Kit removed: ${NAME}"
    exit 0
fi

${SDKTOOL} addAbiFlavor \
    --flavor poky \
    --oses linux || true

${SDKTOOL} addTC \
    --id "ProjectExplorer.ToolChain.Gcc:${BASEID}.gcc" \
    --name "GCC (${NAME})" \
    --path "$(type -p ${CC})" \
    --abi "${ABI}" \
    --language C

${SDKTOOL} addTC \
    --id "ProjectExplorer.ToolChain.Gcc:${BASEID}.g++" \
    --name "G++ (${NAME})" \
    --path "$(type -p ${CXX})" \
    --abi "${ABI}" \
    --language Cxx

${SDKTOOL} addDebugger \
    --id "${BASEID}.gdb" \
    --name "GDB (${NAME})" \
    --engine 1 \
    --binary "$(type -p ${GDB})" \
    --abis "${ABI}"

${SDKTOOL} addQt \
    --id "${BASEID}.qt" \
    --name "${NAME}" \
    --type "Qdb.EmbeddedLinuxQt" \
    --qmake "$(type -p qmake)"

${SDKTOOL} addCMake \
    --id "${BASEID}.cmake" \
    --name "CMake ${NAME}" \
    --path "$(type -p cmake)"

${SDKTOOL} addKit \
    --id "${BASEID}.kit" \
    --name "${NAME}" \
    --qt "${BASEID}.qt" \
    --debuggerid "${BASEID}.gdb" \
    --sysroot "${SDKTARGETSYSROOT}" \
    --devicetype "QdbLinuxOsType" \
    --Ctoolchain "ProjectExplorer.ToolChain.Gcc:${BASEID}.gcc" \
    --Cxxtoolchain "ProjectExplorer.ToolChain.Gcc:${BASEID}.g++" \
    --icon ":/boot2qt/images/B2Qt_QtC_icon.png" \
    --mkspec "${MKSPEC}" \
    --cmake "${BASEID}.cmake" \
    --cmake-config "CMAKE_TOOLCHAIN_FILE:FILEPATH=${OECORE_NATIVE_SYSROOT}/usr/share/cmake/OEToolchainConfig.cmake" \
    --cmake-config "CMAKE_MAKE_PROGRAM:FILEPATH=$(type -p make)" \
    --cmake-config "CMAKE_CXX_COMPILER:FILEPATH=$(type -p ${CXX})" \
    --cmake-config "CMAKE_C_COMPILER:FILEPATH=$(type -p ${CC})"

echo "Configured Qt Creator with new kit: ${NAME}"
