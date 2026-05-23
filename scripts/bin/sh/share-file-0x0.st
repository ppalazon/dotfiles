#!/bin/bash

set -euo pipefail

FILE=${1:-}
EXPIRATION=${2:-"12h"}

usage() {
cat <<EOF
Usage:
  $0 [options] <file-to-share>

Options:
  -x, --expiration   Expiration time        (default: $EXPIRATION, format: 12h, 30m, 1d)
  -h, --help         Show help

Arguments:
  file-to-share      Required file to upload
EOF
exit 0
}

## Parse options
PARSED=$(getopt \
  -o x:h \
  --long expiration:,help \
  -- "$@"
)

eval set -- "$PARSED"

while true; do
  case "$1" in
    -x|--expiration)
      EXPIRATION="$2"
      shift 2
      ;;
    -h|--help)
      usage
      ;;
    --)
      shift
      break
      ;;
    *)
      echo "Invalid option: $1"
      usage
      ;;
  esac
done

## Initial checks

if [[ $# -ne 1 ]]; then
  usage
fi

if [[ -z "$FILE" ]]; then
  echo "Usage: $0 [options] <file-to-share>"
  exit 1
fi

if [[ ! -f "$FILE" ]]; then
  echo "File not found: $FILE"
  exit 1
fi

SHARE_FILE_DIR="$HOME/.local/share/share-file"
mkdir -p "$SHARE_FILE_DIR"

UPLOADS_FILE="$SHARE_FILE_DIR/uploads.txt"

# Parse expiration option with default of 12 hours
if [[ "$EXPIRATION" =~ ^([0-9]+)([smhd])?$ ]]; then
  VALUE="${BASH_REMATCH[1]}"
  UNIT="${BASH_REMATCH[2]:-h}"
  case "$UNIT" in
    s) EXPIRATION_SECONDS=$((VALUE)) ;;
    m) EXPIRATION_SECONDS=$((VALUE * 60)) ;;
    h) EXPIRATION_SECONDS=$((VALUE * 3600)) ;;
    d) EXPIRATION_SECONDS=$((VALUE * 86400)) ;;
    *) echo "Invalid expiration unit: $UNIT" >&2; exit 1 ;;
  esac
else
  echo "Invalid expiration format: $EXPIRATION" >&2
  exit 1
fi

# Parse seconds to epoch time in millis for 0x0.st
EXPIRATION_EPOCH=$(( $(date +%s) + EXPIRATION_SECONDS ))
EXPIRATION_MILLIS=$((EXPIRATION_EPOCH * 1000))
EXPIRATION_DATE=$(date -d "@$EXPIRATION_EPOCH" +"%Y%m%d-%H%M%S")

FILENAME=$(basename "$FILE")

TMP=$(mktemp)

echo $TMP

TOKEN=$(
  curl -s -D - -o "$TMP" -F"file=@$FILE" https://0x0.st \
  | awk '/X-Token:/ {print $2}' \
  | tr -d '\r'
)

URL=$(cat "$TMP")

echo "$FILENAME\t$URL\t$TOKEN\t$EXPIRATION_DATE" >> "$UPLOADS_FILE"

echo "File shared successfully: $URL (expires on $EXPIRATION_DATE)"
