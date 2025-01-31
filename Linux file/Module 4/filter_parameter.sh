#!/bin/bash

# Debugging: Print message when script starts
echo "Starting script execution..."

# Check if output file exists, if not, create it
if [ ! -f "output.txt" ]; then
    echo "Creating output.txt..."
    touch "output.txt"
fi

# Debugging: Check input file existence
if [ ! -f "input.txt" ]; then
    echo "Error: input.txt not found!"
    exit 1
fi

# Read file line by line
while read -r line; do
    echo "Processing line: $line"  # Debugging

    # Extract key using awk
    keyword=$(echo "$line" | awk -F ":" '{print $1}')
    echo "Extracted keyword: $keyword"  # Debugging

    # Check if the keyword matches
    if [[ "$keyword" == "\"frame.time\"" || "$keyword" == "\"wlan.fc.type\"" || "$keyword" == "\"wlan.fc.subtype\"" ]]; then
        echo "Match found, appending to output.txt..."
        echo "$line" >> "output.txt"
    fi
done < "input.txt"

echo "Script execution completed!"
