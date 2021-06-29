# Github action to apply manifests stored in git to the kore api

`kustomization.yaml` by convention must be in the root of the repository, apart from that you can use any importers, transformers, and general templating logic etc with kustomize to build up the resources to send to the Kore api server.

## Example usage

```yaml
# .github/workflows/ci.yaml
name: ci

on:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2.3.4
      - uses: appvia/kore-github-action:v1.0.0
        with:
          kore-token: ${{ secrets.KORE_TOKEN}}
          kore-team: ${{ secrets.KORE_TEAM }}
          kore-server: ${{ secrets.KORE_SERVER }}
          github-token: ${{ secrets.GITHUB_TOKEN }}
          github-actor: ${{ github.actor }}
```

```yaml
# kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
metadata:
  name: GitOps Managed Kore Resources

resources:
  - user1.yaml
```

```yaml
# user1.yaml
apiVersion: org.kore.appvia.io/v1
kind: User
metadata:
  name: myuser
  namespace: kore
spec:
  disabled: false
  email: myuser@local
  username: myuser
```
