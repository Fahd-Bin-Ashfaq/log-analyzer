#!/bin/bash

# Log Analyzer Script - by Fahad

# 1. Check if file path is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <log_file_path>"
    exit 1
fi

log_file="$1"

# 2. Check if file exists
if [ ! -f "$log_file" ]; then
    echo "Error: File not found -> $log_file"
    exit 1
fi

echo "-------------------------------------"
echo "📂 Analyzing Log File: $log_file"
echo "-------------------------------------"

# 3. Count of ERROR, WARNING, and INFO messages
echo
echo "📊 Log Message Count:"
echo "ERROR:   $(grep -c "ERROR" "$log_file")"
echo "WARNING: $(grep -c "WARNING" "$log_file")"
echo "INFO:    $(grep -c "INFO" "$log_file")"

# 4. Top 5 most common ERROR messages
echo
echo "🔥 Top 5 Most Common ERROR Messages:"
grep "ERROR" "$log_file" | cut -d':' -f2- | sort | uniq -c | sort -nr | head -5

# 5. First and last ERROR timestamps
echo
echo "🕒 ERROR Summary:"
first_error=$(grep "ERROR" "$log_file" | head -1 | cut -d' ' -f1,2)
last_error=$(grep "ERROR" "$log_file" | tail -1 | cut -d' ' -f1,2)

echo "First ERROR at: $first_error"
echo "Last  ERROR at: $last_error"
echo "-------------------------------------"
