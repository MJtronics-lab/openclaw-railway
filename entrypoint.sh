#!/bin/bash
set -e

# Restore session from URL if OPENCLAW_RESTORE_URL is set
if [ -n "$OPENCLAW_RESTORE_URL" ] && [ ! -f "$OPENCLAW_STATE_DIR/.restored" ]; then
  echo "[restore] Downloading session from $OPENCLAW_RESTORE_URL..."

  # Create state directory if it doesn't exist
  mkdir -p "$OPENCLAW_STATE_DIR"

  # Backup existing openclaw.json if it exists
  if [ -f "$OPENCLAW_STATE_DIR/openclaw.json" ]; then
    cp "$OPENCLAW_STATE_DIR/openclaw.json" /tmp/openclaw.json.backup
  fi

  # Download and extract
  curl -sL "$OPENCLAW_RESTORE_URL" -o /tmp/restore.zip

  # Unzip to state directory (overwrite existing files, but quietly)
  cd "$OPENCLAW_STATE_DIR"
  unzip -o -q /tmp/restore.zip

  # Restore the original openclaw.json (don't use the one from backup)
  if [ -f /tmp/openclaw.json.backup ]; then
    cp /tmp/openclaw.json.backup "$OPENCLAW_STATE_DIR/openclaw.json"
    echo "[restore] Preserved existing openclaw.json config"
  fi

  # Mark as restored
  touch "$OPENCLAW_STATE_DIR/.restored"

  # Cleanup
  rm -f /tmp/restore.zip /tmp/openclaw.json.backup

  echo "[restore] Session restored successfully!"
fi

# Start the server
exec node src/server.js
