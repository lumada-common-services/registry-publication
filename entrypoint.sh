#!/bin/bash

set -eo pipefail

source utils.sh

ARTIFACTORY_URL=$(yq '.repository-manager' ${INPUT_ARTIFACTS_CONFIG_FILE})

jfrog config add artifactory --interactive=false --enc-password=true \
  --artifactory-url ${ARTIFACTORY_URL} \
  --apikey ${INPUT_ARTIFACTORY_APIKEY} \
  --user ${INPUT_ARTIFACTORY_USER}

export JFROG_CLI_BUILD_URL="$INPUT_BUILD_URL"

# Dealing with the artifacts
ARTIFACTS=$(yq '.artifacts | keys' ${INPUT_ARTIFACTS_CONFIG_FILE})
for artifact_repo in ${ARTIFACTS};
do

  if [ "$artifact_repo" == "-" ]; then
    continue
  fi

  repo_type=$(jfrog rt curl /api/repositories/${artifact_repo} -s | jq -r .packageType)
  artifact_structure=".artifacts.${artifact_repo}[]"

  files=$(yq -o=j -I=0 "${artifact_structure}" ${INPUT_ARTIFACTS_CONFIG_FILE})

  if [ "${repo_type}" == "docker" ]; then

    docker_repo="${artifact_repo}"

    docker_base_url=$(yq '.docker-base-url' ${INPUT_ARTIFACTS_CONFIG_FILE})
    docker_registry="${docker_repo}.${docker_base_url}"

    dockerPush "${files}" \
               "${INPUT_BUILD_VERSION}" \
               "${docker_repo}" \
               "${docker_registry}" \
               "${INPUT_BUILD_NAME}" \
               "${INPUT_BUILD_NUMBER}"

  else
    search_include_pattern=$(yq '.search-patterns.include' ${INPUT_ARTIFACTS_CONFIG_FILE})
    search_exclude_pattern=$(yq '.search-patterns.exclude' ${INPUT_ARTIFACTS_CONFIG_FILE})

    uploadFiles "${artifact_repo}" \
                "${files}" \
                "${INPUT_BUILD_VERSION}" \
                "${search_include_pattern}" \
                "${search_exclude_pattern}" \
                "${INPUT_WORKSPACE}" \
                "${INPUT_BUILD_NAME}" \
                "${INPUT_BUILD_NUMBER}"
  fi

done

# collect ENV variables for build-info
jfrog rt build-collect-env ${INPUT_BUILD_NAME} ${INPUT_BUILD_NUMBER}

# Collect git info from checkout dir
jfrog rt build-add-git ${INPUT_BUILD_NAME} ${INPUT_BUILD_NUMBER} ${INPUT_WORKSPACE}

# Publish build-info
jfrog rt build-publish ${INPUT_BUILD_NAME} ${INPUT_BUILD_NUMBER}
