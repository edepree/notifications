#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<EOF
Usage:
  $0 USERNAME admin
  $0 USERNAME all <ro|wo|rw>
  $0 USERNAME topic <ro|wo|rw> TOPIC

Examples:
  $0 backupbot admin
  $0 reader all ro
  $0 appuser topic rw alerts

The password will be prompted for securely.
EOF
    exit 1
}

cleanup() {
    unset PASSWORD PASSWORD_CONFIRM
}
trap cleanup EXIT

validate_access() {
    case "$1" in
        ro|wo|rw) ;;
        *)
            echo "Error: access must be one of: ro, wo, rw" >&2
            exit 1
            ;;
    esac
}

[[ $# -lt 2 ]] && usage

USERNAME="$1"
MODE="$2"

# Prompt for password securely
read -r -s -p "Password: " PASSWORD
echo
read -r -s -p "Confirm password: " PASSWORD_CONFIRM
echo

if [[ "$PASSWORD" != "$PASSWORD_CONFIRM" ]]; then
    echo "Error: passwords do not match" >&2
    exit 1
fi

# Create user if it doesn't exist
if ! ntfy user list | grep -Fq "user ${USERNAME} "; then
    echo "Creating user: ${USERNAME}"

    if [[ "$MODE" == "admin" ]]; then
        NTFY_PASSWORD="$PASSWORD" \
            ntfy user add --role=admin "$USERNAME"
    else
        NTFY_PASSWORD="$PASSWORD" \
            ntfy user add "$USERNAME"
    fi
else
    echo "User exists, updating password"

    NTFY_PASSWORD="$PASSWORD" \
        ntfy user change-pass "$USERNAME"

    if [[ "$MODE" == "admin" ]]; then
        ntfy user change-role "$USERNAME" admin
    fi
fi

case "$MODE" in
    admin)
        [[ $# -eq 2 ]] || usage
        echo "Granted admin role (full access to all topics)"
        ;;

    all)
        [[ $# -eq 3 ]] || usage

        ACCESS="$3"
        validate_access "$ACCESS"

        echo "Granting ${ACCESS} access to all topics"
        ntfy access "$USERNAME" "*" "$ACCESS"
        ;;

    topic)
        [[ $# -eq 4 ]] || usage

        ACCESS="$3"
        TOPIC="$4"

        validate_access "$ACCESS"

        echo "Granting ${ACCESS} access to topic ${TOPIC}"
        ntfy access "$USERNAME" "$TOPIC" "$ACCESS"
        ;;

    *)
        usage
        ;;
esac

echo "Done."