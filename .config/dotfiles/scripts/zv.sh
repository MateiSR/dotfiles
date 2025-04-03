#!/bin/bash
SESSION="dev"

# If script flag is -r, restart the session
if [ "$1" == "-r" ] ; then
    zellij kill-session $SESSION
fi

# If script flag is -k, kill the session
if [ "$1" == "-k" ] ; then
    zellij kill-session $SESSION
    exit 0
fi

# Check if session exists
if ! zellij list-sessions | grep -q "$SESSION"; then
    # Create a new session with a layout
    zellij --layout dev-layout
else
    # Attach to existing session
    zellij attach $SESSION
    exit 0
fi
