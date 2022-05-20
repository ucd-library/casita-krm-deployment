#! /bin/bash

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $ROOT_DIR

source ../config.sh

function tab() {
  osascript 2>/dev/null <<EOF
    tell application "System Events"
      tell process "Terminal" to keystroke "t" using command down
    end
    tell application "Terminal"
      activate
      do script with command "cd \"$PWD\"; $*" in window 1
    end tell
EOF
}

# start minikube (k8s)
if [[ $START_MINIKUBE == 'true' ]]; then
  minikube start
else 
  echo "if you need to start minikube run as: START_MINIKUBE=true ./cmds/minikube.sh"
fi

# mount home directory into minikube space
# https://minikube.sigs.k8s.io/docs/handbook/mount/
# This must be started before the cluster is up
if [[ $AUTO_EXTRAS == 'true' ]]; then
  tab minikube mount $HOME:/hosthome
else
  echo "warning, not mounting fs, run as \"AUTO_EXTRAS=true ./cmds/minikube.sh\" to auto mount fs, bind ports and start dashboard" 
fi

# start helm
helm upgrade \
 --install airflow apache-airflow/airflow \
 --namespace airflow \
 --create-namespace \
 --set images.airflow.repository=casita-airflow-worker \
 --set images.airflow.tag=latest \
 -f $ROOT_DIR/../casita-krm-local-dev/values.yaml

# helm uninstall airflow --namespace=airflow

# port forward main web service
if [[ $AUTO_EXTRAS == 'true' ]]; then
  tab kubectl port-forward svc/airflow-webserver 8080:8080 --namespace airflow

  tab minikube dashboard

  kubectl exec --stdin --tty airflow-worker-0 --namespace=airflow -- bash 
fi
