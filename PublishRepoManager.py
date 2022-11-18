from publishUtils import *
from PublishRepo import *

import json


class ArtifactoryRepoManager():

    data = None

    def __init__(self, data) -> None:
        self.data = data

    def publishArtifacts(self):
        artifactsYaml = self.data['artifactsYaml']

        for repo, values in artifactsYaml['artifacts'].items():
            repoType = self.getRepoType(repo)
            implCls = None
            data = {**self.data, **{'repoName': repo}}

            if repoType == "docker":
                implCls = DockerPublishRepo(data)

            else:
                implCls = HelmPublishRepo(data)

            implCls.publishArtifacts(values)

    def getRepoType(self, repoName) -> str:
        responseJson = runCommand(
            "jfrog rt curl /api/repositories/" + repoName + " -s")

        return json.loads(responseJson)['packageType']
