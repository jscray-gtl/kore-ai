#!/bin/bash

# Quick test launcher for GTL Insurance Chatbot Automation

echo "🎯 GTL Insurance Chatbot Test - Quick Launcher"
echo "=============================================="

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo "❌ Please run this script from the project root directory"
    exit 1
fi

echo "Select test mode:"
echo "1) 👀 Visible browser (recommended for first run)"
echo "2) 🚀 Headless mode (faster)"
echo "3) 🐛 Debug mode (slow, visible, extra logging)"
echo ""
read -p "Enter choice (1-3): " choice

case $choice in
    1)
        echo "🔧 Running with visible browser..."
        export HEADLESS=false
        npm test
        ;;
    2)
        echo "🔧 Running in headless mode..."
        export HEADLESS=true
        npm test
        ;;
    3)
        echo "🔧 Running in debug mode..."
        export HEADLESS=false
        export DEBUG=true
        npm test
        ;;
    *)
        echo "Invalid choice. Running with visible browser..."
        export HEADLESS=false
        npm test
        ;;
esac

echo ""
echo "=============================================="
echo "🔍 Check these locations for results:"
echo "  📸 Screenshots: tests/screenshots/"
echo "  📊 Test data: tests/artifacts/test_success.json"
echo "  📋 Expected result: Price contains \"$42.90\""

