#!/usr/bin/env bash

docker run -it --rm \
    --user $(id -u):$(id -g) \
    -v "$(pwd)"/output:/etc/matchbox \
    -v "$(pwd)"/output:/var/lib/matchbox \
    -p 8080:8080 \
    -p 8081:8081 \
    quay.io/coreos/matchbox:latest \
        -data-path /var/lib/matchbox \
        -assets-path /var/lib/matchbox \
        -address 0.0.0.0:8080 \
        -rpc-address 0.0.0.0:8081
