#!/bin/bash

echo "=== Snippet Manager Test ==="
echo "1. Testing basic wtype functionality..."
sleep 2
wtype "Test 1: Basic wtype works!"
sleep 1
wtype " "

echo "2. Testing multi-line snippet (like our email signature)..."
sleep 2
wtype "Best regards,"
wtype $'\n'
wtype "John Doe"
wtype $'\n'
wtype "Software Developer" 

echo "3. Testing code snippet with newlines..."
sleep 2
wtype $'\n\nfunction test() {\n    console.log("Hello World");\n    return true;\n}'

echo ""
echo "=== Test completed ==="
echo "If text appeared in your active window, text injection works!"
echo "Now try the overlay with Super+Shift+Space"