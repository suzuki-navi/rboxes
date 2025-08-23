#!/bin/bash

# Script description
# Find and execute all test.sh files in app/* directories in order

# Configuration
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
total_tests=0
passed_tests=0
failed_tests=0

echo "=== rboxes Test Runner ==="
echo

# Search for all test.sh files in app/ directory
test_files=$(find app/ -name "test.sh" -type f | sort)

if [ -z "$test_files" ]; then
    echo "No test.sh files found."
    exit 0
fi

echo "Found test files:"
echo "$test_files"
echo

# Execute each test file
for test_file in $test_files; do
    total_tests=$((total_tests + 1))
    test_dir=$(dirname "$test_file")
    test_name=$(basename "$test_dir")

    echo -e "${YELLOW}[Test $total_tests] $test_file${NC}"
    echo "Working directory: $test_dir"

    # Move to test file directory and execute
    prev_dir=$(pwd)
    cd "$test_dir"

    # Execute test.sh
    if bash ./test.sh; then
        echo -e "${GREEN}✓ Test passed${NC}"
        passed_tests=$((passed_tests + 1))
    else
        echo -e "${RED}✗ Test failed (exit code: $?)${NC}"
        failed_tests=$((failed_tests + 1))
    fi
    echo

    cd "$prev_dir"
done

# Results summary
echo "=== Test Results ==="
echo "Total tests: $total_tests"
echo -e "Passed: ${GREEN}$passed_tests${NC}"
echo -e "Failed: ${RED}$failed_tests${NC}"

if [ $failed_tests -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed.${NC}"
    exit 1
fi