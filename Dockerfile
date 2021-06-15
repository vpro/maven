FROM maven:3-openjdk-8

RUN mkdir -p /work && \
    chgrp -R 0 /work && \
    chmod -R g=u /work

WORKDIR /work
