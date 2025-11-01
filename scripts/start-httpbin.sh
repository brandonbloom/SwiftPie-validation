#!/bin/bash
# Start httpbin server using Docker on port 8888
# This script is used by /run-tests to set up the test environment

docker run -p 8888:80 kennethreitz/httpbin &
sleep 3

# Verify httpbin is running
if curl -s http://localhost:8888/get > /dev/null 2>&1; then
    echo "✓ httpbin server started successfully on port 8888"
    exit 0
else
    echo "✗ httpbin server failed to start"
    exit 1
fi
