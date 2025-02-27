#!/bin/sh

set -e

if [ -n "${DEBUG}" ]; then
    set -x
fi

TMP_DIR=$(mktemp -d)
if [ ! "${TMP_DIR}" ] || [ ! -d "${TMP_DIR}" ]; then
    echo "error: failed to create tmp dir"
    exit 1
fi

cleanup() {      
    rm -rf "${TMP_DIR}"
}

update() {
    wget -O "${TMP_DIR}/manifest.json" "https://raw.githubusercontent.com/briandowns/tools/master/manifest.json"
    cat "${TMP_DIR}/manifest.json"
}

download() {
    repo=$1
    tag=$2

    for file in $(jq -r -c '.libspinner.files[]' < manifest.json); do
        if [ -n "${DEBUG}" ]; then
            wget --verbose -O "${file}" "https://raw.githubusercontent.com/briandowns/${repo}/${tag}/${file}"
        else
            wget -q -O "${file}" "https://raw.githubusercontent.com/briandowns/${repo}/${tag}/${file}"
        fi
    done
}

trap cleanup EXIT

if [ "$1" = "" ]; then
    echo "error: repository required"
    exit 1
fi

REPO=$1
TAG="master"

if [ "$2" != "" ]; then
    TAG=$2
fi 

update
download "${REPO}" "${TAG}"

exit 0
