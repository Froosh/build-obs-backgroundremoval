#!/bin/sh

TARGET_PACKAGE=obs-backgroundremoval
TARGET_VERSION=v0.4.0

mkdir --parents $PWD/output
docker build --tag $TARGET_PACKAGE:$TARGET_VERSION .
docker run --interactive --tty --rm --volume $PWD/output:/output $TARGET_PACKAGE:$TARGET_VERSION

# docker image rm $TARGET_PACKAGE:$TARGET_VERSION --force

ls -las $PWD/output/
