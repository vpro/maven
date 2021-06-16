FROM maven:3-openjdk-8

ENV HOME=/home/ci

RUN mkdir -p /home/ci && \
    chgrp -R 0 /home/ci && \
    chmod -R g=u /home/ci
