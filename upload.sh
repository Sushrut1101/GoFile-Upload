#!/usr/bin/env bash
# Updated GoFile upload script using the latest API
# Usage:
#   ./upload.sh <file_path> [folder_id] [api_token]

set -e

FILE="$1"
FOLDER_ID="$2"
API_TOKEN="$3"

if [[ -z "$FILE" ]]; then
  echo "Usage: $0 <file_path> [folder_id] [api_token]"
  exit 1
fi

if [[ ! -f "$FILE" ]]; then
  echo "Error: File \"$FILE\" does not exist."
  exit 1
fi

# Latest upload endpoint
UPLOAD_URL="https://upload.gofile.io/uploadfile"

# Optional auth header
AUTH_HEADER=()
if [[ -n "$API_TOKEN" ]]; then
  AUTH_HEADER=( -H "Authorization: Bearer $API_TOKEN" )
fi

# Build the form data
FORM=( -F "file=@${FILE}" )
if [[ -n "$FOLDER_ID" ]]; then
  FORM+=( -F "folderId=${FOLDER_ID}" )
fi

echo "Uploading \"$FILE\" to GoFile..."

RESPONSE=$(curl -s "${AUTH_HEADER[@]}" "${FORM[@]}" "$UPLOAD_URL")

echo "Raw response: $RESPONSE"

# If jq is available, parse response
if command -v jq >/dev/null 2>&1; then
  STATUS=$(echo "$RESPONSE" | jq -r '.status // empty')
  
  if [[ "$STATUS" != "ok" && "$STATUS" != "success" ]]; then
    echo "Upload failed or unexpected status: $STATUS"
    exit 1
  fi

  # Try to extract directLink or downloadPage
  LINK=$(echo "$RESPONSE" | jq -r '.data.directLink // .data.downloadPage // empty')
  
  if [[ -n "$LINK" ]]; then
    echo "Download link: $LINK"
  else
    echo "Upload complete but no link found in response."
  fi
else
  echo "jq not found, showing raw response only."
fi
