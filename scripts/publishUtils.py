#!/usr/bin/env python

import os
import subprocess
import shlex


def connectToArtifactory(url):

    print(
        runCommand(
            "jfrog config add artifactory --interactive=false --enc-password=true --artifactory-url " + url + " --password " +
            str(os.getenv('INPUT_ARTIFACTORY_APIKEY')) +
            " --user " + str(os.getenv('INPUT_ARTIFACTORY_USER'))
        )
    )


def runCommand(cmdStr):
    cmd = shlex.split(cmdStr)

    process = subprocess.Popen(cmd,
                               stdout=subprocess.PIPE,
                               stderr=subprocess.PIPE,
                               universal_newlines=True)

    stdout, stderr = process.communicate()

    print("* Running '" + cmdStr + "'")

    # TODO remeber to check why warnings are going into the stderr
    #if str(stderr) != "":
    #    raise Exception(str(stderr))

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
