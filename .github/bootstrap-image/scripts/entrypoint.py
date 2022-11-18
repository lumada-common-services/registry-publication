#!/usr/bin/env python

import os
import yaml
import sys
from PublishRepoManager import ArtifactoryRepoManager

with open(os.getenv('INPUT_ARTIFACTS_CONFIG_FILE'), 'r') as stream:
    artifactsYaml = yaml.safe_load(stream)

data = {"version": os.getenv('INPUT_BUILD_VERSION'),
        "buildName": os.getenv('INPUT_BUILD_NAME'),
        "buildNumber": os.getenv('INPUT_BUILD_NUMBER'),
        "workspace": os.getenv('INPUT_WORKSPACE'),
        "artifactsYaml": artifactsYaml}

print(data)

ArtifactoryRepoManager(data).publish()
