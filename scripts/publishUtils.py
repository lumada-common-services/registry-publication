#!/usr/bin/env python

import os
import subprocess
import shlex


def connectToArtifactory(url):
    print(
        runCommand(
            "jfrog config add artifactory --interactive=false --enc-password=false --basic-auth-only --artifactory-url " +
            url + " --password " + str(os.getenv('INPUT_ARTIFACTORY_APIKEY')) +
            " --user " + str(os.getenv('INPUT_ARTIFACTORY_USER'))
        )
    )

    print(
        runCommand("jfrog rt ping")
    )


def runCommand(cmdStr):
    cmd = shlex.split(cmdStr)

    process = subprocess.Popen(cmd,
                               stdout=subprocess.PIPE,
                               stderr=subprocess.PIPE,
                               universal_newlines=True)

    print("* Running '" + cmdStr + "'")

    stdout, stderr = process.communicate()

    if str(stderr) != "":
        print(str(stderr))
        if "[Error]" in str(stderr):
            raise Exception()

    return str(stdout)


def buildInfo(buildName, buildNumber, workspace):
    # collect ENV variables for build-info
    print(runCommand("jfrog rt build-collect-env " + buildName + " " + buildNumber))

    # Collect git info from checkout dir
    print(runCommand("jfrog rt build-add-git " + buildName +
                     " " + buildNumber + " " + workspace))

    # Publish build-info
    print(runCommand("jfrog rt build-publish " + buildName + " " + buildNumber))


def getProps(itemData) -> str:
    return ";".join("=".join([key, str(itemData.get(key))])
                    for key in itemData.keys())


def setProps(itemData, filePath):
    runCommand("jfrog rt set-props " + filePath + " " + getProps(itemData))
