# Kore.ai Test Suite Upload Guide

Based on the [Kore.ai API documentation](https://docs.kore.ai/xo/apis/automation/api-list/#bot-definition-apis), here's how to upload your test cases to the conversation testing API.

## Current Issue

The `fileName` parameter in the import API expects a **file ID**, not a filename. There are two possible approaches:

### Approach 1: Manual Upload (Recommended)

1. **Upload via Kore.ai UI**: 
   - Go to your Kore.ai bot dashboard
   - Navigate to Testing > Conversation Testing
   - Upload your `test_success.json` file manually
   - Note the file ID that gets generated

2. **Use the Import API**:
   ```bash
   export kore_jwt_token="your_jwt_token_here"
   ./etl/curl_script_corrected.sh
   ```
   (Replace `REPLACE_WITH_FILE_ID_FROM_UPLOAD` with the actual file ID)

### Approach 2: Find the Correct Upload API

The file upload endpoint we tried (`/api/public/stream/{streamId}/file/upload`) returned "Method Not Allowed", suggesting:

- The endpoint might be different
- The upload might need to be done through a different API
- The file might need to be uploaded to a general file storage first

## What We Know Works

✅ **Import API Structure**: Our corrected import API call is working (returns proper JWT error)
✅ **File Format**: Your `test_success.json` is properly formatted for Kore.ai
✅ **Authentication**: JWT token mechanism is correct

## Next Steps

1. **Try Manual Upload**: Use the Kore.ai UI to upload the file and get the file ID
2. **Contact Kore.ai Support**: Ask for the correct file upload API endpoint
3. **Check Documentation**: Look for file management APIs in the full documentation

## Files Created

- `upload_test_file.sh`: Attempts file upload (currently returns 405 error)
- `curl_script_corrected.sh`: Working import script (needs file ID)
- `complete_test_upload_workflow.sh`: Combined workflow (needs correct upload endpoint)

## Test File Details

Your `test_success.json` contains:
- Bot ID: `st-632dfdf2-e66c-5baa-a48d-f7b15e96e07e`
- Test Case: "CHATBOTS_369" with UGHIP and UNL tags
- 11 conversation steps testing hospital indemnity insurance flow

This is properly formatted for Kore.ai conversation testing.

