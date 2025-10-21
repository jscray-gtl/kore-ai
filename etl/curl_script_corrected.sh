#!/bin/bash

# Original curl command for getting sessions (this one seems to work)
curl --location 'https://platform.kore.ai/api/public/bot/st-948507fe-03c3-5afe-b3ca-3886049737bb/getSessions?containmentType=selfService' \
--header "auth: $kore_jwt_token" \
--header 'Content-Type: application/json' \
--data '{
"skip" : 0,
"limit" : 100,
"dateFrom" : "2025-08-27",
"dateTo" : "2025-08-28"
}'

echo "============================================"
echo "Step 2: Import Test Suite API"
echo "============================================"

# Check if JWT token is set
if [ -z "$kore_jwt_token" ]; then
    echo "ERROR: JWT token not set. Please set it with:"
    echo "export kore_jwt_token='your_jwt_token_here'"
    exit 1
fi

# IMPORTANT: Replace the fileName below with the actual file ID from Step 1
FILE_ID="REPLACE_WITH_FILE_ID_FROM_UPLOAD"

if [ "$FILE_ID" = "REPLACE_WITH_FILE_ID_FROM_UPLOAD" ]; then
    echo "ERROR: Please replace FILE_ID with the actual file ID from the upload step"
    echo "Run upload_test_file.sh first to get the file ID"
    exit 1
fi

echo "Using File ID: $FILE_ID"
echo ""

# CORRECTED curl command for importing test suite
# Key fixes:
# 1. Changed /api/public/bot/ to /api/public/stream/ 
# 2. Changed {language-code} to actual language code 'en'
# 3. Changed fileName to file ID format (obtained from upload step)
curl --location --request POST 'https://platform.kore.ai/api/public/stream/st-948507fe-03c3-5afe-b3ca-3886049737bb/conversation/testsuite/import' \
--header "auth: $kore_jwt_token" \
--header 'bot-language: en' \
--header 'Content-Type: application/json' \
--data-raw '{
          "fileName": "'$FILE_ID'",
          "name": "UGHIP Test Suite",
          "tags" : ["UGHIP", "UNL"],
          "description" : "Extended UGHIP Test Case from test_success.json",
           "userEmailId" : "botowner@domain.com"
}'

echo ""
echo "============================================"
echo "Import Status Check"
echo "============================================"
echo "The response should include a dsId for checking import status"
echo "Use the dsId with the import status API to monitor progress"
