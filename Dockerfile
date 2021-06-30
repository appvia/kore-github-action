FROM k8s.gcr.io/kustomize/kustomize:v4.1.3 as kustomize
FROM bitnami/kubectl:1.21 as kubectl
FROM mikefarah/yq:4.9.6 as yq

FROM scratch as binaries
ARG JQ_VERSION='1.6'
ARG KORE_VERSION='0.9.0'
ADD https://github.com/stedolan/jq/releases/download/jq-${JQ_VERSION}/jq-linux64 jq
ADD https://storage.googleapis.com/kore-releases/v${KORE_VERSION}/kore-cli-linux-amd64 kore

FROM alpine as run

RUN apk add --no-cache bash

COPY --from=kustomize --chmod=777 /app/kustomize /usr/bin/
COPY --from=kubectl --chmod=777 /opt/bitnami/kubectl/bin/kubectl /usr/bin/
COPY --from=yq --chmod=777 /usr/bin/yq /usr/bin/
COPY --from=binaries --chmod=777 * /usr/bin/

COPY run.sh find-resources-to-delete.jq /usr/bin/

USER nobody
ENV KORE_CONFIG="/tmp/kore"
CMD /usr/bin/run.sh