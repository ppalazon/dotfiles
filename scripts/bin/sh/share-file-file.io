#!/bin/bash

set -euo pipefail

FILE=${1:-}
EXPIRATION=${2:-"1"}
MAX_DOWNLOADS=3
AUTO_DELETE=true

usage() {
cat <<EOF
Usage:
  $0 [options] <file-to-share>

Options:
  -x, --expiration      Expiration time        (default: $EXPIRATION, format: 4, 1w, 1M, 1y)
  -d, --downloads       Max downloads          (default: $MAX_DOWNLOADS)
  -n, --no-auto-delete  Avoid auto delete after max downloads (default: $AUTO_DELETE)
  -h, --help            Show help

Arguments:
  file-to-share      Required file to upload
EOF
exit 0
}

## Parse options
PARSED=$(getopt \
  -o x:d:nh \
  --long expiration:,downloads:,auto-delete,help \
  -- "$@"
)

eval set -- "$PARSED"

while true; do
  case "$1" in
    -x|--expiration)
      EXPIRATION="$2"
      shift 2
      ;;
    -d|--downloads)
      MAX_DOWNLOADS="$2"
      shift 2
      ;;
    -n|--no-auto-delete)
      AUTO_DELETE=true
      shift
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

UPLOADS_FILE="$SHARE_FILE_DIR/uploads-file-io.txt"

FILENAME=$(basename "$FILE")

JSON=$(curl -s -F"file=@$FILE" https://file.io/?expires=$EXPIRATION)

echo $JSON

URL=$(echo "$JSON" | jq -r '.link')
TOKEN=$(echo "$JSON" | jq -r '.key')
EXPIRATION_DATE=$(echo "$JSON" | jq -r '.expiry')

echo "$FILENAME\t$URL\t$TOKEN\t$EXPIRATION_DATE" >> "$UPLOADS_FILE"

echo "File shared successfully: $URL (expires on $EXPIRATION_DATE)"
