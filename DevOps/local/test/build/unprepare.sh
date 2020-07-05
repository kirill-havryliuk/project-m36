#!/usr/bin/env bash

if ! type dirname > /dev/null 2>&1; then
    echo "Not even a linux or macOS, Windoze? We don't support it. Abort."
    exit 1
fi

. "$(dirname "$0")"/../../../common/common.sh

init_with_root_or_sudo "$0"

begin_banner "Top level" "build unprepare"

set +u
[[ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]] && . $HOME/.nix-profile/etc/profile.d/nix.sh
set -u

if type nix-build >/dev/null 2>&1; then
    info "nix-build found, trying to uninstall it"
    if [ "${THE_DISTRIBUTION_ID}" == "debian" ] || [ "${THE_DISTRIBUTION_ID}" == "ubuntu" ]; then
        [[ -e /proc/sys/kernel/unprivileged_userns_clone ]] && sudo sysctl kernel.unprivileged_userns_clone=1
    fi
    set +e
    sudo rm -fr /nix > /dev/null 2>&1
    set -e
    sudo rm -fr $HOME/.nix-channels
    sudo rm -fr $HOME/.nix-defexpr
    sudo rm -fr $HOME/.nix-profile
    [[ -f $HOME/.profile ]] && sed -i.nix.uninstall.bak '/.nix-profile/d' $HOME/.profile
    [[ -f $HOME/.bash_profile ]] && sed -i.nix.uninstall.bak '/.nix-profile/d' $HOME/.bash_profile
    [[ -f $HOME/.bashrc ]] && sed -i.nix.uninstall.bak '/.nix-profile/d' $HOME/.bashrc
fi

done_banner "Top level" "build unprepare"
