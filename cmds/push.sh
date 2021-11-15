
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

docker push $API_IMAGE_NAME:$KRM_TAG
docker tag $API_IMAGE_NAME:$KRM_TAG $API_IMAGE_NAME:$DOCKER_CACHE_TAG

docker push $EXPIRE_IMAGE_NAME:$KRM_TAG
docker tag $EXPIRE_IMAGE_NAME:$KRM_TAG $EXPIRE_IMAGE_NAME:$DOCKER_CACHE_TAG

docker push $WORKER_IMAGE_NAME:$KRM_TAG
docker tag $WORKER_IMAGE_NAME:$KRM_TAG $WORKER_IMAGE_NAME:$DOCKER_CACHE_TAG

docker push $ROUTER_IMAGE_NAME:$KRM_TAG
docker tag $ROUTER_IMAGE_NAME:$KRM_TAG $ROUTER_IMAGE_NAME:$DOCKER_CACHE_TAG

docker push $WS_SERVICE_IMAGE_NAME:$KRM_TAG
docker tag $WS_SERVICE_IMAGE_NAME:$KRM_TAG $WS_SERVICE_IMAGE_NAME:$DOCKER_CACHE_TAG

docker push $HTTP2_SERVICE_IMAGE_NAME:$KRM_TAG
docker tag $HTTP2_SERVICE_IMAGE_NAME:$KRM_TAG $HTTP2_SERVICE_IMAGE_NAME:$DOCKER_CACHE_TAG

docker push $GRB_DECORDER_IMAGE_NAME:$CASITA_TASKS_TAG
docker tag $GRB_DECORDER_IMAGE_NAME:$CASITA_TASKS_TAG $GRB_DECORDER_IMAGE_NAME:$DOCKER_CACHE_TAG

docker push $GRAPH_SETUP_IMAGE_NAME:$APP_VERSION
docker tag $GRAPH_SETUP_IMAGE_NAME:$APP_VERSION $GRAPH_SETUP_IMAGE_NAME:$DOCKER_CACHE_TAG

docker push $KAFKA_CLI_IMAGE_NAME:$APP_VERSION
docker tag $KAFKA_CLI_IMAGE_NAME:$APP_VERSION $KAFKA_CLI_IMAGE_NAME:$DOCKER_CACHE_TAG

docker push $DECORDER_KRM_INTERFACE_IMAGE_NAME:$CASITA_TASKS_TAG
docker tag $DECORDER_KRM_INTERFACE_IMAGE_NAME:$CASITA_TASKS_TAG $DECORDER_KRM_INTERFACE_IMAGE_NAME:$DOCKER_CACHE_TAG

docker push $NODE_IMAGE_WORKER_IMAGE_NAME:$CASITA_TASKS_TAG
docker tag $NODE_IMAGE_WORKER_IMAGE_NAME:$CASITA_TASKS_TAG $NODE_IMAGE_WORKER_IMAGE_NAME:$DOCKER_CACHE_TAG

docker push $GENERIC_PAYLOAD_WORKER_IMAGE_NAME:$CASITA_TASKS_TAG
docker tag $GENERIC_PAYLOAD_WORKER_IMAGE_NAME:$CASITA_TASKS_TAG $GENERIC_PAYLOAD_WORKER_IMAGE_NAME:$DOCKER_CACHE_TAG

docker push $NODE_STREAM_STATUS_WORKER_IMAGE_NAME:$CASITA_TASKS_TAG
docker tag $NODE_STREAM_STATUS_WORKER_IMAGE_NAME:$CASITA_TASKS_TAG $NODE_STREAM_STATUS_WORKER_IMAGE_NAME:$DOCKER_CACHE_TAG

docker push $NODE_STREAM_STATUS_SERVICE_IMAGE_NAME:$CASITA_TASKS_TAG
docker tag $NODE_STREAM_STATUS_SERVICE_IMAGE_NAME:$CASITA_TASKS_TAG $NODE_STREAM_STATUS_SERVICE_IMAGE_NAME:$DOCKER_CACHE_TAG

docker push $POSTGIS_IMAGE_NAME:$CASITA_TASKS_TAG
docker tag $POSTGIS_IMAGE_NAME:$CASITA_TASKS_TAG $POSTGIS_IMAGE_NAME:$DOCKER_CACHE_TAG

docker push $RING_BUFFER_IMAGE_NAME:$CASITA_TASKS_TAG
docker tag $RING_BUFFER_IMAGE_NAME:$CASITA_TASKS_TAG $RING_BUFFER_IMAGE_NAME:$DOCKER_CACHE_TAG

docker push $EXTERNAL_TOPICS_IMAGE_NAME:$CASITA_TASKS_TAG
docker tag $EXTERNAL_TOPICS_IMAGE_NAME:$CASITA_TASKS_TAG $EXTERNAL_TOPICS_IMAGE_NAME:$DOCKER_CACHE_TAG

for image in "${ALL_DOCKER_BUILD_IMAGES[@]}"; do
  docker push $image:$DOCKER_CACHE_TAG || true
done