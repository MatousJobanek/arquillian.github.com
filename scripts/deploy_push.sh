#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ ${TRAVIS} = "true" ]]; then
    if [[ ${TRAVIS_BRANCH} = "develop" ]]; then
        if [[ ${TRAVIS_PULL_REQUEST} != "false" ]]; then
            echo "=> The pages won't be deployed - it is a build for pull request"
            exit 0;
        fi
    else
        echo "=> The pages won't be deployed - the targeted branch is not \"develop\""
        exit 0;
    fi
fi

CURRENT_BRANCH=`git branch | grep \* | cut -d ' ' -f2`
echo "params ${1} ${2}"
ARQUILLIAN_PROJECT_DIR=${1}
DOCKER_SCRIPTS_LOCATION=${2}

git --git-dir=${ARQUILLIAN_PROJECT_DIR}/.git --work-tree=${ARQUILLIAN_PROJECT_DIR} checkout master
git --git-dir=${ARQUILLIAN_PROJECT_DIR}/.git --work-tree=${ARQUILLIAN_PROJECT_DIR} pull origin master
git --git-dir=${ARQUILLIAN_PROJECT_DIR}/.git --work-tree=${ARQUILLIAN_PROJECT_DIR} checkout ${CURRENT_BRANCH}

docker exec -it arquillian-blog ${DOCKER_SCRIPTS_LOCATION}/deploy.sh

echo "=> Killing and removing arquillian-blog container..."
docker kill arquillian-blog
docker rm arquillian-blog

echo "=> Pushing generated pages to master..."
git --git-dir=${ARQUILLIAN_PROJECT_DIR}/.git --work-tree=${ARQUILLIAN_PROJECT_DIR} push origin master
echo "=> Changing to branch ${CURRENT_BRANCH}..."
git --git-dir=${ARQUILLIAN_PROJECT_DIR}/.git --work-tree=${ARQUILLIAN_PROJECT_DIR} checkout ${CURRENT_BRANCH}
