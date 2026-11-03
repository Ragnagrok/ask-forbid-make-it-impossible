#!/usr/bin/env python3
"""A Claude Code PreToolUse hook that blocks destructive SQL in Bash commands.

It reads the tool call as JSON on stdin and exits with 2 to block it, which is how
Claude Code hooks refuse an action. It's the hook most of us would write first:
a list of the words we don't want to see.
"""
import json
import re
import sys

FORBIDDEN = re.compile(r"\b(DELETE|DROP)\b", re.IGNORECASE)

call = json.load(sys.stdin)
if call.get("tool_name") == "Bash":
    command = call.get("tool_input", {}).get("command", "")
    match = FORBIDDEN.search(command)
    if match:
        print(f"Blocked: {match.group(0).upper()} is not allowed against the database.", file=sys.stderr)
        sys.exit(2)
sys.exit(0)
