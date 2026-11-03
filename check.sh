#!/usr/bin/env bash
# Checks the three steps of the article:
#
#   2-forbid      the hook blocks exactly what attempts.tsv says, and against a real Postgres
#                 each attempt destroys or leaves the table as attempts.tsv says
#   3-impossible  the agent's example compiles, and every file in rejected/ fails with the
#                 error announced on its "-- expects:" line
#
# 1-ask has nothing to check. That's the point.
set -euo pipefail
cd "$(dirname "$0")"
failures=0
ok()   { echo "ok   $*"; }
fail() { echo "FAIL $*"; failures=1; }

echo "== 2-forbid: the hook"
while IFS=$'\t' read -r name hook _open _setting _grant command; do
  call=$(python3 -c 'import json, sys; print(json.dumps({"tool_name": "Bash", "tool_input": {"command": sys.argv[1]}}))' "$command")
  if python3 2-forbid/hook.py <<<"$call" 2>/dev/null; then got=passes; else got=blocks; fi
  [[ $got == "$hook" ]] && ok "$name: the hook $got" || fail "$name: the hook $got, expected $hook"
done < <(tail -n +2 2-forbid/attempts.tsv)

echo "== 2-forbid: the database"
if command -v initdb >/dev/null || ls /usr/lib/postgresql/*/bin/initdb >/dev/null 2>&1; then
  results=$(2-forbid/replica.sh)
else
  results=$(docker run --rm --user postgres --entrypoint bash -v "$PWD:/work:ro" postgres:17 /work/2-forbid/replica.sh)
fi
while IFS=$'\t' read -r name _hook open setting grant _command; do
  expected="$name $open $setting $grant"
  got=$(grep "^$name " <<<"$results" || true)
  [[ $got == "$expected" ]] && ok "$name: open $open, setting $setting, grant $grant" \
                            || fail "$name: expected '$expected', got '$got'"
done < <(tail -n +2 2-forbid/attempts.tsv)

echo "== 3-impossible"
cd 3-impossible
cabal build all -v0
ok "the library and examples/Main.hs compile"
for f in rejected/*.hs; do
  expected=$(sed -n 's/^-- expects: //p' "$f")
  if output=$(cabal exec -v0 -- ghc -XHaskell2010 -XSafe -fno-code -package impossible \
                -outputdir "$(mktemp -d)" "$f" 2>&1); then
    fail "$f compiled, and it shouldn't"
  elif grep -qF "$expected" <<<"$output"; then
    ok "$f doesn't compile: $expected"
  else
    fail "$f doesn't compile, but not for the expected reason:"; echo "$output"
  fi
done

exit $failures
