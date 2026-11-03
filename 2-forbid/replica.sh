#!/usr/bin/env bash
# Starts a throwaway Postgres, runs every attempt in attempts.tsv as three different agents,
# and prints, for each one, whether the orders table survived:
#
#   open     no protection: the agent's role owns the table (the control: every attempt works)
#   setting  the agent may write, but its role defaults to read-only transactions
#   grant    the agent's role was only granted SELECT, like a read-only replica
#
# Output: one line per attempt, "<name> <open> <setting> <grant>", each "intact" or "destroyed".
set -euo pipefail
cd "$(dirname "$0")"

bin=$(dirname "$(command -v initdb || ls /usr/lib/postgresql/*/bin/initdb | tail -1)")
data=$(mktemp -d)
"$bin/initdb" -D "$data" -A trust -U postgres >/dev/null
"$bin/pg_ctl" -D "$data" -o "-k $data -c listen_addresses=''" -l "$data/log" -w start >/dev/null
trap '"$bin/pg_ctl" -D "$data" -m immediate stop >/dev/null; rm -rf "$data"' EXIT

export PGHOST=$data PGDATABASE=postgres
admin() { PGOPTIONS="-c client_min_messages=warning" psql -X -q -v ON_ERROR_STOP=1 -U postgres "$@"; }

admin <<'SQL'
CREATE ROLE agent_open LOGIN;
CREATE ROLE agent_setting LOGIN;
ALTER ROLE agent_setting SET default_transaction_read_only = on;
CREATE ROLE agent_grant LOGIN;
SQL

reset() {
  admin <<'SQL'
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (id int PRIMARY KEY, total int NOT NULL);
INSERT INTO orders VALUES (1, 50), (2, 250), (3, 1200);
ALTER TABLE orders OWNER TO agent_open;
GRANT ALL ON orders TO agent_setting;
GRANT SELECT ON orders TO agent_grant;
SQL
}

survived() {
  local state
  state=$(admin -At -c "SELECT count(*) || ':' || sum(total) FROM orders" 2>/dev/null || true)
  [[ $state == "3:1500" ]] && echo intact || echo destroyed
}

tail -n +2 attempts.tsv | while IFS=$'\t' read -r name _hook _open _setting _grant command; do
  results=()
  for role in agent_open agent_setting agent_grant; do
    reset
    PGUSER=$role bash -c "$command" </dev/null >/dev/null 2>&1 || true
    results+=("$(survived)")
  done
  echo "$name ${results[*]}"
done
