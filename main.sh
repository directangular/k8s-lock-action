#!/bin/bash

MAX_ATTEMPTS=${INPUT_MAX_ATTEMPTS:-10000}

source util.sh
env_check
LOCKNAME=$(get_lock_name)

echo "Attempting lock via ${LOCKNAME}."
echo "If you need to override this lock to allow this build to continue, execute:"
echo "    kubectl create secret generic $LOCKNAME --from-literal=next_build=$GITHUB_RUN_NUMBER --dry-run -o yaml | kubectl replace -f -"

lock_attempt=1
while :; do
    secret_json=$(kubectl get secret $LOCKNAME -o json)
    [[ $? -eq 0 ]] || {
        echo "Creating and grabbing initial secret lock"
        kubectl create secret generic $LOCKNAME --from-literal=next_build=${GITHUB_RUN_NUMBER}
        exit 0
    }
    next_build=$(jq <<<"$secret_json" -r '.data.next_build' | base64 -d)
    [[ $next_build -eq $GITHUB_RUN_NUMBER ]] && { echo "Lock acquired."; exit 0; }
    echo "Couldn't get lock ($next_build "'!'"= $GITHUB_RUN_NUMBER). Attempt $lock_attempt / ${MAX_ATTEMPTS}. Sleeping..."
    sleep 10
done
