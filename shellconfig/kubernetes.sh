# Kubernetes functions and aliases

# Helper to select a pod across all namespaces (by pattern/index or interactively via fzf)
_kselect_pod() {
    local pod_query="$1"
    local index="${2:-1}"
    if [ -n "$pod_query" ]; then
        kubectl get pods --all-namespaces --no-headers | grep "$pod_query" | head -n "$index" | tail -n 1
    elif command -v fzf &>/dev/null; then
        kubectl get pods --all-namespaces --no-headers | fzf --height 40% --reverse --prompt="Select Pod > "
    else
        echo "Usage: provide a pod name substring or install fzf" >&2
        return 1
    fi
}

# Stream logs from a matching pod
klog() {
    local pod=""
    local container_name=""
    local input_index=""
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -i|--index)
                input_index="$2"
                shift 2
                ;;
            *)
                if [ -z "$pod" ]; then
                    pod="$1"
                else
                    container_name="$1"
                fi
                shift
                ;;
        esac
    done
    local line ns podname
    line="$(_kselect_pod "$pod" "${input_index:-1}")" || return 1
    [ -z "$line" ] && { echo "No matching pod found." >&2; return 1; }
    ns="$(echo "$line" | awk '{print $1}')"
    podname="$(echo "$line" | awk '{print $2}')"
    echo "Pod: ${ns}/${podname}"
    echo
    if [ -n "$container_name" ]; then
        kubectl logs -f --namespace="${ns}" "${podname}" -c "${container_name}"
    else
        kubectl logs -f --namespace="${ns}" "${podname}"
    fi
}

# Watch pods in a namespace (or all namespaces if omitted)
wpod() {
    if [ $# -eq 0 ]; then
        watch -n 1 kubectl get pods --all-namespaces -o wide
    else
        watch -n 1 kubectl get pods -n "$*" -o wide
    fi
}

# Execute an interactive shell inside a matching pod
kexec() {
    local pod="$1"
    local input_index="${2:-1}"
    local shell_cmd="${3:-/bin/sh}"
    local line ns podname
    line="$(_kselect_pod "$pod" "$input_index")" || return 1
    [ -z "$line" ] && { echo "No matching pod found." >&2; return 1; }
    ns="$(echo "$line" | awk '{print $1}')"
    podname="$(echo "$line" | awk '{print $2}')"
    echo "Pod: ${ns}/${podname}"
    echo
    kubectl exec -it --namespace="${ns}" "${podname}" -- "${shell_cmd}"
}

# Describe a matching pod
kdesc() {
    local pod="$1"
    local input_index="${2:-1}"
    local line ns podname
    line="$(_kselect_pod "$pod" "$input_index")" || return 1
    [ -z "$line" ] && { echo "No matching pod found." >&2; return 1; }
    ns="$(echo "$line" | awk '{print $1}')"
    podname="$(echo "$line" | awk '{print $2}')"
    echo "Pod: ${ns}/${podname}"
    echo
    kubectl describe pod --namespace="${ns}" "${podname}"
}

# Port-forward to a matching pod (e.g., kpf my-pod 8080:80)
kpf() {
    local pod="$1"
    local ports="${2:?Usage: kpf <pod-pattern> <local-port:remote-port>}"
    local line ns podname
    line="$(_kselect_pod "$pod" 1)" || return 1
    [ -z "$line" ] && { echo "No matching pod found." >&2; return 1; }
    ns="$(echo "$line" | awk '{print $1}')"
    podname="$(echo "$line" | awk '{print $2}')"
    echo "Forwarding ${ns}/${podname} (${ports})..."
    kubectl port-forward --namespace="${ns}" "pod/${podname}" "${ports}"
}

# Kubectl command for all namespaces
ka() {
    kubectl "$@" --all-namespaces
}

# Kubectl command for specific namespace
kn() {
    local namespace="$1"
    shift
    kubectl -n "$namespace" "$@"
}

# Load kubectl completion if kubectl is installed
if command -v kubectl &>/dev/null; then
    if [ -n "${ZSH_VERSION:-}" ]; then
        source <(kubectl completion zsh)
    elif [ -n "${BASH_VERSION:-}" ]; then
        source <(kubectl completion bash)
    fi
fi

# Kubernetes aliases
alias k='kubectl'
alias kg='kubectl get'
alias kgall='kubectl get all'
alias kgp='kubectl get pods'
alias kgpw='kubectl get pods -o wide'
alias kgpa='kubectl get pods -o wide --all-namespaces'
alias kpod='kubectl get pods -o wide --all-namespaces'
alias kgs='kubectl get services'
alias ksvc='kubectl get services -o wide --all-namespaces'
alias kgd='kubectl get deployments'
alias kgn='kubectl get nodes -o wide'
alias kge='kubectl get events --sort-by=.lastTimestamp'
alias kedp='kubectl get endpoints -o wide --all-namespaces'
alias king='kubectl get ingress -o wide --all-namespaces'
alias kp='kubectl get pods -o wide'
alias ks='kubectl get services'
alias ke='kubectl get endpoints'

alias kd='kubectl delete'
alias kdf='kubectl delete --grace-period=0 --force'
alias kc='kubectl create'
alias kaf='kubectl apply -f'
alias kdel='kubectl delete -f'
alias kroll='kubectl rollout status deployment'
alias krestart='kubectl rollout restart deployment'
alias ktop='kubectl top pods'
alias ktopn='kubectl top nodes'

alias kns='kubens'
alias kctx='kubectx'
alias wp='watch -n 1 kubectl get pods -o wide'
alias kt='stern --all-namespaces'
alias h='helm'
alias k9='k9s'



