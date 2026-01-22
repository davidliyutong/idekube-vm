#!/bin/bash

ARCH="arm64" # TODO: use env var
DISTRO="noble"
IMAGE_ENDPOINT="cloud-images.ubuntu.com"
VDISK_SIZE=10G

# Create assets directory if it doesn't exist
mkdir -p assets

if [ ! -f "assets/${DISTRO}-${ARCH}.qcow2" ]; then
    echo "Downloading Base Image"
    wget -O assets/${DISTRO}-${ARCH}.qcow2 https://${IMAGE_ENDPOINT}/${DISTRO}/current/${DISTRO}-server-cloudimg-${ARCH}.img
else
    echo "Base Image Present"
fi


if [ ! -f "assets/${DISTRO}-${ARCH}.diff.qcow2" ]; then
    echo "Creating the diff image"
    qemu-img create -f qcow2 -b ${DISTRO}-${ARCH}.qcow2 -F qcow2 assets/${DISTRO}-${ARCH}.diff.qcow2
fi

echo "Resizing the diff image to ${VDISK_SIZE}"
qemu-img resize assets/${DISTRO}-${ARCH}.diff.qcow2 ${VDISK_SIZE}
