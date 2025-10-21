#!/bin/bash

# Final test script based on working example analysis

echo "============================================"
echo "Final API Test - Based on Working Example"
echo "============================================"

# Check JWT token
if [ -z "$kore_jwt_token" ]; then
    echo "❌ JWT token not set. Please set it with:"
    echo "export kore_jwt_token='your_actual_jwt_token_here'"
    exit 1
fi

STREAM_ID="st-948507fe-03c3-5afe-b3ca-3886049737bb"
HOST="https://platform.kore.ai"

echo "Using JWT token: ${kore_jwt_token:0:20}..."
echo "Stream ID: $STREAM_ID"
echo ""

# Test 1: Verify the working API call pattern
echo "1. Testing known working API (getSessions):"
curl -s --location 'https://platform.kore.ai/api/public/bot/st-948507fe-03c3-5afe-b3ca-3886049737bb/getSessions?containmentType=selfService&limit=1' \
--header "auth: $kore_jwt_token" \
--header 'Content-Type: application/json' \
--data '{
"skip" : 0,
"limit" : 1,
"dateFrom" : "2025-08-27",
"dateTo" : "2025-08-28"
}' | head -c 200

echo ""
echo ""

# Test 2: Test import API with stream endpoint (as per documentation)
echo "2. Testing import API (stream endpoint):"
curl -s --location --request POST 'https://platform.kore.ai/api/public/stream/st-948507fe-03c3-5afe-b3ca-3886049737bb/conversation/testsuite/import' \
--header "auth: $kore_jwt_token" \
--header 'bot-language: en' \
--header 'Content-Type: application/json' \
--data-raw '{
    "fileName": "placeholder_file_id",
    "name": "Test Suite",
    "tags": [],
    "description": "Test",
    "userEmailId": "test@example.com"
}' | head -c 200

echo ""
echo ""

# Test 3: Try file upload with bot endpoint (matching working pattern)
echo "3. Testing file upload (bot endpoint):"
curl -s --location --request POST "${HOST}/api/public/bot/${STREAM_ID}/file/upload" \
--header "auth: $kore_jwt_token" \
--header 'Content-Type: multipart/form-data' \
--form 'file=@tests/artifacts/test_success.json' | head -c 200

echo ""
echo ""

echo "============================================"
echo "Analysis:"
echo "- If test 1 works: JWT token is valid"
echo "- If test 2 works: Import API is accessible" 
echo "- If test 3 works: File upload endpoint found"
echo "============================================"

