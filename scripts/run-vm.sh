#!/bin/bash

ARCH="arm64" # TODO: use env var
DISTRO="noble"
VM_MEMORY="8G"
VM_CPU="4"
HEADLESS="1" # Set to 1 for headless mode


# Detect accelerator
if [[ "$(uname)" == "Darwin" ]]; then
    ACCELERATOR=" -accel hvf "
elif [[ "$(uname)" == "Linux" ]]; then
    ACCELERATOR=" -accel kvm "
else
    ACCELERATOR=""
fi

# Graphics options
if [[ "${HEADLESS}" == "1" ]]; then
    GRAPHICS_OPTS="-nographic"
else
    GRAPHICS_OPTS="-device virtio-gpu-pci -display default,show-cursor=on -device qemu-xhci -device usb-kbd -device usb-tablet -device intel-hda -device hda-duplex"
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
  -cpu host \
  ${ACCELERATOR} \
  -m ${VM_MEMORY} \
  -smp ${VM_CPU},sockets=1,cores=${VM_CPU},threads=1 \
  ${GRAPHICS_OPTS} \
  -serial mon:stdio \
  -drive file=./assets/${DISTRO}-${ARCH}.qcow2,format=qcow2,if=virtio,cache=writethrough \
  -cdrom ./assets/cloud-init.iso \
  -netdev user,id=net0,hostfwd=tcp::10022-:22,hostfwd=tcp::8080-:80 \
  -device virtio-net-device,netdev=net0
