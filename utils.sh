#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

QUIET_BUILD=false

# Nicholas Sushkin
# https://stackoverflow.com/questions/1527049/how-can-i-join-elements-of-an-array-in-bash
function join_by { local IFS="$1"; shift; echo "$*"; }

function usage() {
cat <<EOF
Usage:
    make.sh switch
    make.sh update
    make.sh check
    make.sh gc
EOF
}

function trace() {
    if $QUIET_BUILD
    then
        log="$(mktemp)"
        echo -e "\e[1;34m> $@ \e[0m [logging to $log]" >&2
        "$@" > $log 2>&1 && stat=$? || stat=$?
        if [ $stat -ne 0 ]
        then
            echo -e "\e[1;31m> FAILED <\e[0m"
            head -n 50 $log
            exit $stat
        fi
    else
        echo -e "\e[1;34m> $@ \e[0m" >&2
        "$@"
    fi
}

function build() {
    nixpkgs_path="$(nix eval --raw "(import ${CFG_PATH}/nix/sources.nix).nixpkgs.outPath")"
    home_manager_path="$(nix eval --raw "(import ${CFG_PATH}/nix/sources.nix).home-manager.outPath")"
    export NIX_PATH=nixpkgs="${nixpkgs_path}":home-manager="${home_manager_path}":nixpkgs-overlays="$(realpath $CFG_PATH)/overlays/"
    tmp=$(mktemp -u)
    trace nix build --no-link -f "${CFG_PATH}" -o "${tmp}/result" --keep-going --show-trace "$@" >&2
    drv="$(readlink "${tmp}/result")"
    echo "${drv}"
}

function switch() {
    drv=$(build)
    trace sudo nix-env -p /nix/var/nix/profiles/system --set "$drv"
    NIXOS_INSTALL_BOOTLOADER=1 trace sudo --preserve-env=NIXOS_INSTALL_BOOTLOADER "$drv/bin/switch-to-configuration" switch
}

function vm() {
    nixpkgs_path="$(nix eval --raw "(import ${CFG_PATH}/nix/sources.nix).nixpkgs.outPath")"
    home_manager_path="$(nix eval --raw "(import ${CFG_PATH}/nix/sources.nix).home-manager.outPath")"
    export NIX_PATH=nixpkgs="${nixpkgs_path}":home-manager="${home_manager_path}"
    tmp=$(mktemp -u)
    trace nix build --no-link -f "${CFG_PATH}/vm.nix" -o "${tmp}/result" --keep-going --show-trace "$*" >&2
    drv="$(readlink "${tmp}/result")"
    echo "${drv}"
}

function update() {
    trace niv update
}

function upgrade() {
    update
    build
}

function check() {
    trace fd . "${CFG_PATH}" -e nix -x nixfmt -c || :
    trace fd . "${CFG_PATH}" -e sh -x shellcheck -Calways || :
}

function format() {
    trace fd . "${CFG_PATH}" -e nix -x nixfmt || :
    trace git diff
}

CFG_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

mode="$1"
shift

while ! [ -z ${1+x} ]
do
    case "$1" in
        "--")
            shift
            break
            ;;
        "-Q" | "--quiet")
            echo "Building quietly"
            QUIET_BUILD=true
            ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
    shift
done

case "$mode" in
    "build")
        build "$@"
        ;;
    "switch")
        switch "$@"
        ;;
    "check")
        check "$@"
        ;;
    "update")
        update "$@"
        ;;
    "upgrade")
        upgrade "$@"
        ;;
    "format")
        format "$@"
        ;;
    "vm")
        vm "$@"
        ;;
esac
