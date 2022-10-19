FROM maven:3.8-eclipse-temurin-17

LABEL maintainer=digitaal-techniek@vpro.nl

ENV YQ_VERSION=v4.27.5
ENV YQ_BINARY=yq_linux_amd64

ADD entrypoint.sh /root/entrypoint.sh

RUN apt-get -y update && apt-get install -y wget ssh git && \
    wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY}.tar.gz -O - | tar xz && mv ${YQ_BINARY} /usr/bin/yq && \
    curl -fsSL https://downloads-openshift-console.apps.cluster.chp4.io/amd64/linux/oc.tar --output oc.tar && \
    tar xvf oc.tar && \
    mv oc /usr/local/bin && \
    chmod +x /usr/local/bin/oc && \
    rm -f oc.tar && \
    mkdir /root/.ssh && \
    ssh-keyscan git.vpro.nl >/root/.ssh/known_hosts && \
    chgrp -R 0 /root/.ssh && \
    chmod -R g=u /root/.ssh && \
    chmod +x /root/entrypoint.sh

WORKDIR /root

ENTRYPOINT ["/root/entrypoint.sh"]
