#!/bin/bash

SERVICE_NAME="nvidia-blocker"
MODPROBE_CONF="/etc/modprobe.d/disable-nvidia.conf"

if [[ "$EUID" -ne 0 ]]; then
  echo "[ERROR] Please run this script with sudo:"
  echo "  sudo $0 on   # to enable GPU"
  echo "  sudo $0 off  # to disable GPU"
  exit 1
fi

case "$1" in
  off)
    echo "[INFO] Disabling NVIDIA driver for next boot..."
    systemctl enable $SERVICE_NAME
    echo "[✓] NVIDIA driver will be disabled on next reboot."
    ;;
  on)
    echo "[INFO] Re-enabling NVIDIA driver for next boot..."
    sudo systemctl disable $SERVICE_NAME
    rm -f "$MODPROBE_CONF"
    echo "[✓] NVIDIA driver will be enabled on next reboot."
    ;;
  *)
    echo "Usage: sudo $0 on|off"
    exit 1
    ;;
esac
