#!/usr/bin/env bash
set -euo pipefail

USER="$1"
PASSWORD="$2"
MODE="$3"        # all | topic
ACCESS="$4"      # read | write | rw
TOPIC="${5:-}"

if [[ -z "$USER" || -z "$PASSWORD" || -z "$MODE" || -z "$ACCESS" ]]; then
  echo "Usage:"
  echo "  $0 <user> <password> <all|topic> <read|write|rw> [topic]"
  exit 1
fi

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