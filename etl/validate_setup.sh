#!/bin/bash

# Validation script to check setup before running the main workflow

echo "============================================"
echo "Kore.ai Setup Validation"
echo "============================================"

# Check JWT token
echo "1. JWT Token Check:"
if [ -z "$kore_jwt_token" ]; then
    echo "❌ JWT token not set"
    echo "   Run: export kore_jwt_token='your_token_here'"
    exit 1
else
    echo "✅ JWT token is set (${#kore_jwt_token} characters)"
    # Show first and last few characters for verification
    echo "   Token preview: ${kore_jwt_token:0:10}...${kore_jwt_token: -10}"
fi

echo ""

# Check test file
echo "2. Test File Check:"
TEST_FILE="/Users/jscray/Documents/workspace/kore-ai/tests/artifacts/test_success.json"
if [ ! -f "$TEST_FILE" ]; then
    echo "❌ Test file not found: $TEST_FILE"
    exit 1
else
    echo "✅ Test file found: $TEST_FILE"
    FILE_SIZE=$(wc -c < "$TEST_FILE")
    echo "   File size: $FILE_SIZE bytes"
    
    # Validate JSON format
    if command -v jq >/dev/null 2>&1; then
        if jq empty "$TEST_FILE" 2>/dev/null; then
            echo "✅ JSON format is valid"
        else
            echo "❌ Invalid JSON format"
        fi
    else
        echo "⚠️  jq not available, skipping JSON validation"
    fi
fi

echo ""

# Test basic connectivity
echo "3. API Connectivity Check:"
echo "Testing basic API connectivity..."

RESPONSE=$(curl -s -w "%{http_code}" --location --request GET 'https://platform.kore.ai/api/public/stream/st-948507fe-03c3-5afe-b3ca-3886049737bb/getSessions?containmentType=selfService&skip=0&limit=1' --header "auth: $kore_jwt_token" --header 'Content-Type: application/json' -o /tmp/api_test_response.json)

HTTP_CODE="${RESPONSE: -3}"
echo "HTTP Status Code: $HTTP_CODE"

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ API connectivity successful"
    echo "✅ JWT token is valid and working"
elif [ "$HTTP_CODE" = "401" ] || [ "$HTTP_CODE" = "403" ]; then
    echo "❌ Authentication failed"
    echo "   Check your JWT token permissions"
elif [ "$HTTP_CODE" = "000" ]; then
    echo "❌ Network connectivity issue"
    echo "   Check your internet connection"
else
    echo "⚠️  Unexpected response code: $HTTP_CODE"
    echo "   Response: $(cat /tmp/api_test_response.json 2>/dev/null)"
fi

echo ""

# Check file permissions
echo "4. Script Permissions Check:"
for script in "upload_test_file.sh" "curl_script_corrected.sh" "complete_test_upload_workflow.sh"; do
    if [ -x "etl/$script" ]; then
        echo "✅ $script is executable"
    else
        echo "❌ $script is not executable"
        echo "   Run: chmod +x etl/$script"
    fi
done

echo ""
echo "============================================"
echo "Validation Complete"
echo "============================================"

# Cleanup
rm -f /tmp/api_test_response.json

