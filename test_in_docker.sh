#!/usr/bin/env bash

# -e: exit when a command fails
# -o pipefail: set exit status of shell script to last nonzero exit code, if any were nonzero.
set -o pipefail

echo ""
echo "Running Tests in Docker Container"
echo "================================="
docker build -t swiftybeaver .
docker run --name swiftybeaver_test --rm swiftybeaver swift test
echo "Finished tests, docker container were removed."
