#!/usr/bin/env bash
# Build NixOS installer ISO with custom tools
set -euo pipefail

echo "Building installer ISO..."
echo "This will take a while and requires significant disk space."
echo

nix build ".#nixosConfigurations.installer.config.system.build.isoImage" -L

if [[ $? -eq 0 ]]; then
  echo "ISO built successfully!"
  echo "Location: $(ls -la result/iso/*.iso)"
  echo
  echo "To write to USB:"
  echo "  sudo dd if=result/iso/*.iso of=/dev/sdX bs=4M status=progress"
else
  echo "ISO build failed"
  exit 1
fi
