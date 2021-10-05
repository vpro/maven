FROM maven:3-openjdk-8-slim

ENV HOME=/home/ci

ENV YQ_VERSION=v4.2.0
ENV YQ_BINARY=yq_linux_amd64



RUN mkdir -p /home/ci && \
    chgrp -R 0 /home/ci && \
    chmod -R g=u /home/ci && \
    wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY}.tar.gz -O - | tar xz && mv ${YQ_BINARY} /usr/bin/yq
