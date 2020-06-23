#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

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
    echo -e "\e[1;34m> $*\e[0m" >&2; "$@"
}

function build() {
    nixpkgs_path="$(nix eval --raw "(import ${CFG_PATH}/nix/sources.nix).nixpkgs.outPath")"
    home_manager_path="$(nix eval --raw "(import ${CFG_PATH}/nix/sources.nix).home-manager.outPath")"
    export NIX_PATH=nixpkgs="${nixpkgs_path}":home-manager="${home_manager_path}":nixpkgs-overlays="$(realpath $CFG_PATH)/overlays/"
    tmp=$(mktemp -u)
    trace nix build --no-link -f "${CFG_PATH}" -o "${tmp}/result" --keep-going --show-trace "$*" >&2
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

case "$mode" in
    "build")
        build "$*"
        ;;
    "switch")
        switch "$*"
        ;;
    "check")
        check "$*"
        ;;
    "update")
        update "$*"
        ;;
    "upgrade")
        upgrade "$*"
        ;;
    "format")
        format "$*"
        ;;
    "vm")
        vm "$*"
        ;;
esac
