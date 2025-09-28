FROM maven:3.9.11-eclipse-temurin-25

LABEL org.opencontainers.image.description="This image is used in CI/CD to build projects with maven"
LABEL org.opencontainers.image.licenses="Apache-2.0"

LABEL maintainer="digitaal-techniek@vpro.nl,michiel@mmprogrami.nl"

ENV YQ_VERSION=v4.47.2

ADD entrypoint.sh /root/entrypoint.sh
ADD after_maven.sh /root/after_maven.sh
ADD setup_maven.sh /root/setup_maven.sh
ADD maven_release.sh /root/maven_release.sh
ADD maven_branch.sh /root/maven_branch.sh
ADD maven.sh /root/maven.sh
ADD count.xslt /root/count.xslt
ADD failures_and_errors.xslt /root/failures_and_errors.xslt
ADD jacoco.xslt /root/jacoco.xslt



RUN apt-get -y update && apt-get -y upgrade && apt-get install -y wget openssh-client git rsync file xsltproc && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    export ARCH=`dpkg --print-architecture` && \
    export YQ_BINARY=yq_linux_${ARCH} && \
    wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY}.tar.gz -O - | tar xz && mv ${YQ_BINARY} /usr/bin/yq && \
    curl -fsSL https://downloads-openshift-console.apps.cluster.chp5-prod.npocloud.nl/${ARCH}/linux/oc.tar --output oc.tar && \
    tar xvf oc.tar && \
    mv oc /usr/local/bin && \
    chmod +x /usr/local/bin/oc && \
    rm -f oc.tar && \
    mkdir -p /root/.ssh && \
    (ssh-keyscan gitlab.com >/root/.ssh/known_hosts ; echo "gitlab.com: $?") && \
    ssh-keyscan github.com >>/root/.ssh/known_hosts && \
    chgrp -R 0 /root/.ssh && \
    chmod -R g=u /root/.ssh && \
    chmod +x /root/entrypoint.sh  && \
    (echo -n "vpro/maven build time=" ; date -Iseconds) >> /DOCKER.BUILD


WORKDIR /root



ENTRYPOINT ["/root/entrypoint.sh"]
