#!/bin/bash
set -e

# Restore session from URL if OPENCLAW_RESTORE_URL is set
if [ -n "$OPENCLAW_RESTORE_URL" ] && [ ! -f "$OPENCLAW_STATE_DIR/.restored" ]; then
  echo "[restore] Downloading session from $OPENCLAW_RESTORE_URL..."

  # Create state directory if it doesn't exist
  mkdir -p "$OPENCLAW_STATE_DIR"

  # Download and extract
  curl -sL "$OPENCLAW_RESTORE_URL" -o /tmp/restore.zip

  # Unzip to state directory (overwrite existing files)
  cd "$OPENCLAW_STATE_DIR"
  unzip -o /tmp/restore.zip

  # Mark as restored
  touch "$OPENCLAW_STATE_DIR/.restored"

  # Cleanup
  rm /tmp/restore.zip

  echo "[restore] Session restored successfully!"
fi

# Start the server
exec node src/server.js
