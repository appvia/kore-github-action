#!/bin/bash

echo $INPUT_KORE_CONFIG | base64 -d > /tmp/kore
export KORE_CONFIG="/tmp/kore"

# if [ -z "$INPUT_KORE_TOKEN" ]; then export KORE_TOKEN=${INPUT_KORE_TOKEN}; fi
# if [ -z "$INPUT_KORE_SERVER" ]; then export KORE_SERVER=${INPUT_KORE_SERVER}; fi
# if [ -z "$INPUT_KORE_TEAM" ]; then export KORE_TEAM=${INPUT_KORE_TEAM}; fi

echo "WHO AM I"
kore whoami

TMP=$(mktemp -d)

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

echo "GET THE INTENDED STATE"
kustomize build . | yq eval --tojson - | jq -src > ${TMP}/combined.json 

echo ${TMP}/combined.json

set -e

echo "APPLY THE INTENDED STATE"
cat ${TMP}/combined.json| yq eval-all -P '.[] | splitDoc' -  | kore apply -f -

echo "REMOVE OLD RESOURCES"
RESOURCES=$(kore get -t kore-admin configmap gitops -o json | jq -cr ".data.combined" | jq -r --slurpfile desired ${TMP}/combined.json -f ${SCRIPT_DIR}/find-resources-to-delete.jq | jq -sr)
echo $RESOURCES | yq eval-all -P '.[] | splitDoc' -  | kore delete -f -

echo "UPDATING STATE FILE"
kubectl -n kore-admin --dry-run=client -o json create configmap gitops --from-file=combined=${TMP}/combined.json | kore apply -f -