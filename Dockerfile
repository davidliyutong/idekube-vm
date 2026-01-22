FROM ubuntu:24.04

RUN apt-get update && \
    apt-get install -y \
    qemu \
    qemu-utils \
    cloud-image-utils \
    qemu-system-aarch64 \
    qemu-system-x86 \
    libvirt-daemon-system \
    libvirt-clients \
    virtinst \
    virt-manager \
    cloud-image-utils && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /workspace