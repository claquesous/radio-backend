+#!/bin/bash
+set -e
+
+NEXT_DIR="/opt/claqradio/radio-backend/next"
+
+if [ -L "$NEXT_DIR" ] || [ -d "$NEXT_DIR" ]; then
+  rm -rf "$NEXT_DIR"
+fi
+
+mkdir -p "$NEXT_DIR"
