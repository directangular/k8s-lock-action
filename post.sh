#!/bin/bash

set -e

source /util.sh
env_check
init_k8s
LOCKNAME=$(get_lock_name)

# Only release the lock if this run currently holds it. This prevents
# cancelled or skipped runs from advancing the lock inadvertently.
secret_json=$(kubectl get secret $LOCKNAME -o json || echo "nope")
if [[ "$secret_json" = "nope" ]]; then
    echo "Lock secret $LOCKNAME not found; nothing to release."
    exit 0
fi

current_next_build=$(jq <<<"$secret_json" -r '.data.next_build' | base64 -d || true)
if [[ "$current_next_build" != "$GITHUB_RUN_NUMBER" ]]; then
    echo "Lock not held by this run (current next_build=$current_next_build, this run=$GITHUB_RUN_NUMBER). Skipping release."
    echo "If you need to fix up the lock number, execute:"
    echo "    kubectl create secret generic $LOCKNAME --from-literal=next_build=<desired_build_number> --dry-run=client -o yaml | kubectl replace -f -"
    exit 0
fi

next_build=$GITHUB_RUN_NUMBER
((next_build++))
echo "Setting next build to ${next_build}. Thanks for playing"'!'""
kubectl create secret generic $LOCKNAME \
        --from-literal=next_build=${next_build} \
        --dry-run=client \
        -o yaml | kubectl replace -f -
