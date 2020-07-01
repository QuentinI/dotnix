#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

QUIET_BUILD=false
UPLOAD_CACHE=false
RETURN_VALUE=""

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
        echo -e "\e[1;34m> $* \e[0m [logging to $log]" >&2
        "$@" > "$log" 2>&1 && stat=$? || stat=$?
        if [ $stat -ne 0 ]
        then
            echo -e "\e[1;31m> FAILED <\e[0m"
            head -n 50 "$log"
            exit $stat
        fi
    else
        echo -e "\e[1;34m> $* \e[0m" >&2
        "$@"
    fi
}

function build() {
    nixpkgs_path="$(nix eval --raw "(import ${CFG_PATH}/nix/sources.nix).nixpkgs.outPath")"
    home_manager_path="$(nix eval --raw "(import ${CFG_PATH}/nix/sources.nix).home-manager.outPath")"
    export NIX_PATH=nixpkgs="${nixpkgs_path}:home-manager=${home_manager_path}:nixpkgs-overlays=$(realpath "$CFG_PATH")/overlays/"
    tmp=$(mktemp -u)
    trace nix build --no-link -f "${CFG_PATH}" -o "${tmp}/result" --keep-going --show-trace "$@" >&2
    drv="$(readlink "${tmp}/result")"
    if $UPLOAD_CACHE
    then
        trace cachix push quentini "$drv"
    fi
    trace nix-diff --color always $(nix-store -qd /run/current-system) $(nix-store -qd ${drv}) | $PAGER
    RETURN_VALUE="${drv}"
}

function switch() {
    build
    drv=$RETURN_VALUE
    read -p "Switch? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        trace sudo nix-env -p /nix/var/nix/profiles/system --set "$drv"
        NIXOS_INSTALL_BOOTLOADER=1 trace sudo --preserve-env=NIXOS_INSTALL_BOOTLOADER "$drv/bin/switch-to-configuration" switch
    fi
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

function derivation_hash() {
    echo "$1" | awk -F "[-/]" '{print $4}'
}

function _uncached() {
    dcache=$(derivation_hash "$1")
    if [ $(curl -s -o /dev/null -w "%{http_code}" "cache.nixos.org/$dcache.narinfo") -eq 404 ]
    then
        return 0
    else
        return 1
    fi
}

function uncached() {
    export -f derivation_hash
    export -f _uncached
    nix-store -qR "$1" | xargs -n 1 -P 16 -I % bash -c 'if $(_uncached $1); then echo $1; fi' _ %
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
        "-C" | "--cache")
            UPLOAD_CACHE=true
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
    "uncached")
        uncached "$@"
        ;;
esac
