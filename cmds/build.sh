#! /bin/bash

set -e

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $ROOT_DIR

source ../config.sh

REPOSITORY_DIR=$ROOT_DIR/../$REPOSITORY_DIR

echo "Starting docker build"

# Use buildkit to speedup local builds
# Not supported in google cloud build yet
if [[ -z $GCLOUD_BUILD ]]; then
  echo "Using docker buildkit"
  export DOCKER_BUILDKIT=1
fi

# Additionally set local-dev tags used by 
# local development docker-compose file
if [[ ! -z $LOCAL_BUILD ]]; then
  echo "Using local tags: $LOCAL_TAG"
  KRM_TAG=$LOCAL_TAG
  CASITA_TASKS_TAG=$LOCAL_TAG
fi

NODEJS_BASE=$BASE_NODE_IMAGE_NAME:$KRM_TAG

######### BUILD BASE NODE IMAGE ############

echo "building: $BASE_NODE_IMAGE_NAME:$KRM_TAG"
docker build \
  --build-arg BUILDKIT_INLINE_CACHE=1 \
  --cache-from $BASE_NODE_IMAGE_NAME:$DOCKER_CACHE_TAG \
  -t $BASE_NODE_IMAGE_NAME:$KRM_TAG \
  $REPOSITORY_DIR/$KRM_REPO_NAME/node-utils

######### BUILD CONTROLLER ############

echo "building: $CONTROLLER_IMAGE_NAME:$KRM_TAG"
docker build \
  --build-arg BUILDKIT_INLINE_CACHE=1 \
  --build-arg NODEJS_BASE=${NODEJS_BASE} \
  --cache-from $CONTROLLER_IMAGE_NAME:$DOCKER_CACHE_TAG \
  -t $CONTROLLER_IMAGE_NAME:$KRM_TAG \
  $REPOSITORY_DIR/$KRM_REPO_NAME/controller

######### BUILD EXPIRE ############

echo "building: $EXPIRE_IMAGE_NAME:$KRM_TAG"
docker build \
  --build-arg BUILDKIT_INLINE_CACHE=1 \
  --build-arg NODEJS_BASE=${NODEJS_BASE} \
  --cache-from $EXPIRE_IMAGE_NAME:$DOCKER_CACHE_TAG \
  -t $EXPIRE_IMAGE_NAME:$KRM_TAG \
  $REPOSITORY_DIR/$KRM_REPO_NAME/expire

######### BUILD WORKER ############

echo "building: $WORKER_IMAGE_NAME:$KRM_TAG"
docker build \
  --build-arg BUILDKIT_INLINE_CACHE=1 \
  --build-arg NODEJS_BASE=${NODEJS_BASE} \
  --cache-from $WORKER_IMAGE_NAME:$DOCKER_CACHE_TAG \
  -t $WORKER_IMAGE_NAME:$KRM_TAG \
  $REPOSITORY_DIR/$KRM_REPO_NAME/worker

WORKER_BASE_IMAGE=$WORKER_IMAGE_NAME:$KRM_TAG

######### BUILD ROUTER ############

echo "building: $ROUTER_IMAGE_NAME:$KRM_TAG"
docker build \
  --build-arg BUILDKIT_INLINE_CACHE=1 \
  --build-arg NODEJS_BASE=${NODEJS_BASE} \
  --cache-from $ROUTER_IMAGE_NAME:$DOCKER_CACHE_TAG \
  -t $ROUTER_IMAGE_NAME:$KRM_TAG \
  $REPOSITORY_DIR/$KRM_REPO_NAME/router

######### BUILD DECODER ############

echo "building: $GRB_DECORDER_IMAGE_NAME:$CASITA_TASKS_TAG"
docker build \
  --build-arg BUILDKIT_INLINE_CACHE=1 \
  --cache-from $GRB_DECORDER_IMAGE_NAME:$DOCKER_CACHE_TAG \
  -t $GRB_DECORDER_IMAGE_NAME:$CASITA_TASKS_TAG \
  $REPOSITORY_DIR/$CASITA_TASKS_REPO_NAME/decoder

######### BUILD DECODER KRM INTERFACE ############

echo "building: $DECORDER_KRM_INTERFACE_IMAGE_NAME:$CASITA_TASKS_TAG"
docker build \
  --build-arg BUILDKIT_INLINE_CACHE=1 \
  --cache-from $DECORDER_KRM_INTERFACE_IMAGE_NAME:$DOCKER_CACHE_TAG \
  -t $DECORDER_KRM_INTERFACE_IMAGE_NAME:$CASITA_TASKS_TAG \
  $REPOSITORY_DIR/$CASITA_TASKS_REPO_NAME/decoder-krm-interface

######### NODE IMAGE WORKER ############

echo "building: $NODE_IMAGE_WORKER_IMAGE_NAME:$CASITA_TASKS_TAG"
docker build \
  --build-arg BUILDKIT_INLINE_CACHE=1 \
  --build-arg WORKER_BASE_IMAGE=${WORKER_BASE_IMAGE} \
  --cache-from $NODE_IMAGE_WORKER_IMAGE_NAME:$DOCKER_CACHE_TAG \
  -t $NODE_IMAGE_WORKER_IMAGE_NAME:$CASITA_TASKS_TAG \
  $REPOSITORY_DIR/$CASITA_TASKS_REPO_NAME/node-image-utils