#!/bin/bash
# Prepare REA for Claude Code cloud sessions: build the local checkout and
# supply the pinned headless JADX engine used for Android APK analysis.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

project_dir="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
jadx_dir="$HOME/.local/share/rea/android"
jadx_jar="$jadx_dir/jadx-headless-mcp-0.7.1-all.jar"
jadx_url="https://github.com/1013503897/jadx-headless-mcp/releases/download/v0.7.1/jadx-headless-mcp-0.7.1-all.jar"
# Must match src/android/JadxRelease.ts.
jadx_sha256="6e5eacf500b64292bfb73c49797c1958f6ee44646e43e868039ae7feb573ff75"

# The MCP launcher may run this concurrently with the SessionStart hook.
exec 9>"${TMPDIR:-/tmp}/rea-session-start.lock"
flock 9

cd "$project_dir"
npm install --no-audit --no-fund
npm run build:cached

if ! echo "$jadx_sha256  $jadx_jar" | sha256sum -c --status - 2>/dev/null; then
  mkdir -p "$jadx_dir"
  curl -fsSL -o "$jadx_jar.partial" "$jadx_url"
  echo "$jadx_sha256  $jadx_jar.partial" | sha256sum -c --status -
  mv "$jadx_jar.partial" "$jadx_jar"
fi

if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  echo "export REA_JADX_MCP_JAR=\"$jadx_jar\"" >> "$CLAUDE_ENV_FILE"
fi
