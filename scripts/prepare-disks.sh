#!/bin/bash

ARCH="arm64" # TODO: use env var
DISTRO="noble"
IMAGE_ENDPOINT="cloud-images.ubuntu.com"
VDISK_SIZE=10G

# Create assets directory if it doesn't exist
mkdir -p assets

if [ ! -f "assets/${DISTRO}-${ARCH}.img" ]; then
    echo "Downloading Base Image"
    wget -O assets/${DISTRO}-${ARCH}.img https://${IMAGE_ENDPOINT}/${DISTRO}/current/${DISTRO}-server-cloudimg-${ARCH}.img
else
    echo "Base Image Present"
fi


if [ ! -f "assets/${DISTRO}-${ARCH}.qcow2" ]; then
    echo "Creating the diff image"
    pushd assets
    qemu-img create -f qcow2 -o backing_file=${DISTRO}-${ARCH}.img,backing_fmt=qcow2 ${DISTRO}-${ARCH}.qcow2 ${VDISK_SIZE}
    popd
fi
