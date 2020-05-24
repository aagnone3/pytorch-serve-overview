#!/usr/bin/env bash
set -eou pipefail
source ./env

image=${1?Please pass a URL or local path to an image to classify.}
[[ -f $image ]] && {
    image_file=$image
} || {
    image_url=${1:-"https://s3.amazonaws.com/model-server/inputs/kitten.jpg"}
    image_file=images/$(echo $image_url | rev | cut -d/ -f1 | rev)
    [[ -f $image_file ]] || {
        pushd images
        curl -O $image_url
        popd
    }
}
curl \
    -X POST \
    localhost:$SERVER_PORT/predictions/densenet161 \
    -T $image_file \
    2>/dev/null
