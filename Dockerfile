FROM k8s.gcr.io/kustomize/kustomize:v4.5.4 as kustomize

FROM scratch as binaries
ARG WAYFINDER_VERSION='v0.12.0-beta1'
ADD https://storage.googleapis.com/wayfinder-releases/${WAYFINDER_VERSION}/wf-cli-linux-amd64 wf

FROM alpine as run

RUN apk add --no-cache bash

COPY --from=kustomize --chmod=777 /app/kustomize /usr/bin/
COPY --from=binaries --chmod=777 * /usr/bin/

COPY run.sh /usr/bin/

USER nobody

ENV WAYFINDER_CONFIG="/tmp/wf"

CMD /usr/bin/run.sh
