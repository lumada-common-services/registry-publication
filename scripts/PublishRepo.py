from abc import ABC, abstractmethod
from publishUtils import *

import re


class ArtifactoryRepo(ABC):

    @abstractmethod
    def __init__(self, data) -> None:
        pass

    @abstractmethod
    def publishArtifacts(self, values):
        pass


class DockerPublishRepo(ArtifactoryRepo):

    data = None

    def __init__(self, data) -> None:
        self.data = data

    def publishArtifacts(self, values):
        version = self.data['version']
        buildName = self.data['buildName']
        buildNumber = self.data['buildNumber']
        repoName = self.data['repoName']
        dockerRegistry = repoName + "." + \
            self.data['artifactsYaml']['docker-base-url']

        for item in values:
            imageName = ""
            if 'name' in item:
                imageName = item['name']

            if imageName != "":
                imageName = imageName.replace("<VERSION>", version)
                runCommand("jfrog docker push " + dockerRegistry + "/" + imageName +
                           " --build-name " + buildName + " --build-number " + buildNumber)
                setProps(item, dockerRegistry + "/" + imageName)


class HelmPublishRepo(ArtifactoryRepo):

    data = None

    def __init__(self, data) -> None:
        self.data = data

    def publishArtifacts(self, values):
        version = self.data['version']
        buildName = self.data['buildName']
        buildNumber = self.data['buildNumber']
        repoName = self.data['repoName']
        artifactsYaml = self.data['artifactsYaml']

        rootDir = self.data['workspace']
        includePattern = artifactsYaml['search-patterns']['include']
        excludePattern = artifactsYaml['search-patterns']['exclude']

        dirIncludeRegex = re.compile(includePattern)
        dirExcludeRegex = re.compile(excludePattern)

        for item in values:
            fileName = item['name'].replace("<VERSION>", version)
            regex = re.compile(fileName, re.IGNORECASE)

            # search for the files
            self.findAndUploadFiles(item, repoName, regex, dirIncludeRegex,
                                    dirExcludeRegex, rootDir, buildName, buildNumber)

    def findAndUploadFiles(self, item, repoName, regex, dirIncludeRegex, dirExcludeRegex, rootDir, buildName, buildNumber) -> None:

        for currentDir, subFolders, files in os.walk(rootDir):

            if not dirIncludeRegex.match(currentDir) or dirExcludeRegex.match(currentDir):
                continue

            for fileFound in files:

                if regex.match(fileFound):
                    fullFilePath = os.path.join(currentDir, fileFound)
                    remoteFile = repoName + "/" + fileFound
                    runCommand("jfrog rt upload " + fullFilePath + " " + remoteFile +
                               " --build-name " + buildName + " --build-number " + buildNumber)
                    setProps(item, remoteFile)
