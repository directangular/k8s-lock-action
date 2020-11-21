# Can exit. Invoke directly, not from a subshell.
function init_k8s() {
    [[ -n "$INPUT_KUBE_CONFIG_DATA" ]] || {
        echo "Please set kube_config_data in your 'with:' block"
    }
    base64 -d <<<"$INPUT_KUBE_CONFIG_DATA" > /tmp/kubeconfig
    export KUBECONFIG=/tmp/kubeconfig
    [[ -n "$INPUT_KUBE_CONTEXT" ]] && kubectl config use-context $INPUT_KUBE_CONTEXT
    kubectl version || { echo "Couldn't get a working kubectl"; exit 1; }
}

function get_lock_name() {
    echo "k8s-lock-${GITHUB_REPOSITORY/\//-}-${INPUT_LOCK_NAME}"
}

# Can exit. Invoke directly, not from a subshell.
function env_check() {
    [[ -n "$INPUT_LOCK_NAME" ]] || {
        echo "Please set an input_lock_name in your 'with:' block"
        exit 1
    }
}
