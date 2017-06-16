#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. ${DIR}/build_prod_and_run.sh

docker exec -it ${DOCKER_ID} ${DOCKER_SCRIPTS_LOCATION}/deploy.sh
docker kill ${DOCKER_ID}
docker rm ${DOCKER_ID}

git branch
echo "=> Pushing generated pages to master..."
git push origin master
