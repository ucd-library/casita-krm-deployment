
#! /bin/bash

###
# Push docker image and $DOCKER_CACHE_TAG (currently :latest) tag to docker hub
###

set -e
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $ROOT_DIR/..
source config.sh

docker push $BASE_NODE_IMAGE_NAME:$KRM_TAG
docker tag $BASE_NODE_IMAGE_NAME:$KRM_TAG $BASE_NODE_IMAGE_NAME:$DOCKER_CACHE_TAG

docker push $CONTROLLER_IMAGE_NAME:$KRM_TAG
docker tag $CONTROLLER_IMAGE_NAME:$KRM_TAG $CONTROLLER_IMAGE_NAME:$DOCKER_CACHE_TAG

docker push $EXPIRE_IMAGE_NAME:$KRM_TAG
docker tag $EXPIRE_IMAGE_NAME:$KRM_TAG $EXPIRE_IMAGE_NAME:$DOCKER_CACHE_TAG

docker push $WORKER_IMAGE_NAME:$KRM_TAG
docker tag $WORKER_IMAGE_NAME:$KRM_TAG $WORKER_IMAGE_NAME:$DOCKER_CACHE_TAG

docker push $ROUTER_IMAGE_NAME:$KRM_TAG
docker tag $ROUTER_IMAGE_NAME:$KRM_TAG $ROUTER_IMAGE_NAME:$DOCKER_CACHE_TAG

docker push $GRB_DECORDER_IMAGE_NAME:$CASITA_TASKS_TAG
docker tag $GRB_DECORDER_IMAGE_NAME:$CASITA_TASKS_TAG $GRB_DECORDER_IMAGE_NAME:$DOCKER_CACHE_TAG

docker push $DECORDER_KRM_INTERFACE_IMAGE_NAME:$CASITA_TASKS_TAG
docker tag $DECORDER_KRM_INTERFACE_IMAGE_NAME:$CASITA_TASKS_TAG $DECORDER_KRM_INTERFACE_IMAGE_NAME:$DOCKER_CACHE_TAG

docker push $NODE_IMAGE_WORKER_IMAGE_NAME:$CASITA_TASKS_TAG
docker tag $NODE_IMAGE_WORKER_IMAGE_NAME:$CASITA_TASKS_TAG $NODE_IMAGE_WORKER_IMAGE_NAME:$DOCKER_CACHE_TAG

for image in "${ALL_DOCKER_BUILD_IMAGES[@]}"; do
  docker push $image:$DOCKER_CACHE_TAG || true
done