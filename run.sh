#!/usr/bin/env bash

set -e
shopt -s extglob

# Defaults variables
export INSTANCES_COUNT=1
export AUTO_APPROVE=false
export AVAILABLE_CMDS='@(refresh|plan|apply|destroy|validate)'

cwd="$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)"

[ -f ~/openrc.sh ] && source ~/openrc.sh



function __iso8601_date(){
  date -u +'%Y-%m-%dT%H:%M:%SZ'
}

display_help() {
    echo "Usage: ./run.sh [arguments]..."
    echo
    echo "  -n, --number            number of instances (default: ${INSTANCES_COUNT})"
    echo "  -c, --command           select terraform command to run"
    echo "                          possible options: ${AVAILABLE_CMDS}"
    echo "  -a, --auto-approve      auto-approve terraform command (default: false)"
    echo "  -h, --help              display this help message"
    echo
}

exit_help() {
    display_help
    echo "Error: $1"
    exit 1
}

# no arguments provided? show help
if [ $# -eq 0 ]; then
    display_help
    exit 0
fi

# process arguments
while [[ $# -gt 0 ]]; do
    arg=$1
    case $arg in
        -h|--help)
            display_help
            exit 0 ;;
        -a|--auto-approve)
            AUTO_APPROVE="true"
            ;;
        -n|--number-of-instances)
            INSTANCES_COUNT=${2}
            shift
            ;;
        -c|--command)
            case $2 in
                ${AVAILABLE_CMDS})
                    COMMAND=$2
                    ;;
                *)
                    exit_help "Unknown command: $2"
                    ;;
            esac
            shift
            ;;
        *)
            exit_help "Unknown argument: $arg"
            ;;
    esac
    shift
done

[ "$INSTANCES_COUNT" ] || exit_help "Number of instances not specified!"

build_output="output/terraform-run-$COMMAND-$(__iso8601_date)"

mkdir -p output

# Capture all output from here on in terraform-run-*.log
exec &> >(tee -a "${build_output}.log")

echo "[+] Selected command: $COMMAND"
echo "[+] Selected number of instances: $INSTANCES_COUNT"
echo "[+] Automatically approve: $AUTO_APPROVE"

sleep 1

install_jq() {
    sudo apt-get install jq
}

install_terraform() {
    TF_VERSION="0.12.24"
    ${cwd}/deps/terraform-installer/terraform-install.sh -i "${TF_VERSION}" -a
}

install_terraform_inventory() {
    ${cwd}/deps/terraform-inventory-installer/install.sh
}

install_ansible() {
    ${cwd}/deps/ansible-installer/install.sh
}

# Dependency checks
dep_check() {
    deps="jq terraform ansible terraform_inventory"

    for dep in $deps; do
        echo "[+] Checking for installed dependency: $dep"
        if ! which "${dep//_/-}" &>/dev/null; then
            echo "[-] Missing dependency: $dep"
            echo "[+] Attempting to install:"
            install_"${dep}"
        fi
    done

    echo "[+] All done! Creating hidden file .dep_check so we don't have preform check again."
    touch .dep_check
}

# Run dependency check once (see above for dep check)
if [ ! -f ".dep_check" ]; then
    dep_check
else
    echo "[+] Dependency check previously conducted. To rerun remove file .dep_check"
fi

set_terraform_vars() {
    export TF_VAR_region="WAW1"
    export TF_VAR_ssh_public_key="~/.ssh/id_rsa.pub"
    export TF_VAR_ssh_private_key="~/.ssh/id_rsa"
    export TF_VAR_ssh_user="ubuntu"
    export TF_VAR_name="csb"
    export TF_VAR_flavor_name="s1-2"
    export TF_VAR_mysql_count="${INSTANCES_COUNT}"
}

set_terraform_vars
[ ! -e ${cwd}/.terraform ] && terraform init

tf_cmd=()
tf_cmd+="${COMMAND}"

case "${COMMAND}" in
    plan|apply|destroy)
        tf_cmd+=("--parallelism" "20")
        if [ "${COMMAND}" != "plan" -a "${AUTO_APPROVE}" == "true" ]; then
            tf_cmd+="-auto-approve"
        fi
esac

terraform "${tf_cmd[@]}"