#!/bin/bash
# Launch REA's stdio MCP server from this checkout. Build output goes to
# stderr so stdout stays reserved for the MCP protocol.
set -euo pipefail

project_dir="$(cd "$(dirname "$0")/../.." && pwd)"

if [ ! -f "$project_dir/dist/main.js" ] || [ ! -f "$HOME/.local/share/rea/android/jadx-headless-mcp-0.7.1-all.jar" ]; then
  CLAUDE_CODE_REMOTE=true CLAUDE_ENV_FILE= "$project_dir/.claude/hooks/session-start.sh" >&2
fi

export REA_JADX_MCP_JAR="${REA_JADX_MCP_JAR:-$HOME/.local/share/rea/android/jadx-headless-mcp-0.7.1-all.jar}"
exec node "$project_dir/scripts/rea.mjs" mcp
