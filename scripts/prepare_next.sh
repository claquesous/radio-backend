#!/bin/bash
set -e

NEXT_DIR="/opt/claqradio/radio-backend/next/tmp"

if [ -L "$NEXT_DIR" ] || [ -d "$NEXT_DIR" ]; then
  rm -rf "$NEXT_DIR"
fi

mkdir -p "$NEXT_DIR"
