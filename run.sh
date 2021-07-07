#!/bin/bash
set -e

# Handle github action prefixing the env vars
export KORE_TOKEN=${INPUT_KORE_TOKEN:-${KORE_TOKEN}}
export KORE_SERVER=${INPUT_KORE_SERVER:-${KORE_SERVER}}

# Safe escaped multiline output inline for github
# https://github.community/t/set-output-truncates-multiline-strings/16852/5
# $1 is the name of the output
# $2 is the multiline content
function github_safe_output {
  STRING="${2//'%'/'%25'}"
  STRING="${STRING//$'\n'/'%0A'}"
  STRING="${STRING//$'\r'/'%0D'}"
  echo "::set-output name=${1}::${STRING}"
}

# Kore version
kore version

# Validate who I am
github_safe_output whoami "$(kore whoami)"

DIFF=$(kustomize build | kore sync -f - --non-interactive -t kore-admin --state config --dry-run)

github_safe_output diff "${DIFF}"

if [[ "$INPUT_APPLY" == "true" ]]; then
  OUTPUT=$(kustomize build | kore sync -f - --non-interactive -t kore-admin --state config)
  github_safe_output output "${OUTPUT}"
else
  github_safe_output output "DRY RUN"
fi