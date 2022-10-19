#!/usr/bin/env bash

if [ ! -z ${GITLAB_RUNNER_PRIVATE_KEY+x} ];
then
  echo Starting agent and adding key
  eval $(ssh-agent -s)
  ssh-add <(echo "$GITLAB_RUNNER_PRIVATE_KEY")
fi

exec "$@"
