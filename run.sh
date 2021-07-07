#!/bin/bash
set -e

# Handle github action prefixing the env vars
export KORE_TOKEN=${INPUT_KORE_TOKEN:-${KORE_TOKEN}}
export KORE_SERVER=${INPUT_KORE_SERVER:-${KORE_SERVER}}

# Kore version
kore version

# Validate who I am
echo "::group::whoami"
  kore whoami --verbose
echo "::endgroup::"

echo "::group::diff"
  kustomize build | kore sync -f - --non-interactive -t kore-admin --state config --dry-run
echo "::endgroup::"


echo "::group::output"
if [[ "$INPUT_APPLY" == "true" ]]; then
  kustomize build | kore sync -f - --non-interactive -t kore-admin --state config
else
  echo "DRY RUN"
fi
echo "::endgroup::"