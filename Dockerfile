FROM maven:3-openjdk-8

RUN mkdir -p /.npm /.jspm && \
    chgrp -R 0 /.npm /.jspm && \
    chmod -R g=u /.npm/.jspm
