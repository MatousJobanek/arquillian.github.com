#!/bin/bash

######################### Load & set variables #########################

WORKING_DIR=${1}
. ${WORKING_DIR}/variables


######################### Deploy & push #########################

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


VARIABLE_TO_SET_GH_PATH="--git-dir=${ARQUILLIAN_PROJECT_DIR}/.git --work-tree=${ARQUILLIAN_PROJECT_DIR}"
GH_AUTH_REF=`git ${VARIABLE_TO_SET_GH_PATH} remote get-url origin | awk "{sub(/https:\/\//,\"https://${GITHUB_AUTH}@\")}; 1" | awk "{sub(/\.git$/, \"\")} 1"`
GIT_PROJECT=`git ${VARIABLE_TO_SET_GH_PATH} remote get-url origin | awk "{sub(/\.git$/, \"\")} 1"`

LAST_COMMIT=`git ls-remote ${GIT_PROJECT} master | awk '{print $1;}'`
CURRENT_BRANCH=`git rev-parse --abbrev-ref HEAD`

git ${VARIABLE_TO_SET_GH_PATH} pull --all

echo "=> retrieving master branch"
if [[ ${TRAVIS} = "true" ]]; then
    CURRENT_BRANCH=`git status | grep HEAD | awk '{print $4}'`
    git ${VARIABLE_TO_SET_GH_PATH} config remote.origin.fetch +refs/heads/*:refs/remotes/origin/*
    git ${VARIABLE_TO_SET_GH_PATH} fetch --unshallow origin master
else
    git ${VARIABLE_TO_SET_GH_PATH} fetch origin
fi

git ${VARIABLE_TO_SET_GH_PATH} checkout master
git ${VARIABLE_TO_SET_GH_PATH} pull -f origin master
git ${VARIABLE_TO_SET_GH_PATH} checkout ${CURRENT_BRANCH}

echo "=> Running deploy script"
docker exec -it arquillian-org ${DOCKER_SCRIPTS_LOCATION}/deploy.sh





echo "=> creating timestamp"
TIMESTAMP=`date --rfc-3339=seconds`
echo "#!/bin/bash
bash --login <<EOF

cd ${ARQUILLIAN_PROJECT_DIR_NAME}

touch ./last_update.txt
ls
echo \"echo ${TIMESTAMP} > ./last_update.txt\"
echo \"${TIMESTAMP}\" > ./last_update.txt
ls
git add ./last_update.txt
git status
git commit -m 'Changed last update timestamp'

echo '=> Pushing generated pages to master...'
git push ${GH_AUTH_REF} master

echo \"=> Changing to branch ${CURRENT_BRANCH}...\"
git checkout ${CURRENT_BRANCH}

EOF" > ${SCRIPTS_LOCATION}/timestamp.sh
chmod +x ${SCRIPTS_LOCATION}/*

docker exec -it arquillian-org ${DOCKER_SCRIPTS_LOCATION}/timestamp.sh





echo "=> Killing and removing arquillian-org container..."
docker kill arquillian-org
docker rm arquillian-org



NEW_COMMIT=`git ls-remote ${GIT_PROJECT} master | awk '{print $1;}'`
if [[ "${NEW_COMMIT}" = "${LAST_COMMIT}" ]]; then
    echo "=> There wasn't pushed any new commit - see the log for more information"
    exit 1;
fi


######################### Wait for latest version if pushed to arquillian organization #########################




######################### Verify production #########################

echo "
export ARQUILLIAN_BLOG_TEST_URL=http://arquillian.org/
" >> ${WORKING_DIR}/variables

pwd
ls


${SCRIPT_DIR}/verify.sh ${WORKING_DIR}

exit $?