#!/bin/bash
set -e

# Handle github action prefixing the env vars
export WF_TOKEN=${INPUT_WF_TOKEN:-${WF_TOKEN}}
export WF_SERVER=${INPUT_WF_SERVER:-${WF_SERVER}}

# Kore version
wf version

# Validate who I am
echo "::group::whoami"
  wf whoami --verbose
echo "::endgroup::"

echo "::group::diff"
  kustomize build | wf sync -f - --non-interactive --state config --dry-run
echo "::endgroup::"


echo "::group::output"
if [[ "$INPUT_APPLY" == "true" ]]; then
  kustomize build | wf sync -f - --non-interactive --state config
else
  echo "DRY RUN"
fi
echo "::endgroup::"
