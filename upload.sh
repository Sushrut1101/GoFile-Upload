#!/bin/bash

# File to Upload
FILE="@$1"

# Find the Best server to upload
SERVER=$(curl -s https://apiv2.gofile.io/getServer | jq  -r '.data|.server')

UPLOAD=$(curl -F file=${FILE} https://${SERVER}.gofile.io/uploadFile)

# Print the link!
echo $UPLOAD

echo " "
