FROM maven:3-openjdk-11-slim

LABEL maintainer=digitaal-techniek@vpro.nl

ENV HOME=/home/ci

ENV YQ_VERSION=v4.2.0
ENV YQ_BINARY=yq_linux_amd64


RUN  adduser ci --system --uid 1001 --shell /bin/bash && \
    apt-get -y update && apt-get install -y wget git && \
    wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY}.tar.gz -O - | tar xz && mv ${YQ_BINARY} /usr/bin/yq && \
    curl -fsSL https://downloads-openshift-console.apps.cluster.chp4.io/amd64/linux/oc.tar --output oc.tar && \
    tar xvf oc.tar && \
    mv oc /usr/local/bin && \
    chmod +x /usr/local/bin/oc && \
    rm -f oc.tar  \

USER 1001
ENTRYPOINT bash
