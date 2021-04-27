/****************************************************************************
**
** Copyright (C) 2018 The Qt Company Ltd.
** Contact: https://www.qt.io/licensing/
**
** This file is part of the Boot to Qt meta layer.
**
** $QT_BEGIN_LICENSE:GPL$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see https://www.qt.io/terms-conditions. For further
** information use the contact form at https://www.qt.io/contact-us.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 3 or (at your option) any later version
** approved by the KDE Free Qt Foundation. The licenses are as published by
** the Free Software Foundation and appearing in the file LICENSE.GPL3
** included in the packaging of this file. Please review the following
** information to ensure the GNU General Public License requirements will
** be met: https://www.gnu.org/licenses/gpl-3.0.html.
**
** $QT_END_LICENSE$
**
****************************************************************************/

function Component()
{
}

Component.prototype.createOperations = function()
{
    component.createOperations();

    var device = "@MACHINE@";
    var platform = "@NAME@";
    var sysroot = "@SYSROOT@";
    var target_sys = "@TARGET_SYS@";
    var target = "@TARGET@";
    var abi = "@ABI@-linux-poky-elf-@BITS@bit";
    var installPath = "@INSTALLPATH@/toolchain";
    var sdkPath = "@SDKPATH@";
    var sdkFile = "@SDKFILE@";
    var hostSysroot = "@TOOLCHAIN_HOST_SYSROOT@";

    var path = installer.value("TargetDir") + installPath;
    if (systemInfo.kernelType !== "winnt") {
        var script = path + "/" + sdkFile;
        component.addOperation("Execute", "{0}", "chmod", "+x", script);
        component.addOperation("Execute", "{0}", script, "-y", "-d", path, "UNDOEXECUTE", "rm", "-rf", path);
        component.addOperation("Execute", "{0}", "/bin/rm", script);
    } else {
        path = path.replace(/\\/g,"/");
        component.addOperation("Replace",
                                path + "/sysroots/" + hostSysroot + "/usr/bin/qt.conf",
                                sdkPath, path);
        component.addOperation("Replace",
                                path + "/sysroots/" + hostSysroot + "/usr/share/cmake/OEToolchainConfig.cmake.d/" + device + ".cmake",
                                sdkPath, path);
    }
    var basecomponent = component.name.substring(0, component.name.lastIndexOf("."));
    var toolchainId = "ProjectExplorer.ToolChain.Gcc:" + component.name;
    var debuggerId = basecomponent + ".gdb";
    var qtId = basecomponent + ".qt";
    var cmakeId = basecomponent + ".cmake";
    var cmakeGenerator = "Unix Makefiles";
    var icon = installer.value("B2QtDeviceIcon");
    var executableExt = "";
    if (systemInfo.kernelType === "winnt") {
        executableExt = ".exe";
        toolchainId = "ProjectExplorer.ToolChain.Mingw:" + component.name;
        cmakeGenerator = "MinGW Makefiles";
    }

    component.addOperation("Execute", "{0,2}",
        ["@SDKToolBinary@", "addAbiFlavor",
         "--flavor", "poky",
         "--oses", "linux"]);

    component.addOperation("Execute",
        ["@SDKToolBinary@", "addTC",
        "--id", toolchainId + ".gcc",
        "--name", "GCC (" + platform + " " + target + ")",
        "--path", path + "/sysroots/" + hostSysroot + "/usr/bin/" + target_sys + "/" + target_sys + "-gcc" + executableExt,
        "--abi", abi,
        "--language", "C",
        "UNDOEXECUTE",
        "@SDKToolBinary@", "rmTC", "--id", toolchainId + ".gcc"]);

    component.addOperation("Execute",
        ["@SDKToolBinary@", "addTC",
        "--id", toolchainId + ".g++",
        "--name", "G++ (" + platform + " " + target + ")",
        "--path", path + "/sysroots/" + hostSysroot + "/usr/bin/" + target_sys + "/" + target_sys + "-g++" + executableExt,
        "--abi", abi,
        "--language", "Cxx",
        "UNDOEXECUTE",
        "@SDKToolBinary@", "rmTC", "--id", toolchainId + ".g++"]);

    component.addOperation("Execute",
        ["@SDKToolBinary@", "addDebugger",
        "--id", debuggerId,
        "--name", "GDB (" + platform + " " + target + ")",
        "--engine", "1",
        "--binary", path + "/sysroots/" + hostSysroot + "/usr/bin/" + target_sys + "/" + target_sys + "-gdb" + executableExt,
        "--abis", abi,
        "UNDOEXECUTE",
        "@SDKToolBinary@", "rmDebugger", "--id", debuggerId]);

    component.addOperation("Execute",
        ["@SDKToolBinary@", "addQt",
         "--id", qtId,
         "--name", platform + " " + target,
         "--type", "Qdb.EmbeddedLinuxQt",
         "--qmake", path + "/sysroots/" + hostSysroot + "/usr/bin/qmake" + executableExt,
         "--abis", abi,
         "UNDOEXECUTE",
         "@SDKToolBinary@", "rmQt", "--id", qtId]);

    component.addOperation("Execute",
        ["@SDKToolBinary@", "addCMake",
        "--id", cmakeId,
        "--name", "CMake (" + platform + " " + target + ")",
        "--path", path + "/sysroots/" + hostSysroot + "/usr/bin/cmake" + executableExt,
        "UNDOEXECUTE",
        "@SDKToolBinary@", "rmCMake", "--id", cmakeId]);

    component.addOperation("Execute",
        ["@SDKToolBinary@", "addKit",
         "--id", basecomponent,
         "--name", platform + " " + target,
         "--mkspec", "devices/linux-oe-generic-g++",
         "--qt", qtId,
         "--debuggerid", debuggerId,
         "--sysroot", path + "/sysroots/" + sysroot,
         "--devicetype", "QdbLinuxOsType",
         "--Ctoolchain", toolchainId + ".gcc",
         "--Cxxtoolchain", toolchainId + ".g++",
         "--icon", icon,
         "--cmake", cmakeId,
         "--cmake-generator", cmakeGenerator,
         "--cmake-config", "CMAKE_TOOLCHAIN_FILE:FILEPATH=" + path + "/sysroots/" + hostSysroot + "/usr/share/cmake/OEToolchainConfig.cmake",
         "--cmake-config", "CMAKE_MAKE_PROGRAM:FILEPATH=" + path + "/sysroots/" + hostSysroot + "/usr/bin/make" + executableExt,
         "--cmake-config", "CMAKE_CXX_COMPILER:FILEPATH=" + path + "/sysroots/" + hostSysroot + "/usr/bin/" + target_sys + "/" + target_sys + "-g++" + executableExt,
         "--cmake-config", "CMAKE_C_COMPILER:FILEPATH=" + path + "/sysroots/" + hostSysroot + "/usr/bin/" + target_sys + "/" + target_sys + "-gcc" + executableExt,
         "UNDOEXECUTE",
         "@SDKToolBinary@", "rmKit", "--id", basecomponent]);
}
