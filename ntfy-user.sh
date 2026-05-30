#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 4 ]]; then
  echo "Usage:"
  echo "  $0 <user> <password> <all|topic> <read|write|rw> [topic]"
  exit 1
fi

USER="$1"
PASSWORD="$2"
MODE="$3"
ACCESS="$4"
TOPIC="${5:-}"

echo "Creating user: $USER"
ntfy user add "$USER" || true

echo "Setting password..."
ntfy user change-password "$USER" "$PASSWORD"

if [[ "$MODE" == "all" ]]; then
  echo "Granting $ACCESS access to ALL topics"
  ntfy access "$USER" "*" "$ACCESS"

elif [[ "$MODE" == "topic" ]]; then
  if [[ -z "$TOPIC" ]]; then
    echo "ERROR: topic required for topic mode"
    exit 1
  fi

  echo "Granting $ACCESS access to topic: $TOPIC"
  ntfy access "$USER" "$TOPIC" "$ACCESS"

else
  echo "Invalid mode: $MODE (use 'all' or 'topic')"
  exit 1
fi

echo "Done."