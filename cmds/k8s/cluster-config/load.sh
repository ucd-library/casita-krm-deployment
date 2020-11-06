#! /bin/bash

CWD=$(pwd)

set -e

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $ROOT_DIR

if [[ -z "${BRANCH_NAME}" ]] ; then
  BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
fi

if [[ $BRANCH_NAME == "main" ]] ; then
  BRANCH_NAME=prod
fi

if [[ -f "./$BRANCH_NAME.sh" ]] ; then
  source ./$BRANCH_NAME.sh
  cd $CWD
else
  echo "\$BRANCH_NAME: $BRANCH_NAME does not have an associated cluster";
  exit -1;
fi