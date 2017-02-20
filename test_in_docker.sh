#!/usr/bin/env bash

# -e: exit when a command fails
# -o pipefail: set exit status of shell script to last nonzero exit code, if any were nonzero.
set -o pipefail

echo ""
echo "Running Tests in Docker Container"
echo "================================="
docker build -t swiftybeaver .

#docker run --name swiftybeaver_test --rm swiftybeaver swift test
docker run -e SBPLATFORM_APP_ID=$SBPLATFORM_APP_ID \
-e SBPLATFORM_APP_SECRET=$SBPLATFORM_APP_SECRET \
-e SBPLATFORM_ENCRYPTION_KEY=$SBPLATFORM_ENCRYPTION_KEY \
--name swiftybeaver_test --rm swiftybeaver swift test
echo "Finished tests, docker container were removed."
