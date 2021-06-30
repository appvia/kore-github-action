#!/bin/bash



export KORE_TOKEN=${INPUT_KORE_TOKEN}
export KORE_SERVER=${INPUT_KORE_SERVER}
export KORE_TEAM=${INPUT_KORE_TEAM}

echo "WHO AM I"
kore whoami

TMP=$(mktemp -d)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

echo "GET THE INTENDED STATE"
kustomize build . | yq eval --tojson - | jq -src > ${TMP}/combined.json 

echo ${TMP}/combined.json

echo "APPLY THE INTENDED STATE"
cat ${TMP}/combined.json| yq eval-all -P '.[] | splitDoc' -  | kore apply -f -

echo "REMOVE OLD RESOURCES"
RESOURCES=$(kore get configmap gitops -o json | jq -cr ".data.combined" | jq -sr --slurpfile desired ${TMP}/combined.json -f ${SCRIPT_DIR}/find-resources-to-delete.jq - | jq -rs )
echo $RESOURCES | yq eval-all -P '.[] | splitDoc' -  | kore delete -f -

echo "UPDATING STATE FILE"
kubectl --dry-run=client -o json create configmap gitops --from-file=combined=${TMP}/combined.json | kore apply -f -