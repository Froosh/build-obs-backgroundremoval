# syntax=docker/dockerfile:1

FROM ubuntu:latest

ARG APT_PROXY=http://little-timmy:3142/

ARG OUTPUT_PATH=/output
ARG TARGET_PACKAGE=obs-backgroundremoval
ARG VERSION=v0.4.0

# ARG ONNXRUNTIME_VERSION=1.12.0

ENV DEBIAN_FRONTEND=noninteractive \
    OUTPUT_PATH="${OUTPUT_PATH}" \
    TARGET_PACKAGE=${TARGET_PACKAGE} \
    VERSION=${VERSION}

#     ONNXRUNTIME_VERSION=${ONNXRUNTIME_VERSION} \

RUN set -eux \
 && echo "Acquire::http::Proxy \"$APT_PROXY\";" | tee /etc/apt/apt.conf.d/01proxy \
 && apt-get --yes update \
 && apt-get --yes install --no-install-recommends \
        build-essential \
        ca-certificates \
        cmake \
        git \
        language-pack-en \
        libobs-dev \
        libonnx-dev \
        libopencv-dev \
        libsimde-dev \
        wget \
 && rm -rf /var/lib/apt/lists/*

# RUN wget https://github.com/microsoft/onnxruntime/releases/download/v${ONNXRUNTIME_VERSION}/onnxruntime-linux-x64-${ONNXRUNTIME_VERSION}.tgz \
#  && tar xzvf onnxruntime-linux-x64-${ONNXRUNTIME_VERSION}.tgz --strip-components=1 -C /usr/local/ --wildcards "*/include/*" "*/lib*/"

RUN git clone https://github.com/royshil/${TARGET_PACKAGE}.git \
 && cd ${TARGET_PACKAGE} \
 && git checkout ${VERSION} \
 && mkdir build \
 && cd build \
 && cmake .. \
 && cmake --build . \
 && cmake --install . \
 && mkdir --parents ${OUTPUT_PATH}

VOLUME [ "${OUTPUT_PATH}" ]

CMD set -eux \
 && mkdir --parents ${OUTPUT_PATH}/bin/64bit \
 && mkdir --parents ${OUTPUT_PATH}/data \
 && cp --force /usr/local/lib/obs-plugins/${TARGET_PACKAGE}.so ${OUTPUT_PATH}/bin/64bit/ \
 && cp --force --recursive /usr/local/share/obs/obs-plugins/${TARGET_PACKAGE}/* ${OUTPUT_PATH}/data

#  && cp --force /usr/local/lib/libonnxruntime.so ${OUTPUT_PATH}/bin/64bit/libonnxruntime.so.${ONNXRUNTIME_VERSION} \
