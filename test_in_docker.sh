#!/usr/bin/env bash

# -e: exit when a command fails
# -o pipefail: set exit status of shell script to last nonzero exit code, if any were nonzero.
set -o pipefail

echo ""
echo "Running Tests in Docker Container"
echo "Swift 4"
echo "================================="
docker build -t swiftybeaver_s4 -f Dockerfile .

docker run -e SBPLATFORM_APP_ID=$SBPLATFORM_APP_ID \
-e SBPLATFORM_APP_SECRET=$SBPLATFORM_APP_SECRET \
-e SBPLATFORM_ENCRYPTION_KEY=$SBPLATFORM_ENCRYPTION_KEY \
--name swiftybeaver_test_s4 --rm swiftybeaver_s4 swift test \
  || (set +x; echo -e "\033[0;31mTests exited with non-zero exit code\033[0m"; tput bel; exit 1)
echo "Finished tests, docker container were removed."
