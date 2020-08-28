#! /bin/bash

######### DEPLOYMENT CONFIG ############
# Setup your application deployment here
########################################

# Main version number we are tagging the app with. Always update
# this when you cut a new version of the app!
APP_VERSION=v0.0.1

###
# TAGS
###

# Repository tags/branchs
# Tags should always be used for production deployments
# Branches can be used for development deployments
KRM_TAG=main
CASITA_TASKS_TAG=main

# Docker

ZOOKEEPER_TAG=3.6
KAFKA_TAG=2.5.0
MONGO_TAG=4.2
RABBITMQ_TAG=3.7.2-management

DOCKER_CACHE_TAG="latest"
LOCAL_TAG="local-dev"

##
# Repositories
##

GITHUB_ORG_URL=https://github.com/ucd-library

# the krm process pipe repository.  has base worker, controller and router
KRM_REPO_NAME=krm-process-pipe
KRM_REPO_URL=$GITHUB_ORG_URL/${KRM_REPO_NAME}

CASITA_TASKS_REPO_NAME=casita-krm-tasks
CASITA_TASKS_REPO_URL=$GITHUB_ORG_URL/${CASITA_TASKS_REPO_NAME}

###
# Docker
###

GRB_DECORDER_IMAGE_NAME=ucdlib/grb-decoder
DECORDER_KRM_INTERFACE_IMAGE_NAME=ucdlib/casita-decoder-krm-interface
BASE_NODE_IMAGE_NAME=ucdlib/krm-node-utils
WORKER_IMAGE_NAME=ucdlib/krm-worker
NODE_IMAGE_WORKER_IMAGE_NAME=ucdlib/krm-node-image-worker
ROUTER_IMAGE_NAME=ucdlib/krm-router
CONTROLLER_IMAGE_NAME=ucdlib/krm-controller
API_IMAGE_NAME=ucdlib/krm-api
EXPIRE_IMAGE_NAME=ucdlib/krm-expire
ZOOKEEPER_IMAGE_NAME=zookeeper
KAFKA_IMAGE_NAME=bitnami/kafka
MONGO_IMAGE_NAME=mongo
RABBITMQ_IMAGE_NAME=rabbitmq


ALL_DOCKER_BUILD_IMAGES=( \
  $GRB_DECORDER_IMAGE_NAME $WORKER_IMAGE_NAME
  $ROUTER_IMAGE_NAME $CONTROLLER_IMAGE_NAME \
  $DECORDER_KRM_INTERFACE_IMAGE_NAME $NODE_IMAGE_WORKER_IMAGE_NAME
  $EXPIRE_IMAGE_NAME $BASE_NODE_IMAGE_NAME $API_IMAGE_NAME
)

##
# LOCAL FOLDERS
##

# folder in /deployment to place filed in k8s template files
DEPLOYMENT_DIR=k8s

# directory we are going to cache our various git repos
# at different revisions
REPOSITORY_DIR=repositories

LOCAL_DEV_DIR=fvs-app-local-dev

##
# Git
##

ALL_GIT_REPOSITORIES=( $KRM_REPO_NAME $CASITA_TASKS_REPO_NAME )

GIT_CLONE="git clone --depth 1"