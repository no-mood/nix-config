#!/usr/bin/env bash
# Interactive NixOS deployment workflow
# Usage: deploy-host <hostname>
set -euo pipefail

# Available hosts
available_hosts="dra tau lyr installer"

# Global variables
hostname=""
temp=""
host_dir=""

show_usage() {
  echo "Usage: deploy-host <hostname>"
  echo
  echo "Available hosts: $available_hosts"
  echo
  echo "Examples:"
  echo "  deploy-host dra"
  echo "  deploy-host tau"
  echo "  deploy-host lyr"
  echo "  deploy-host installer"
}

# Initialize temp directory and cleanup
init_temp() {
  temp=$(mktemp -d)
  install -d -m755 "$temp/etc/ssh"
  echo "Using temp directory: $temp"
}

cleanup_temp() {
  if [[ -n "$temp" && -d "$temp" ]]; then
    rm -rf "$temp"
    echo "Cleaned up temp directory"
  fi
}

# Generate SSH host keys
generate_host_keys() {
  echo "Generating SSH host keys for $hostname..."
  echo "(Press Ctrl+C to cancel and return to menu)"

  # Trap CTRL+C to return gracefully
  trap 'echo; echo "Cancelled. Returning to menu..."; return 1' INT

  # Generate keys in temp directory
  ssh-keygen -t ed25519 -f "$temp/etc/ssh/ssh_host_ed25519_key" -N "" -C "root@$hostname"

  # Copy public key to host directory for persistence
  mkdir -p "$host_dir"
  cp "$temp/etc/ssh/ssh_host_ed25519_key.pub" "$host_dir/ssh_host_ed25519_key.pub"

  # Reset trap
  trap - INT

  echo "SSH keys generated successfully!"
  echo "Public key saved to $host_dir/ssh_host_ed25519_key.pub"
}

# Show Age key for sops-nix
show_age_key() {
  echo "Getting Age key for $hostname..."
  echo "(Press Ctrl+C to cancel and return to menu)"

  # Trap CTRL+C to return gracefully
  trap 'echo; echo "Cancelled. Returning to menu..."; return 1' INT

  local key_file="$temp/etc/ssh/ssh_host_ed25519_key.pub"
  if [[ ! -f "$key_file" ]]; then
    # Try to load from persistent location
    local persistent_key="$host_dir/ssh_host_ed25519_key.pub"
    if [[ -f "$persistent_key" ]]; then
      echo "Loading existing public key..."
      cp "$persistent_key" "$key_file"
    else
      echo "No SSH public key found. Generate keys first."
      trap - INT
      return 1
    fi
  fi

  echo "Age public key for $hostname:"
  ssh-to-age -i "$key_file"
  echo
  echo "Remember to:"
  echo "   1. Add this Age key to .sops.yaml"
  echo "   2. Run: sops updatekeys nixos/hosts/common/secrets.yaml"
  echo "   3. Run: sops updatekeys nixos/hosts/$hostname/secrets.yaml"
  echo "   4. Commit the updated secrets.yaml files"

  # Reset trap
  trap - INT
}

# Test configuration in VM
test_vm() {
  echo "Starting VM test for $hostname..."
  echo "This will create an interactive VM where you can manually test the full disk layout and system config."
  echo "(Press Ctrl+C to cancel and return to menu)"

  # Trap CTRL+C to return gracefully
  trap 'echo; echo "Cancelled. Returning to menu..."; return 1' INT

  if nix run -L ".#nixosConfigurations.$hostname.config.system.build.vmWithDisko"; then
    echo "VM test completed"
    trap - INT
    return 0
  else
    echo "VM test failed"
    trap - INT
    return 1
  fi
}

# Quick configuration check
dry_run_test() {
  echo "Checking configuration for $hostname..."
  echo "This runs nixos-anywhere's automated test (installTest) without an interactive VM."
  echo "(Press Ctrl+C to cancel and return to menu)"

  # Trap CTRL+C to return gracefully
  trap 'echo; echo "Cancelled. Returning to menu..."; return 1' INT

  if nixos-anywhere --flake ".#$hostname" --vm-test; then
    echo "Configuration check passed"
    trap - INT
    return 0
  else
    echo "Configuration check failed"
    trap - INT
    return 1
  fi
}

# Deploy to remote host
deploy_nixos() {
  local ip_address="$1"
  shift
  local extra_args=("$@")

  # Ensure SSH keys are in temp directory
  if [[ ! -f "$temp/etc/ssh/ssh_host_ed25519_key" ]]; then
    echo "SSH keys not found in temp directory. Regenerating or loading..."

    # Try to load from persistent location first
    local persistent_private="$host_dir/ssh_host_ed25519_key"
    local persistent_public="$host_dir/ssh_host_ed25519_key.pub"

    if [[ -f "$persistent_public" ]]; then
      echo "Loading existing SSH keys..."
      cp "$persistent_public" "$temp/etc/ssh/ssh_host_ed25519_key.pub"
      chmod 644 "$temp/etc/ssh/ssh_host_ed25519_key.pub"

      if [[ -f "$persistent_private" ]]; then
        cp "$persistent_private" "$temp/etc/ssh/ssh_host_ed25519_key"
        chmod 600 "$temp/etc/ssh/ssh_host_ed25519_key"
      else
        echo "Warning: Private key not found. Keys may need to be regenerated."
        return 1
      fi
    else
      echo "No existing keys found. Please generate keys first."
      return 1
    fi
  fi

  echo "SSH host keys ready for deployment."
  echo "Deploying $hostname to $ip_address..."

  # Deploy with nixos-anywhere
  nix run github:nix-community/nixos-anywhere -- \
    --extra-files "$temp" \
    --generate-hardware-config nixos-generate-config ./nixos/hosts/"$hostname"/hardware-configuration.nix \
    --flake ".#$hostname" \
    --target-host "root@$ip_address" \
    "${extra_args[@]}"
}

# Show main menu
show_menu() {
  echo "=================================="
  echo "NixOS Deployment for: $hostname"
  echo "=================================="
  echo "Actions:"
  echo "  g) Generate SSH host keys"
  echo "  a) Show Age key for host"
  echo "  t) Test configuration in VM"
  echo "  c) Check configuration (dry-run)"
  echo "  d) Deploy to remote host"
  echo "  q) Quit"
  echo
}

# Main script logic
main() {
  # Check if hostname argument provided
  if [[ $# -eq 0 ]]; then
    echo "Error: hostname required"
    echo
    show_usage
    exit 1
  fi

  # Validate hostname
  hostname="$1"
  if [[ ! "$available_hosts" =~ $hostname ]]; then
    echo "Error: unknown hostname '$hostname'"
    echo
    show_usage
    exit 1
  fi

  # Set up directories
  host_dir="./nixos/hosts/$hostname"

  # Initialize temp directory
  init_temp
  trap cleanup_temp EXIT

  # Interactive menu loop
  while true; do
    show_menu
    echo -n "Choose action: "
    read -r action

    case $action in
      g|G)
        if generate_host_keys; then
          echo "Keys generated successfully!"
        else
          echo "Failed to generate keys"
        fi
        ;;

      a|A)
        if show_age_key; then
          echo "Age key displayed successfully"
        else
          echo "Failed to get Age key"
        fi
        ;;

      t|T)
        test_vm
        ;;

      c|C)
        dry_run_test
        ;;

      d|D)
        echo "(Press Ctrl+C to cancel and return to menu)"

        # Trap CTRL+C to return gracefully
        trap 'echo; echo "Cancelled. Returning to menu..."; continue' INT

        echo -n "Enter target IP address: "
        read -r ip_address
        if [[ -z "$ip_address" ]]; then
          echo "IP address required"
          trap - INT
          continue
        fi

        # Build the complete nixos-anywhere command
        full_command="nixos-anywhere --extra-files \$temp --generate-hardware-config nixos-generate-config ./nixos/hosts/$hostname/hardware-configuration.nix --flake \".#$hostname\" --target-host \"root@$ip_address\""

        echo
        echo "=== nixos-anywhere Command ==="
        echo "Edit the complete command below (use arrows, backspace, etc.):"
        echo "(Press Ctrl+C to cancel and return to menu)"
        echo
        echo -n "Command: "
        read -e -i "$full_command" final_command

        echo
        echo "Command to execute:"
        echo "$final_command"
        echo
        echo "Make sure you have:"
        echo "   1. Generated SSH host keys"
        echo "   2. Updated .sops.yaml with Age key"
        echo "   3. Run: sops updatekeys nixos/hosts/common/secrets.yaml"
        echo "   4. Run: sops updatekeys nixos/hosts/$hostname/secrets.yaml"
        echo
        echo -n "Continue with deployment? (y/N): "
        read -r confirm

        # Reset trap
        trap - INT

        if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
          echo "Starting deployment..."
          echo "Executing: $final_command"
          if eval "$final_command"; then
            echo "Deployment completed successfully!"
          else
            echo "Deployment failed"
          fi
        else
          echo "Deployment cancelled"
        fi
        ;;

      q|Q)
        echo "Goodbye!"
        exit 0
        ;;

      *)
        echo "Invalid action. Please choose g/a/t/c/d/q."
        ;;
    esac

    echo
    echo -n "Press Enter to continue..."
    read -r
    echo
  done
}

# Run main function with all arguments
main "$@"
