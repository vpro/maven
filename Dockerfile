FROM maven:3-openjdk-8

RUN mkdir -p /.npm && \
    chgrp -R 0 /.npm && \
    chmod -R g=u /.npm
