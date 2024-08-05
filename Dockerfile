FROM maven:3.9.6-eclipse-temurin-21


LABEL maintainer=digitaal-techniek@vpro.nl

ENV YQ_VERSION=v4.40.5
ENV YQ_BINARY=yq_linux_amd64

ADD entrypoint.sh /root/entrypoint.sh

RUN apt-get -y update && apt-get install -y wget ssh git rsync && \
    wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY}.tar.gz -O - | tar xz && mv ${YQ_BINARY} /usr/bin/yq && \
    curl -fsSL https://downloads-openshift-console.apps.cluster.chp5-prod.npocloud.nl/amd64/linux/oc.tar --output oc.tar && \
    tar xvf oc.tar && \
    mv oc /usr/local/bin && \
    chmod +x /usr/local/bin/oc && \
    rm -f oc.tar && \
    mkdir -p /root/.ssh && \
    (ssh-keyscan git.vpro.nl >/root/.ssh/known_hosts ; echo "git.vpro.nl: $?") && \
    (ssh-keyscan files-digitaal.vpro.nl >>/root/.ssh/known_hosts ; echo "files-digitaal.vpro.nl: $?") && \
    (ssh-keyscan gitlab.com >>/root/.ssh/known_hosts ; echo "gitlab.com: $?") && \
    ssh-keyscan github.com >>/root/.ssh/known_hosts && \
    chgrp -R 0 /root/.ssh && \
    chmod -R g=u /root/.ssh && \
    chmod +x /root/entrypoint.sh

WORKDIR /root

ENTRYPOINT ["/root/entrypoint.sh"]
