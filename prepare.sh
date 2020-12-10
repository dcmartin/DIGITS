#! /bin/bash

while true; do
    INCLUDE=$(sed -n '0,/#INCLUDE/{=;p}' Dockerfile | sed -n 'N;s/\n#INCLUDE /:/p')
    [ -z "$INCLUDE" ] && break

    LINE=$(echo $INCLUDE | cut -d: -f1)
    REPO=$(echo $INCLUDE | cut -d: -f2)

    cat $REPO/Dockerfile \
     | grep -v "^FROM " \
     | grep -v "^MAINTAINER " \
     | grep -v "^COPY " \
     | grep -v "NVIDIA_BUILD_" \
     | sed '/WORKDIR \/workspace/,$d' \
     > Dockerfile.$REPO

    sed -i "${LINE}d;$((LINE-1))rDockerfile.$REPO" Dockerfile
done
