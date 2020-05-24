FROM pytorch/torchserve:latest

# Args
ARG MODEL_FILE

# System-related
RUN echo 'export PATH=$PATH:/home/model-server/.local/bin' >> ~/.bashrc
RUN /usr/bin/python3 -m pip install --upgrade pip
RUN pip install \
    torch \
    torchtext \
    torchvision \
    sentencepiece \
    psutil \
    future
RUN pip install \
    torchserve \
    torch-model-archiver

# Pytorch-related
COPY serve serve
COPY ${MODEL_FILE} ${MODEL_FILE}
RUN PATH=$PATH:/home/model-server/.local/bin torch-model-archiver \
    --model-name densenet161 \
    --version 1.0 \
    --model-file ./serve/examples/image_classifier/densenet_161/model.py \
    --serialized-file ${MODEL_FILE} \
    --export-path model-store \
    --extra-files ./serve/examples/image_classifier/index_to_name.json \
    --handler image_classifier
