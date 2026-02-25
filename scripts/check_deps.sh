#!/usr/bin/env bash
set -euo pipefail

need() {
  local bin="$1"
  if ! command -v "$bin" >/dev/null 2>&1; then
    echo "error: missing dependency: $bin" >&2
    exit 2
  fi
}

need bash
need git
need rg
