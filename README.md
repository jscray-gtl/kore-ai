# GTL Insurance Chatbot Automation Tests

This project contains Selenium WebDriver automation tests for the GTL Insurance chatbot at https://eapp-react-qa.gtlic.com/

## 🎯 Test Objective

The test automates a complete insurance quote workflow based on the UGHIP test case:

1. **Start Flow**: Initialize the chatbot
2. **Quote Request**: Request a hospital indemnity quote  
3. **Personal Details**: Provide M, IL, 01/01/1960
4. **Product Selection**: Choose "Hospital Indemnity Shield"
5. **Days Selection**: Select 10 days
6. **Amount Selection**: Choose $900 coverage
7. **Rider Addition**: Add Ambulance rider for $250
8. **Final Verification**: Confirm price contains "$42.90"

## 🛠️ Setup

### Prerequisites
- Node.js (v16 or higher)
- Chrome browser installed
- Internet connection

### Installation

```bash
# Install dependencies
npm install

# Make test runner executable
chmod +x tests/run-test.sh
```

## 🚀 Running Tests

### Quick Start
```bash
# Run test with visible browser (recommended for first run)
npm test

# Or use the shell script
./tests/run-test.sh
```

### Advanced Options
```bash
# Run in headless mode (faster, no browser window)
./tests/run-test.sh headless

# Run in debug mode (visible browser)
./tests/run-test.sh debug

# Run with environment variable
HEADLESS=true npm test
```

## 📁 Project Structure

```
├── package.json              # Dependencies and scripts
├── tests/
│   ├── chatbot-test.js       # Main Selenium test
│   ├── config.js             # Test configuration
│   ├── run-test.sh           # Test runner script
│   ├── artifacts/
│   │   └── test_success.json # Test case data
│   └── screenshots/          # Auto-generated screenshots
├── etl/                      # API testing scripts
└── README.md                 # This file
```

## 🧪 Test Features

### Smart Chat Detection
- Automatically finds chat interfaces (iframes, containers)
- Multiple fallback selectors for input fields
- Handles different chat implementations

### Robust Input Handling
- Tries multiple methods to send messages (Enter key, submit button)
- Waits for responses with configurable timeouts
- Handles dynamic content loading

### Comprehensive Verification
- Validates each step's expected output
- Specifically checks for the final price "$42.90"
- Takes screenshots at key moments for debugging

### Error Handling
- Graceful failure handling
- Detailed logging of each step
- Screenshot capture on errors

## 📸 Screenshots

The test automatically captures screenshots:
- `01-initial-page.png` - Initial page load
- `02-chat-interface.png` - Chat interface detected
- `03-after-test-case.png` - After completing all steps
- `04-final-result.png` - Final verification
- `error-screenshot.png` - If errors occur

## 🔧 Configuration

Edit `tests/config.js` to customize:
- Timeouts and delays
- Chat interface selectors
- Expected results
- Browser settings

## 📊 Test Data

The test reads from `tests/artifacts/test_success.json` which contains:
- Bot ID and configuration
- Complete conversation flow
- Expected responses for each step
- Final price verification data

## 🐛 Troubleshooting

### Common Issues

**Chrome driver issues:**
```bash
npm run install-drivers
```

**Chat interface not found:**
- Check if the website structure changed
- Update selectors in `config.js`
- Run in visible mode to see what's happening

**Test timeouts:**
- Increase timeout values in `config.js`
- Check internet connection
- Verify website is accessible

### Debug Mode
Run with visible browser to see exactly what's happening:
```bash
./tests/run-test.sh debug
```

## 📈 Success Criteria

The test passes when:
1. ✅ All conversation steps complete successfully
2. ✅ Expected responses are found for each step
3. ✅ Final quote contains the price "$42.90"
4. ✅ No errors or timeouts occur

## 🔄 CI/CD Integration

For automated testing, use headless mode:
```bash
HEADLESS=true npm test
```

Exit codes:
- `0` - Test passed
- `1` - Test failed or error occurred

## 📝 Logs

The test provides detailed console output showing:
- Each step being executed
- Messages being sent
- Responses being verified
- Screenshots being captured
- Final results

Example successful run:
```
🚀 Initializing Selenium WebDriver...
✅ WebDriver initialized successfully
🌐 Navigating to GTL Insurance App...
✅ Successfully navigated to the application
🔍 Looking for chat interface...
✅ Found chat interface using selector: iframe[title*="chat"]
📤 Sending message: "quote"
✅ Message sent successfully
⏳ Waiting for response containing: "Great! Right now I can only quote..."
✅ Expected response found!
💰 Verifying final price of $42.90...
✅ SUCCESS: Found expected price $42.90 in the response!
```

