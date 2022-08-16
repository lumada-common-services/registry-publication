#!/bin/sh

set -eo pipefail

jfrog config add artifactory --interactive=false --enc-password=true \
  --artifactory-url ${INPUT_ARTIFACTORY_URL} \
  --apikey ${INPUT_ARTIFACTORY_APIKEY} \
  --user ${INPUT_ARTIFACTORY_USER}

# Taking care of the docker images
for image in ${INPUT_IMAGES}; do

  jfrog rt dp $image ${INPUT_ARTIFACTORY_DOCKER_REPO} \
    --build-name ${INPUT_BUILD_NAME} \
    --build-number ${INPUT_BUILD_NUMBER}

done

# Taking care of the helm charts
for chart in ${INPUT_HELM_CHARTS}; do
  if [ -e $chart ]
  then
    jfrog rt u $chart ${INPUT_ARTIFACTORY_HELM_REPO} \
      --build-name ${INPUT_BUILD_NAME} \
      --build-number ${INPUT_BUILD_NUMBER}

  else
      echo "Could not find '$chart'. Not adding..."

  fi
done

# collect ENV variables for build-info
jfrog rt bce ${INPUT_BUILD_NAME} ${INPUT_BUILD_NUMBER}

ls -la ${INPUT_WORKSPACE}

# Collect git info from checkout dir
jfrog rt bag ${INPUT_BUILD_NAME} ${INPUT_BUILD_NUMBER} ${INPUT_WORKSPACE}

# Add artifacts as build dependencies ?
#jfrog rt bad ${INPUT_BUILD_NAME} ${INPUT_BUILD_NUMBER} "${INPUT_ARTIFACTORY_HELM_REPO}/dependencies/" --from-rt

# Publish build-info
jfrog rt bp ${INPUT_BUILD_NAME} ${INPUT_BUILD_NUMBER}

SUCCESS=$(jfrog rt ping)

# temporary
# tail -f /dev/null
