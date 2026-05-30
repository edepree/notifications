#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<EOF
Usage:
  $0 USER PASSWORD admin
  $0 USER PASSWORD all <ro|wo|rw>
  $0 USER PASSWORD topic <ro|wo|rw> TOPIC

Examples:
  $0 backupbot SecretPass admin
  $0 reader SecretPass all ro
  $0 appuser SecretPass topic rw alerts
EOF
    exit 1
}

[[ $# -lt 3 ]] && usage

USER_NAME="$1"
PASSWORD="$2"
MODE="$3"

# create user if it doesn't exist
if ! ntfy user list | grep -q "^user ${USER_NAME} "; then
    echo "Creating user: ${USER_NAME}"

    if [[ "$MODE" == "admin" ]]; then
        NTFY_PASSWORD="$PASSWORD" \
            ntfy user add --role=admin "$USER_NAME"
    else
        NTFY_PASSWORD="$PASSWORD" \
            ntfy user add "$USER_NAME"
    fi
else
    echo "User exists, updating password"

    NTFY_PASSWORD="$PASSWORD" \
        ntfy user change-pass "$USER_NAME"

    if [[ "$MODE" == "admin" ]]; then
        ntfy user change-role "$USER_NAME" admin
    fi
fi

case "$MODE" in
    admin)
        echo "Granted admin role (full access to all topics)"
        ;;

    all)
        [[ $# -eq 4 ]] || usage

        ACCESS="$4"
        echo "Granting ${ACCESS} access to all topics"
        ntfy access "$USER_NAME" "*" "$ACCESS"
        ;;

    topic)
        [[ $# -eq 5 ]] || usage

        ACCESS="$4"
        TOPIC="$5"

        echo "Granting ${ACCESS} access to topic ${TOPIC}"
        ntfy access "$USER_NAME" "$TOPIC" "$ACCESS"
        ;;

    *)
        usage
        ;;
esac

echo
echo "Current user configuration:"
ntfy user list
echo
echo "Access rules:"
ntfy access "$USER_NAME"