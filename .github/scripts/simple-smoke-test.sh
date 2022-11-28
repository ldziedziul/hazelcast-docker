#!/usr/bin/env bash

set -e
set -o pipefail

export CLV_VERSION=v5.2.0-beta3-preview1

function test_docker_image() {
    local image=$1;
    echo "Starting $image"
    local container_id=$(docker run -it --rm -d -p5701:5701 "${image}")
    local key="some-key"
    local expected="some-value"
    echo "Putting '$expected' value to '$key' key"
    clc map put -n some-map $key $expected
    echo "Getting value for '$key' key"
    local actual=$(clc map get -n some-map $key)
    docker stop "$container_id"

    if [ "$expected" != "$actual" ]; then
        echo "Expected to read '${expected}' but got '${actual}'"
        exit 1;
    fi
}

function install_clc() {
  CLC_URL="https://github.com/hazelcast/hazelcast-commandline-client/releases/download/${CLV_VERSION}/hazelcast-clc_${CLV_VERSION}_linux_amd64.tar.gz"
  curl -L $CLC_URL | tar xzf - --strip-components=1 -C /usr/local/bin
  chmod +x /usr/local/bin/clc
}

install_clc
test_docker_image "$@"
