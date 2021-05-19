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

######### BUILD API ############

echo "building: $API_IMAGE_NAME:$KRM_TAG"
docker build \
  --build-arg BUILDKIT_INLINE_CACHE=1 \
  --build-arg NODEJS_BASE=${NODEJS_BASE} \
  --cache-from $API_IMAGE_NAME:$DOCKER_CACHE_TAG \
  -t $API_IMAGE_NAME:$KRM_TAG \
  $REPOSITORY_DIR/$KRM_REPO_NAME/api

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

######### WS SERVICE ############

echo "building: $WS_SERVICE_IMAGE_NAME:$KRM_TAG"
docker build \
  --build-arg BUILDKIT_INLINE_CACHE=1 \
  --build-arg NODEJS_BASE=${NODEJS_BASE} \
  --cache-from $WS_SERVICE_IMAGE_NAME:$DOCKER_CACHE_TAG \
  -t $WS_SERVICE_IMAGE_NAME:$KRM_TAG \
  $REPOSITORY_DIR/$KRM_REPO_NAME/public-events/ws

######### HTTP2 SERVICE ############

echo "building: $HTTP2_SERVICE_IMAGE_NAME:$KRM_TAG"
docker build \
  --build-arg BUILDKIT_INLINE_CACHE=1 \
  --build-arg NODEJS_BASE=${NODEJS_BASE} \
  --cache-from $HTTP2_SERVICE_IMAGE_NAME:$DOCKER_CACHE_TAG \
  -t $HTTP2_SERVICE_IMAGE_NAME:$KRM_TAG \
  $REPOSITORY_DIR/$KRM_REPO_NAME/public-events/http2


######### BUILD KAFKA CLI IMAGE ############

echo "building: $KAFKA_CLI_IMAGE_NAME:$APP_VERSION"
docker build \
  --build-arg BUILDKIT_INLINE_CACHE=1 \
  --cache-from $KAFKA_CLI_IMAGE_NAME:$DOCKER_CACHE_TAG \
  -t $KAFKA_CLI_IMAGE_NAME:$APP_VERSION \
  $ROOT_DIR/../debug/kafka-cli

######### BUILD GRAPH SETUP IMAGE ############

echo "building: $GRAPH_SETUP_IMAGE_NAME:$APP_VERSION"
docker build \
  --build-arg BUILDKIT_INLINE_CACHE=1 \
  --cache-from $GRAPH_SETUP_IMAGE_NAME:$DOCKER_CACHE_TAG \
  -t $GRAPH_SETUP_IMAGE_NAME:$APP_VERSION \
  $ROOT_DIR/../setup

######### BUILD DECODER ############

echo "building: $GRB_DECORDER_IMAGE_NAME:$CASITA_TASKS_TAG"
docker build \
  --build-arg BUILDKIT_INLINE_CACHE=1 \
  --build-arg NODEJS_BASE=${NODEJS_BASE} \
  --cache-from $GRB_DECORDER_IMAGE_NAME:$DOCKER_CACHE_TAG \
  -t $GRB_DECORDER_IMAGE_NAME:$CASITA_TASKS_TAG \
  $REPOSITORY_DIR/$CASITA_TASKS_REPO_NAME/decoder

######### BUILD DECODER KRM INTERFACE ############

echo "building: $DECORDER_KRM_INTERFACE_IMAGE_NAME:$CASITA_TASKS_TAG"
docker build \
  --build-arg BUILDKIT_INLINE_CACHE=1 \
  --build-arg NODEJS_BASE=${NODEJS_BASE} \
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

######### GENERIC PAYLOAD WORKER ############

echo "building: $GENERIC_PAYLOAD_WORKER_IMAGE_NAME:$CASITA_TASKS_TAG"
docker build \
  --build-arg BUILDKIT_INLINE_CACHE=1 \
  --build-arg WORKER_BASE_IMAGE=${WORKER_BASE_IMAGE} \
  --cache-from $GENERIC_PAYLOAD_WORKER_IMAGE_NAME:$DOCKER_CACHE_TAG \
  -t $GENERIC_PAYLOAD_WORKER_IMAGE_NAME:$CASITA_TASKS_TAG \
  $REPOSITORY_DIR/$CASITA_TASKS_REPO_NAME/generic-payload-parser

######### NODE STREAM STATUS WORKER ############

echo "building: $NODE_STREAM_STATUS_WORKER_IMAGE_NAME:$CASITA_TASKS_TAG"
docker build \
  --build-arg BUILDKIT_INLINE_CACHE=1 \
  --build-arg WORKER_BASE_IMAGE=${WORKER_BASE_IMAGE} \
  --cache-from $NODE_STREAM_STATUS_WORKER_IMAGE_NAME:$DOCKER_CACHE_TAG \
  -t $NODE_STREAM_STATUS_WORKER_IMAGE_NAME:$CASITA_TASKS_TAG \
  $REPOSITORY_DIR/$CASITA_TASKS_REPO_NAME/status/worker

######### NODE STREAM STATUS SERVICE ############

echo "building: $NODE_STREAM_STATUS_SERVICE_IMAGE_NAME:$CASITA_TASKS_TAG"
docker build \
  --build-arg BUILDKIT_INLINE_CACHE=1 \
  --build-arg NODEJS_BASE=${NODEJS_BASE} \
  --cache-from $NODE_STREAM_STATUS_SERVICE_IMAGE_NAME:$DOCKER_CACHE_TAG \
  -t $NODE_STREAM_STATUS_SERVICE_IMAGE_NAME:$CASITA_TASKS_TAG \
  $REPOSITORY_DIR/$CASITA_TASKS_REPO_NAME/status/service

######### POSTGIS ############

echo "building: $POSTGIS_IMAGE_NAME:$CASITA_TASKS_TAG"
docker build \
  --build-arg BUILDKIT_INLINE_CACHE=1 \
  --cache-from $POSTGIS_IMAGE_NAME:$DOCKER_CACHE_TAG \
  -t $POSTGIS_IMAGE_NAME:$CASITA_TASKS_TAG \
  $REPOSITORY_DIR/$CASITA_TASKS_REPO_NAME/postgis

######### RING BUFFER ############

echo "building: $RING_BUFFER_IMAGE_NAME:$CASITA_TASKS_TAG"
docker build \
  --build-arg BUILDKIT_INLINE_CACHE=1 \
  --cache-from $RING_BUFFER_IMAGE_NAME:$DOCKER_CACHE_TAG \
  --build-arg WORKER_BASE_IMAGE=${WORKER_BASE_IMAGE} \
  -t $RING_BUFFER_IMAGE_NAME:$CASITA_TASKS_TAG \
  $REPOSITORY_DIR/$CASITA_TASKS_REPO_NAME/block-ring-buffer