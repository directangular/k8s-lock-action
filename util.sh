# Can exit. Invoke directly, not from a subshell.
function init_k8s() {
    base64 -d <<<"$KUBE_CONFIG_DATA" > /tmp/kubeconfig
    export KUBECONFIG=/tmp/kubeconfig
    [[ -n "$INPUT_KUBE_CONTEXT" ]] && kubectl use-context $INPUT_KUBE_CONTEXT
    kubectl version || { echo "Couldn't get a working kubectl"; exit 1; }
}

function get_lock_name() {
    echo "k8s-lock-${GITHUB_REPOSITORY/\//-}-${INPUT_LOCK_NAME}"
}

# Can exit. Invoke directly, not from a subshell.
function env_check() {
    [[ -n "$INPUT_LOCK_NAME" ]] || {
        echo "Please set an input-lock-name in your 'with:' block"
        exit 1
    }
}
