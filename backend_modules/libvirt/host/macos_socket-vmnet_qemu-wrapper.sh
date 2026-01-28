#!/usr/bin/env bash

# Detect Homebrew path or fall back to default
PREFIX="${HOMEBREW_PREFIX:-/opt/homebrew}"

REAL_QEMU="$PREFIX/bin/qemu-system-aarch64"
VMNET_CLIENT="$PREFIX/opt/socket_vmnet/bin/socket_vmnet_client"
SOCKET_PATH="$PREFIX/var/run/socket_vmnet"

# Ensure the client exists before trying to run
if [ ! -f "$VMNET_CLIENT" ]; then
    echo "Error: socket_vmnet_client not found at $VMNET_CLIENT" >&2
    exit 1
fi

# find next available FD
MAX_FD=$(ls /dev/fd | sort -n | tail -1)
NEXT_FD=$((MAX_FD + 1))

echo "Wrapper execution started at $(date)" > "$HOME/qemu_wrapper_debug.log"
echo "Arguments from libvirt: $@" >> "$HOME/qemu_wrapper_debug.log"
echo "Next FD number: $NEXT_FD" >> "$HOME/qemu_wrapper_debug.log"

# Execute QEMU and perform the redirection in the same command
# We use the descriptor number directly in the exec call.
# The "{NEXT_FD}<>$SOCKET_PATH" syntax opens the socket and assigns it to NEXT_FD
# for the duration of the REAL_QEMU process.
exec "$VMNET_CLIENT" "$SOCKET_PATH" "$REAL_QEMU" \
    -netdev "socket,id=vmn0,fd=$NEXT_FD" \
    "$@"
