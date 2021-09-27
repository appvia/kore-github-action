FROM k8s.gcr.io/kustomize/kustomize:v4.4.0 as kustomize

FROM scratch as binaries
ARG KORE_VERSION='v0.10.0-rc1'
ADD https://storage.googleapis.com/kore-releases/${KORE_VERSION}/kore-cli-linux-amd64 kore

FROM alpine as run

RUN apk add --no-cache bash

COPY --from=kustomize --chmod=777 /app/kustomize /usr/bin/
COPY --from=binaries --chmod=777 * /usr/bin/

COPY run.sh /usr/bin/

USER nobody

ENV KORE_CONFIG="/tmp/kore"

CMD /usr/bin/run.sh