# Github action to apply manifests stored in git to the kore api

`kustomization.yaml` by convention must be in the root of the repository, apart from that you can use any importers, transformers, and general templating logic etc with kustomize to build up the resources to send to the Kore api server.

## Example usage

```yaml
# .github/workflows/ci.yaml
name: ci

on:
  push:
  pull_request:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2.3.4
      - uses: appvia/kore-github-action:v4.0.0
        id: kore
        with:
          kore_token: '${{ secrets.KORE_TOKEN }}'
          kore_server: '${{ secrets.KORE_SERVER }}'
          apply: ${{ github.ref == 'refs/heads/main' }}

      - name: 'Comment PR'
        uses: actions/github-script@4.0.2
        if: github.event_name == 'pull_request'
        with:
          script: |
            github.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: `# Proposed diff
              \`\`\`diff
              ${{steps.kore.outputs.diff}}
              \`\`\`
              `
            })
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
