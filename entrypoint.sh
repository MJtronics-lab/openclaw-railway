#!/bin/bash

# Restore session from URL if OPENCLAW_RESTORE_URL is set
# Use hash of URL as marker so changing URL triggers new restore
RESTORE_MARKER="$OPENCLAW_STATE_DIR/.restored-$(echo -n "$OPENCLAW_RESTORE_URL" | md5sum | cut -d' ' -f1)"
if [ -n "$OPENCLAW_RESTORE_URL" ] && [ ! -f "$RESTORE_MARKER" ]; then
  echo "[restore] Downloading session from $OPENCLAW_RESTORE_URL..."

  # Create state directory if it doesn't exist
  mkdir -p "$OPENCLAW_STATE_DIR"

  # Backup existing openclaw.json if it exists
  if [ -f "$OPENCLAW_STATE_DIR/openclaw.json" ]; then
    cp "$OPENCLAW_STATE_DIR/openclaw.json" /tmp/openclaw.json.backup
  fi

  # Download and extract
  curl -sL "$OPENCLAW_RESTORE_URL" -o /tmp/restore.zip

  # Unzip to state directory (overwrite existing files, convert backslashes)
  cd "$OPENCLAW_STATE_DIR"
  echo "[restore] Extracting to $OPENCLAW_STATE_DIR..."
  # Try with backslash conversion first, fallback to normal unzip
  if ! unzip -o -: /tmp/restore.zip 2>/dev/null; then
    echo "[restore] Fallback to standard unzip..."
    unzip -o /tmp/restore.zip
  fi
  echo "[restore] Extraction complete."

  # Restore the original openclaw.json (don't use the one from backup)
  if [ -f /tmp/openclaw.json.backup ]; then
    cp /tmp/openclaw.json.backup "$OPENCLAW_STATE_DIR/openclaw.json"
    echo "[restore] Preserved existing openclaw.json config"
  fi

  # Mark as restored (with URL-specific marker)
  touch "$RESTORE_MARKER"

  # Cleanup
  rm -f /tmp/restore.zip /tmp/openclaw.json.backup

  echo "[restore] Session restored successfully!"
fi

# Start the server
exec node src/server.js
