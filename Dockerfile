FROM maven:3-openjdk-8

RUN touch /.babel.json && \
    mkdir -p /.npm /.jspm && \
    chgrp -R 0 /.npm /.jspm /.babel.json && \
    chmod -R g=u /.npm /.jspm /.babel.json
