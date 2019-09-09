#!/bin/bash

#This file retrieves GKE credentials and submits an Argo Workflow on K8s

set -e

############ Helper Functions ############

function check_env() {
    if [ -z $(eval echo "\$$1") ]; then
        echo "Variable $1 not found.  Exiting..."
        exit 1
    fi
}

function check_file_exists() {
    if [ ! -f $1 ]; then
        echo "File $1 was not found"
        echo "Here are the contents of the current directory:"
        ls
        exit 1
    fi
}

function yaml_get_generateName {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }' | grep metadata_generateName= | cut -d \" -f2
}

randomstring(){
    cat /dev/urandom | env LC_CTYPE=C tr -dc 'a-z' | fold -w 7 | head -n 1
}

############ Validate Inputs ############

# Check the presence of all required environment variables and files
check_env "INPUT_APPLICATION_CREDENTIALS"
check_env "INPUT_PROJECT_ID"
check_env "INPUT_LOCATION_ZONE"
check_env "INPUT_CLUSTER_NAME"

cd $GITHUB_WORKSPACE

############ Authenticate to GKE ############

# Recover Application Credentials For GKE Authentication
echo "$INPUT_APPLICATION_CREDENTIALS" | base64 -d > /tmp/account.json

# Use gcloud CLI to retrieve k8s authentication
gcloud auth activate-service-account --key-file=/tmp/account.json
gcloud config set project "$INPUT_PROJECT_ID"
gcloud container clusters get-credentials "$INPUT_CLUSTER_NAME" --zone "$INPUT_LOCATION_ZONE" --project "$INPUT_PROJECT_ID"

# Copy Config File
mkdir -p $GITHUB_WORKSPACE/.kube
cp $HOME/.kube/config $GITHUB_WORKSPACE/.kube/
chmod 777 $GITHUB_WORKSPACE/.kube/config

# Show Pods
export KUBECONFIG="$GITHUB_WORKSPACE/.kube/config"
kubectl get pods