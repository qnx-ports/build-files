#!/bin/bash

METHOD=${METHOD:-docker}
${METHOD} build -t qnx-ports-docker \
  --build-arg USER_NAME="$(id --user --name | awk '{print $1;}')" \
  --build-arg GROUP_NAME="$(id --group --name | awk '{print $1;}')" \
  --build-arg USER_ID="$(id --user | awk '{print $1;}')" \
  --build-arg GROUP_ID="$(id --group | awk '{print $1;}')" \
  .
