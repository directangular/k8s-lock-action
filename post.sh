#!/bin/bash

source util.sh
env_check
LOCKNAME=$(get_lock_name)

next_build=$GITHUB_RUN_NUMBER
((next_build++))
echo "Setting next build to ${next_build}. Thanks for playing"'!'""
kubectl create secret generic $LOCKNAME \
        --from-literal=next_build=${next_build} \
        --dry-run \
        -o yaml | kubectl replace -f -