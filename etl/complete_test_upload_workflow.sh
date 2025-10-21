#!/bin/bash

# Complete workflow to upload and import test cases to Kore.ai
# Based on: https://docs.kore.ai/xo/apis/automation/api-list/#bot-definition-apis

echo "============================================"
echo "Kore.ai Test Suite Upload & Import Workflow"
echo "============================================"

# Configuration
STREAM_ID="st-948507fe-03c3-5afe-b3ca-3886049737bb"
HOST="https://platform.kore.ai"
TEST_FILE_PATH="/Users/jscray/Documents/workspace/kore-ai/tests/artifacts/test_success.json"

# Check if JWT token is set
if [ -z "$kore_jwt_token" ]; then
    echo "ERROR: JWT token not set. Please set it with:"
    echo "export kore_jwt_token='your_jwt_token_here'"
    exit 1
fi

# Check if test file exists
if [ ! -f "$TEST_FILE_PATH" ]; then
    echo "ERROR: Test file not found at: $TEST_FILE_PATH"
    exit 1
fi

echo "Configuration:"
echo "  Host: $HOST"
echo "  Stream ID: $STREAM_ID"
echo "  Test File: $TEST_FILE_PATH"
echo "  JWT Token: Set (${#kore_jwt_token} characters)"
echo ""

# Step 1: Upload the test file
echo "============================================"
echo "Step 1: Uploading Test File"
echo "============================================"

UPLOAD_RESPONSE=$(curl -s --location --request POST "${HOST}/api/public/bot/${STREAM_ID}/file/upload" \
--header "auth: $kore_jwt_token" \
--header 'Content-Type: multipart/form-data' \
--form "file=@${TEST_FILE_PATH}")

echo "Upload Response:"
echo "$UPLOAD_RESPONSE"
echo ""

# Extract fileName from response (assuming JSON response with fileName field)
FILE_ID=$(echo "$UPLOAD_RESPONSE" | grep -o '"fileName":"[^"]*"' | cut -d'"' -f4)

if [ -z "$FILE_ID" ]; then
    echo "ERROR: Could not extract fileName from upload response"
    echo "Please check the upload response above for errors"
    exit 1
fi

echo "✅ File uploaded successfully!"
echo "File ID: $FILE_ID"
echo ""

# Step 2: Import the test suite
echo "============================================"
echo "Step 2: Importing Test Suite"
echo "============================================"

IMPORT_RESPONSE=$(curl -s --location --request POST "${HOST}/api/public/bot/${STREAM_ID}/conversation/testsuite/import" \
--header "auth: $kore_jwt_token" \
--header 'bot-language: en' \
--header 'Content-Type: application/json' \
--data-raw '{
    "fileName": "'$FILE_ID'",
    "name": "UGHIP Test Suite",
    "tags": ["UGHIP", "UNL"],
    "description": "Extended UGHIP Test Case from test_success.json",
    "userEmailId": "botowner@domain.com"
}')

echo "Import Response:"
echo "$IMPORT_RESPONSE"
echo ""

# Extract dsId from response for status checking
DS_ID=$(echo "$IMPORT_RESPONSE" | grep -o '"dsId":"[^"]*"' | cut -d'"' -f4)

if [ -n "$DS_ID" ]; then
    echo "✅ Test suite import initiated successfully!"
    echo "Data Set ID: $DS_ID"
    echo ""
    echo "Use this dsId to check import status with the import status API"
else
    echo "⚠️  Import response received, but no dsId found"
    echo "Please check the response above for any errors"
fi

echo ""
echo "============================================"
echo "Workflow Complete"
echo "============================================"
