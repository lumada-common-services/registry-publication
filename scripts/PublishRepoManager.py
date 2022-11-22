from publishUtils import *
from PublishRepo import *

import json


class ArtifactoryRepoManager():

    data = None

    def __init__(self, data) -> None:
        self.data = data

    def publish(self) -> None:
        artifactsYaml = self.data['artifactsYaml']

        # Connect to Artifactory
        connectToArtifactory(artifactsYaml['repository-manager'])

        for repo, values in artifactsYaml['artifacts'].items():
            repoType = self.getRepoType(repo)
            implCls = None
            data = {**self.data, **{'repoName': repo}}

            if repoType == "docker":
                implCls = DockerPublishRepo(data)

            else:
                implCls = HelmPublishRepo(data)

            implCls.publishArtifacts(values)

        buildInfo(data['buildName'], data['buildNumber'], data['workspace'])

    def getRepoType(self, repoName) -> str:
        responseJson = runCommand(
            "jfrog rt curl /api/repositories/" + repoName + " -s")

        return json.loads(responseJson)['packageType']
