FROM k8s.gcr.io/kustomize/kustomize:v4.1.3 as kustomize
FROM bitnami/kubectl:1.21 as kubectl

FROM alpine as jq
ENV JQ_VERSION='1.5'
RUN wget  https://github.com/stedolan/jq/releases/download/jq-${JQ_VERSION}/jq-linux64 -O /tmp/jq-linux64

FROM quay.io/appvia/kore:v0.7.2 as kore

FROM mikefarah/yq:4.9.6 as yq

FROM alpine as run

RUN apk add --no-cache bash

WORKDIR /usr/bin

COPY --from=kustomize --chmod=777 /app/kustomize .
COPY --from=kubectl --chmod=777 /opt/bitnami/kubectl/bin/kubectl .
COPY --from=kore --chmod=777 /bin/kore .
COPY --from=jq --chmod=777 /tmp/jq-linux64 .
COPY --from=yq --chmod=777 /usr/bin/yq .

COPY run.sh find-resources-to-delete.jq ./

CMD /usr/bin/run.sh