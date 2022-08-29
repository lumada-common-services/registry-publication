#!/bin/bash

set -eo pipefail

function createArtifactsMap() {
  local files=$1
  local build_version=$2

  declare -A propsMap

  for file in ${files}; do
    file_name=$(echo ${file} | yq e '.name')
    file_name=$(echo ${file_name} | sed -e "s/<VERSION>/${build_version}/g")

    props=""
    file_keys=$(echo ${file} | yq e ' keys')

    for file_key in ${file_keys};
    do

      if [ "$file_key" == "-" ]; then
        continue
      fi
      key_value=$(echo "${file}" | yq e ".$file_key")
      props="$props$file_key=$key_value;"
    done
    # removes the last ';'
    props=$(echo ${props} | sed 's/.$//')
    propsMap["$file_name"]="$props"

  done

  echo '('
    for key in  "${!propsMap[@]}" ; do
        echo "['$key']='${propsMap[$key]}'"
    done
  echo ')'
}

function dockerPush() {
  images_list=$1
  build_version=$2
  docker_repo=$3
  docker_registry=$4
  build_name=$5
  build_number=$6

  declare -A propsMap=$(createArtifactsMap "$files" "$build_version")

  for image in ${images_list};
  do
    image_name=$(echo ${image} | yq e '.name')
    for_release=$(echo ${image} | yq e '.for-release')

    image_name=$(echo ${image_name} | sed -e "s/<VERSION>/${build_version}/g")

    jfrog rt docker-push ${docker_registry}/${image_name} ${docker_repo} \
      --build-name ${build_name} \
      --build-number ${build_number}

    props=${propsMap[$image_name]}
    props=$(echo "$props" | tr -d '"')

    image_name=$(echo ${image_name} | sed -e "s/:/\//g")
    echo "jfrog rt set-props \"${docker_repo}/${image_name}/\" \"${props}\""

    jfrog rt set-props "${docker_repo}/${image_name}/" "${props}" # --build="${build_name}/${build_number}"

  done
}

function uploadFiles() {
  remote_repo=$1
  files=$2
  build_version=$3
  search_include_pattern=$4
  search_exclude_pattern=$5
  workspace=$6
  build_name=$7
  build_number=$8

  declare -A propsMap=$(createArtifactsMap "$files" "$build_version")

  find_search_include_pattern=""
  for file in ${files}; do
    file_name=$(echo ${file} | yq e '.name')
    file_name=$(echo ${file_name} | sed -e "s/<VERSION>/${build_version}/g")

    find_search_include_pattern="${find_search_include_pattern}(${search_include_pattern}${file_name})|"
  done

  # removes the last '|'
  find_search_include_pattern=$(echo ${find_search_include_pattern} | sed 's/.$//')

  found_files=$(find "${workspace}" -regextype 'posix-extended' -not -regex "${search_exclude_pattern}" -regex "${find_search_include_pattern}")

  for found_file in ${found_files}; do
    if [ -e $found_file ]
    then

      jfrog rt upload "${found_file}" "${remote_repo}" \
        --build-name "${build_name}" \
        --build-number "${build_number}"

      # extra props defined in the yaml item
      file_name=$(basename "${found_file}")
      remote_file="${remote_repo}/${file_name}"

      props=${propsMap[$file_name]}
      props=$(echo "$props" | tr -d '"')

      jfrog rt set-props "${remote_file}" "${props}" # --build="${build_name}/${build_number}"

    else
        echo "Could not find '$found_file'. Not adding..."

    fi
  done

}
