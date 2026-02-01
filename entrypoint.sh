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

  # Download archive
  curl -sL "$OPENCLAW_RESTORE_URL" -o /tmp/restore.archive

  # Extract based on file type
  cd "$OPENCLAW_STATE_DIR"
  echo "[restore] Extracting to $OPENCLAW_STATE_DIR..."

  # Check if it's a tar.gz or zip
  if file /tmp/restore.archive | grep -q "gzip"; then
    echo "[restore] Detected tar.gz archive"
    tar -xzf /tmp/restore.archive
  else
    echo "[restore] Detected zip archive"
    # Try with backslash conversion first, fallback to normal unzip
    if ! unzip -o -: /tmp/restore.archive 2>/dev/null; then
      echo "[restore] Fallback to standard unzip..."
      unzip -o /tmp/restore.archive
    fi
  fi

  echo "[restore] Extraction complete."
  echo "[restore] Workspace contents:"
  ls -la "$OPENCLAW_STATE_DIR/workspace/" 2>/dev/null || echo "[restore] No workspace dir found"

  # Restore the original openclaw.json (don't use the one from backup)
  if [ -f /tmp/openclaw.json.backup ]; then
    cp /tmp/openclaw.json.backup "$OPENCLAW_STATE_DIR/openclaw.json"
    echo "[restore] Preserved existing openclaw.json config"
  fi

  # Mark as restored (with URL-specific marker)
  touch "$RESTORE_MARKER"

  # Cleanup
  rm -f /tmp/restore.archive /tmp/openclaw.json.backup

  echo "[restore] Session restored successfully!"
fi

# Start the server
exec node src/server.js
