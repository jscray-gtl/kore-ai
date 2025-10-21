#!/bin/bash

# Upload test file to Kore.ai to get fileName ID
# This must be done before importing the test suite

echo "============================================"
echo "Step 1: Upload Test File to Get File ID"
echo "============================================"

# Check if JWT token is set
if [ -z "$kore_jwt_token" ]; then
    echo "ERROR: JWT token not set. Please set it with:"
    echo "export kore_jwt_token='your_jwt_token_here'"
    exit 1
fi

# Configuration
STREAM_ID="st-948507fe-03c3-5afe-b3ca-3886049737bb"
HOST="https://platform.kore.ai"
TEST_FILE_PATH="/Users/jscray/Documents/workspace/kore-ai/tests/artifacts/test_success.json"

# Check if test file exists
if [ ! -f "$TEST_FILE_PATH" ]; then
    echo "ERROR: Test file not found at: $TEST_FILE_PATH"
    exit 1
fi

echo "Uploading file: $TEST_FILE_PATH"
echo "Stream ID: $STREAM_ID"
echo ""

# Upload the file (using bot endpoint like the working example)
curl --location --request POST "${HOST}/api/public/bot/${STREAM_ID}/file/upload" \
--header "auth: $kore_jwt_token" \
--header 'Content-Type: multipart/form-data' \
--form "file=@${TEST_FILE_PATH}"

echo ""
echo ""
echo "============================================"
echo "Copy the fileName from the response above"
echo "and use it in the import script"
echo "============================================"
