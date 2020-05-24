#!/usr/bin/env bash
set -eou pipefail

model_name=${1:-"densenet161-8d451a50.pth"}
image_name=${2:-"pytorch-serve-intro"}
[[ -d serve ]] || git clone git@github.com:pytorch/serve.git
[[ -f $model_name ]] || wget https://download.pytorch.org/models/$model_name
docker build \
    -t $image_name \
    --build-arg MODEL_FILE=$model_name \
    .
