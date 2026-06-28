#!/bin/bash
set -e;
set -u;

echo -e '\n\033[1m[Build tf2classified-freeplay]\033[0m'


#
# Default options
#
option_skip_pull=false;					# Skip pulling the latest base image?
option_skip_tests=false;				# Skip running tests?
options_skip_push_dockerhub=false;		# Skip pushing to Docker Hub?


#
# Parse command line options
#
while [ "$#" -gt 0 ]
do
	case "$1" in
		# options
		--skip-pull)
			option_skip_pull=true;
			;;
		--skip-tests)
			option_skip_tests=true;
			;;
		--skip-push-dockerhub)
			options_skip_push_dockerhub=true;
			;;
		# unknown
		*)
			echo "Error: unknown option '${1}'. Exiting." >&2;
			exit 12;
			;;
	esac
	shift
done


#
# Pull the latest base image unless skipped
#
if [ "$option_skip_pull" != 'true' ]; then
	docker pull lacledeslan/gamesvr-tf2classified:latest
else
	echo "Skipping pulling the latest base image";
fi;


#
# Build the Docker image
#
docker build . -f linux.Dockerfile --rm -t lacledeslan/gamesvr-tf2classified-freeplay:latest --build-arg BUILDNODE="$(cat /proc/sys/kernel/hostname)";


#
# Run tests for the Docker image unless skipped
#
if [ "$option_skip_tests" != 'true' ]; then
	echo -e '\n\033[1m[Running tests for tf2classified-freeplay]\033[0m'
	docker run -it --rm lacledeslan/gamesvr-tf2classified-freeplay:latest ./ll-tests/gamesvr-tf2classified-freeplay.sh;
else
	echo "Skipping tests";
fi;


#
# Push the Docker image to Docker Hub unless skipped
#
if [ "$options_skip_push_dockerhub" != 'true' ]; then
	docker push lacledeslan/gamesvr-tf2classified-freeplay:latest
else
	echo "Skipping push to Docker Hub";
fi;
