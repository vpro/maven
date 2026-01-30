FROM maven:3.9.12-eclipse-temurin-25-alpine

LABEL org.opencontainers.image.description="This image is used in CI/CD to build projects with maven"
LABEL org.opencontainers.image.licenses="Apache-2.0"
LABEL maintainer="digitaal-techniek@vpro.nl,michiel@mmprogrami.nl"

ENV YQ_VERSION=v4.50.1

COPY entrypoint.sh /root/entrypoint.sh
COPY after_maven.sh /root/after_maven.sh
COPY setup_maven.sh /root/setup_maven.sh
COPY maven_release.sh /root/maven_release.sh
COPY maven_branch.sh /root/maven_branch.sh
COPY maven.sh /root/maven.sh
COPY count.xslt /root/count.xslt
COPY failures_and_errors.xslt /root/failures_and_errors.xslt
COPY jacoco.xslt /root/jacoco.xslt

RUN apk update && apk add --no-cache git libxslt && \
    ARCH=$(uname -m) && \
    case "$ARCH" in \
      x86_64) ARCH="amd64" ;; \
      aarch64) ARCH="arm64" ;; \
      i386|i686) ARCH="386" ;; \
    esac && \
    YQ_BINARY="yq_linux_${ARCH}" && \
    wget -q https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY}.tar.gz -O - | tar xz && \
    mv ${YQ_BINARY} /usr/bin/yq && \
    curl -fsSL https://downloads-openshift-console.apps.cluster.chp5-prod.npocloud.nl/${ARCH}/linux/oc.tar --output oc.tar && \
    tar xvf oc.tar && \
    mv oc /usr/local/bin && \
    chmod +x /usr/local/bin/oc && \
    rm -f oc.tar && \
    mkdir -p /root/.ssh && \
    ssh-keyscan gitlab.com > /root/.ssh/known_hosts && \
    ssh-keyscan github.com >> /root/.ssh/known_hosts && \
    chgrp -R 0 /root/.ssh && \
    chmod -R g=u /root/.ssh && \
    chmod +x /root/entrypoint.sh && \
    echo -n "vpro/maven build time=" && date -Iseconds >> /DOCKER.BUILD

WORKDIR /root

ENTRYPOINT ["/root/entrypoint.sh"]