/****************************************************************************
**
** Copyright (C) 2022 The Qt Company Ltd.
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
    var platform = "@NAME@ @TARGET@";
    var sysroot = "@SYSROOT@";
    var target_sys = "@TARGET_SYS@";
    var abi = "@ABI@-linux-poky-elf-@BITS@bit";
    var installPath = "@INSTALLPATH@/toolchain";
    var sdkPath = "@SDKPATH@";
    var sdkFile = "@SDKFILE@";
    var hostSysroot = "@TOOLCHAIN_HOST_SYSROOT@";
    var imageTag = "boot2qt-@MACHINE@:@VERSION@"
    var dockerPrefix = "";

    var container = false;
    if ( "@TOOLCHAIN_HOST_TYPE@" == "linux" && systemInfo.kernelType !== "linux" || @FORCE_CONTAINER_TOOLCHAIN@)
       container = true;

    var path = installer.value("TargetDir") + installPath;
    if (!container) {
        if (systemInfo.kernelType !== "winnt") {
            var script = path + "/" + sdkFile;
            component.addOperation("Execute", "{0}", "sh", script, "-y", "-d", path, "UNDOEXECUTE", "rm", "-rf", path);
            component.addOperation("Execute", "{0}", "/bin/rm", script);
        } else {
            // workaround for QTIFW-2344
            path = path.replace(/\\/g, "/");
        }
    } else {
        component.addOperation("AppendFile", path + "/Dockerfile",
            "\
FROM --platform=linux/@DOCKER_ARCH@ ubuntu:20.04\n\
ENV LANG C.UTF-8\n\
RUN apt-get update && DEBIAN_FRONTEND=\"noninteractive\" apt-get install -y --no-install-recommends python3 xz-utils file make && rm -rf /var/lib/apt/lists/*\n\
COPY *.sh /\n\
RUN sh *.sh -d /opt/toolchain -y && rm *.sh\n");

        component.addOperation("Execute", [
            "docker",
            "build", path,
            "-t", imageTag,
            "errormessage=Installer was unable to run docker. " +
            "Make sure Docker is installed and running before continuing.\n\n" +
            "The toolchain Docker container can also be created manually by running command:\n" +
            "docker build " + path + " -t " + imageTag,
            "UNDOEXECUTE",
            "docker", "image", "rm", "-f", imageTag]);
        path = "/opt/toolchain";
        dockerPrefix = "docker://" + imageTag;
    }

    var toolchainId = "ProjectExplorer.ToolChain.Gcc:" + component.name;
    var executableExt = "";
    if (!container && systemInfo.kernelType === "winnt") {
        executableExt = ".exe";
        toolchainId = "ProjectExplorer.ToolChain.Mingw:" + component.name;
    }

    component.addOperation("Execute", "{0,2}",
        ["@SDKToolBinary@", "addAbiFlavor",
         "--flavor", "poky",
         "--oses", "linux"]);

    component.addOperation("Execute",
        ["@SDKToolBinary@", "addTC",
        "--id", toolchainId + ".gcc",
        "--name", "GCC (" + platform + ")",
        "--path", dockerPrefix + path + "/sysroots/" + hostSysroot + "/usr/bin/" + target_sys + "/" + target_sys + "-gcc" + executableExt,
        "--abi", abi,
        "--language", "C",
        "UNDOEXECUTE",
        "@SDKToolBinary@", "rmTC", "--id", toolchainId + ".gcc"]);

    component.addOperation("Execute",
        ["@SDKToolBinary@", "addTC",
        "--id", toolchainId + ".g++",
        "--name", "G++ (" + platform + ")",
        "--path", dockerPrefix + path + "/sysroots/" + hostSysroot + "/usr/bin/" + target_sys + "/" + target_sys + "-g++" + executableExt,
        "--abi", abi,
        "--language", "Cxx",
        "UNDOEXECUTE",
        "@SDKToolBinary@", "rmTC", "--id", toolchainId + ".g++"]);

    component.addOperation("Execute",
        ["@SDKToolBinary@", "addDebugger",
        "--id", component.name,
        "--name", "GDB (" + platform + ")",
        "--engine", "1",
        "--binary", dockerPrefix + path + "/sysroots/" + hostSysroot + "/usr/bin/" + target_sys + "/" + target_sys + "-gdb" + executableExt,
        "--abis", abi,
        "UNDOEXECUTE",
        "@SDKToolBinary@", "rmDebugger", "--id", component.name]);

    component.addOperation("Execute",
        ["@SDKToolBinary@", "addQt",
         "--id", component.name,
         "--name", platform,
         "--type", "Qdb.EmbeddedLinuxQt",
         "--qmake", dockerPrefix + path + "/sysroots/" + hostSysroot + "/usr/bin/qmake" + executableExt,
         "--abis", abi,
         "UNDOEXECUTE",
         "@SDKToolBinary@", "rmQt", "--id", component.name]);

    component.addOperation("Execute",
        ["@SDKToolBinary@", "addCMake",
        "--id", component.name,
        "--name", "CMake (" + platform + ")",
        "--path", dockerPrefix + path + "/sysroots/" + hostSysroot + "/usr/bin/cmake" + executableExt,
        "UNDOEXECUTE",
        "@SDKToolBinary@", "rmCMake", "--id", component.name]);

    if (container) {
        component.addOperation("Execute",
            ["@SDKToolBinary@", "addDev",
            "--id", component.name,
            "--name", "Docker Image (" + platform + ")",
            "--type", "0",
            "--osType", "DockerDeviceType",
            "--origin", "1",
            "--dockerRepo", "boot2qt-@MACHINE@",
            "--dockerTag", "@VERSION@",
            "--dockerMappedPaths", installer.value("TargetDir"),
            "UNDOEXECUTE",
            "@SDKToolBinary@", "rmDev", "--id", component.name]);
    }

    var addKitOperations =
        ["@SDKToolBinary@", "addKit",
         "--id", component.name,
         "--name", platform,
         "--qt", component.name,
         "--debuggerid", component.name,
         "--sysroot", dockerPrefix + path + "/sysroots/" + sysroot,
         "--devicetype", "QdbLinuxOsType",
         "--Ctoolchain", toolchainId + ".gcc",
         "--Cxxtoolchain", toolchainId + ".g++",
         "--cmake", component.name,
         "--cmake-generator", "Ninja",
         "--cmake-config", "CMAKE_CXX_COMPILER:STRING=%{Compiler:Executable:Cxx}",
         "--cmake-config", "CMAKE_C_COMPILER:STRING=%{Compiler:Executable:C}",
         "--cmake-config", "CMAKE_PREFIX_PATH:STRING=%{Qt:QT_INSTALL_PREFIX}",
         "--cmake-config", "QT_QMAKE_EXECUTABLE:STRING=%{Qt:qmakeExecutable}",
         "--cmake-config", "CMAKE_TOOLCHAIN_FILE:FILEPATH=" + path + "/sysroots/" + hostSysroot + "/usr/lib/cmake/Qt6/qt.toolchain.cmake",
         "--cmake-config", "CMAKE_MAKE_PROGRAM:FILEPATH=" + path + "/sysroots/"+ hostSysroot + "/usr/bin/ninja" + executableExt];

    if (container) {
        addKitOperations.push("--builddevice", component.name);
    }
    if (!container) {
        addKitOperations.push("--mkspec", "linux-oe-g++");
    }

    addKitOperations.push("UNDOEXECUTE", "@SDKToolBinary@", "rmKit", "--id", component.name);
    component.addOperation("Execute", addKitOperations);

    if (container) {
        var settingsFile = installer.value("QtCreatorInstallerSettingsFile");
        component.addOperation("Settings", "path="+settingsFile, "method=add_array_value", "key=Plugins/ForceEnabled", "value=Docker");
    }
}
