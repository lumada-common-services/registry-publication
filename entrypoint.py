#!/usr/bin/env python

import os
import yaml
import sys
from PublishRepoManager import ArtifactoryRepoManager

INPUT_ARTIFACTS_CONFIG_FILE = sys.argv[1]
INPUT_WORKSPACE = sys.argv[2]
INPUT_BUILD_VERSION = sys.argv[3]
INPUT_BUILD_NAME = sys.argv[4]
INPUT_BUILD_NUMBER = sys.argv[5]

with open(INPUT_ARTIFACTS_CONFIG_FILE, 'r') as stream:
    artifactsYaml = yaml.safe_load(stream)

ArtifactoryRepoManager({"version": INPUT_BUILD_VERSION,
                        "buildName": INPUT_BUILD_NAME,
                        "buildNumber": INPUT_BUILD_NUMBER,
                        "workspace": INPUT_WORKSPACE,
                        "artifactsYaml": artifactsYaml}).publishArtifacts()
