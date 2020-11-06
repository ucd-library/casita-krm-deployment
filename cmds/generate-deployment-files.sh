#! /bin/bash

##
# Generate docker-compose deployment and local development files based on
# config.sh parameters
##

set -e
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $ROOT_DIR/../templates

source ../config.sh

# generate main dc file
content=$(cat deployment.yaml)
echo "deployment.yaml (dc)"
for key in $(compgen -v); do
  if [[ $key == "COMP_WORDBREAKS" || $key == "content" ]]; then
    continue;
  fi
  escaped=$(printf '%s\n' "${!key}" | sed -e 's/[\/&]/\\&/g')
  content=$(echo "$content" | sed "s/{{$key}}/${escaped}/g") 
done
echo "$content" > ../docker-compose.yaml

# generate k8s files
rm -rf ../k8s
mkdir ../k8s

for file in ./k8s/*.yaml; do
  file=$(basename $file)
  echo "$file (k8s)"
  content=$(cat ../templates/k8s/$file)
  for key in $(compgen -v); do
    if [[ $key == "COMP_WORDBREAKS" || $key == "content" ]]; then
      continue;
    fi
    escaped=$(printf '%s\n' "${!key}" | sed -e 's/[\/&]/\\&/g')
    content=$(echo "$content" | sed "s/{{$key}}/${escaped}/g") 
  done
  echo "$content" > ../k8s/$file
done

# generate local development dc file
content=$(cat local-dev.yaml)
echo "local-dev.yaml (dc)"
KRM_TAG=$LOCAL_TAG
CASITA_TASKS_TAG=$LOCAL_TAG
for key in $(compgen -v); do
  if [[ $key == "COMP_WORDBREAKS" || $key == "content" ]]; then
    continue;
  fi
  escaped=$(printf '%s\n' "${!key}" | sed -e 's/[\/&]/\\&/g')
  content=$(echo "$content" | sed "s/{{$key}}/${escaped}/g") 
done
if [ ! -d "../casita-krm-local-dev" ]; then
  mkdir ../casita-krm-local-dev
fi

echo "$content" > ../casita-krm-local-dev/docker-compose.yaml