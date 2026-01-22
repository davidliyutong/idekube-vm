#!/bin/bash

ARCH="arm64" # TODO: use env var
DISTRO="noble"
VM_MEMORY="8G"
VM_CPU="4"
HEADLESS="1" # Set to 1 for headless mode


# Detect accelerator
if [[ "$(uname)" == "Darwin" ]]; then
    ACCELERATOR=" -accel hvf "
    CPU_TYPE="host"
elif [[ "$(uname)" == "Linux" ]]; then
    if [[ -e /dev/kvm ]] && (lsmod | grep -q kvm || [[ -d /sys/module/kvm ]]); then
        ACCELERATOR=" -accel kvm "
        CPU_TYPE="host"
    else
        ACCELERATOR=""
        echo "Warning: /dev/kvm not found, KVM acceleration disabled" >&2
        if [[ "${ARCH}" == "arm64" ]]; then
            CPU_TYPE="cortex-a72"
        elif [[ "${ARCH}" == "x86_64" ]]; then
            CPU_TYPE="qemu64"
        else
            CPU_TYPE="host"
        fi
    fi
else
    echo "Unsupported OS for acceleration" >&2
    exit 1
fi

# Graphics options
if [[ "${HEADLESS}" == "1" ]]; then
    GRAPHICS_OPTS="-nographic"
else
    GRAPHICS_OPTS="-device virtio-gpu-pci -display default,show-cursor=on -device qemu-xhci -device usb-kbd -device usb-tablet -device intel-hda -device hda-duplex"
fi

# Check if user network backend is available
NETWORK_OPTS=""
if qemu-system-aarch64 -netdev help 2>&1 | grep -q "user"; then
    NETWORK_OPTS="-netdev user,id=net0,hostfwd=tcp::10022-:22,hostfwd=tcp::8080-:80 -device virtio-net-pci,netdev=net0,disable-modern=off,disable-legacy=on"
else
    echo "Warning: 'user' network backend not available, falling back to tap" >&2
    NETWORK_OPTS="-netdev tap,id=net0 -device virtio-net-pci,netdev=net0,disable-modern=off,disable-legacy=on"
fi

# If cloud-localds exists, init the cloud-init drive
if command -v cloud-localds >/dev/null 2>&1; then
    echo "cloud-localds found, generating cloud-init.iso..."
    cloud-localds ./assets/cloud-init.iso ./user-data.yaml ./meta-data.yaml
else
    echo "cloud-localds not found, skipping cloud-init.iso generation."
fi

qemu-system-aarch64 \
  -M virt \
  -drive if=pflash,format=raw,readonly=on,file=./assets/edk2-aarch64-code.fd \
  -drive if=pflash,format=raw,file=./assets/edk2-arm-vars.fd \
  -cpu ${CPU_TYPE} \
  ${ACCELERATOR} \
  -m ${VM_MEMORY} \
  -smp ${VM_CPU},sockets=1,cores=${VM_CPU},threads=1 \
  ${GRAPHICS_OPTS} \
  -serial mon:stdio \
  -drive file=./assets/${DISTRO}-${ARCH}.qcow2,format=qcow2,if=virtio,cache=writethrough \
  -cdrom ./assets/cloud-init.iso \
  ${NETWORK_OPTS}
