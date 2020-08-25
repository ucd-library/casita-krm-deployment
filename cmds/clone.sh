#! /bin/bash

###
# Shallow clone repositories defined in config.sh
# WARNING: Used for gcloud builds.  This wipes
# respositories folders and starts fresh every time
###

set -e
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $ROOT_DIR/..
source config.sh

if [ -d $REPOSITORY_DIR ] ; then
  rm -rf $REPOSITORY_DIR
fi
mkdir -p $REPOSITORY_DIR

# KRM
$GIT_CLONE $KRM_REPO_URL.git \
  --branch $KRM_TAG \
  --depth 1 \
  $REPOSITORY_DIR/$KRM_REPO_NAME

# TASKS
$GIT_CLONE $CASITA_TASKS_REPO_URL.git \
  --branch $CASITA_TASKS_TAG \
  --depth 1 \
  $REPOSITORY_DIR/$CASITA_TASKS_REPO_NAME