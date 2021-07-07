#!/bin/bash
set -e

echo $INPUT_KORE_CONFIG | base64 -d > /tmp/kore
export KORE_CONFIG="/tmp/kore"

# Safe multiline output inline for github
# https://github.community/t/set-output-truncates-multiline-strings/16852/5
# $1 is the name of the output
# $2 is the multiline content
function github_safe_output {
  STRING="${2//'%'/'%25'}"
  STRING="${SAFE_STRING//$'\n'/'%0A'}"
  STRING="${SAFE_STRING//$'\r'/'%0D'}"
  echo "::set-output name=${1}::${STRING}"
}

github_safe_output whoami $(kore whoami)

DESIRED=$(kustomize build . )

DIFF=$(echo $DESIRED | kore sync -f - --non-interactive -t kore-admin --state config --dry-run)

github_safe_output diff ${DIFF}

if [[ "$INPUT_APPLY" == "true" ]]; then
  OUTPUT=$(echo $DESIRED | kore sync -f - --non-interactive -t kore-admin --state config)
  github_safe_output output ${OUTPUT}
elif
  github_safe_output output "DRY RUN"
fi