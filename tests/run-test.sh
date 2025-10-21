#!/bin/bash

# GTL Insurance Chatbot Selenium Test Runner

echo "============================================"
echo "GTL Insurance Chatbot Automation Test"
echo "============================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Change to project directory
cd "$(dirname "$0")/.."

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js is not installed. Please install Node.js first.${NC}"
    exit 1
fi

# Check if dependencies are installed
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}📦 Installing dependencies...${NC}"
    npm install
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Failed to install dependencies${NC}"
        exit 1
    fi
fi

# Create screenshots directory
mkdir -p tests/screenshots

# Set environment variables
export NODE_ENV=test

# Run based on argument
case "$1" in
    "headless")
        echo -e "${BLUE}🔧 Running in headless mode...${NC}"
        export HEADLESS=true
        npm test
        ;;
    "debug")
        echo -e "${BLUE}🐛 Running in debug mode (visible browser)...${NC}"
        export HEADLESS=false
        npm test
        ;;
    *)
        echo -e "${BLUE}🚀 Running test with visible browser...${NC}"
        echo -e "${YELLOW}💡 Use './run-test.sh headless' for headless mode${NC}"
        export HEADLESS=false
        npm test
        ;;
esac

# Check test results
if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}✅ Test completed successfully!${NC}"
    echo -e "${GREEN}💰 Expected price $42.90 was found!${NC}"
else
    echo -e "\n${RED}❌ Test failed!${NC}"
    echo -e "${YELLOW}📸 Check screenshots in tests/screenshots/ for debugging${NC}"
fi

echo -e "\n${BLUE}📁 Test artifacts:${NC}"
echo -e "  - Screenshots: tests/screenshots/"
echo -e "  - Test data: tests/artifacts/test_success.json"
echo -e "  - Logs: Check console output above"

