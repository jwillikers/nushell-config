default: install

alias f := format
alias fmt := format

format:
    just --fmt --unstable

install:
    #!/usr/bin/env bash
    set -euxo pipefail
    cp --update=none yum.repos.d/rsteube-fury.repo /etc/yum.repos.d/rsteube-fury.repo
    curl --location https://copr.fedorainfracloud.org/coprs/atim/nushell/repo/fedora/atim-nushell-fedora.repo \
        | sudo tee /etc/yum.repos.d/atim-nushell-fedora.repo
    distro=$(awk -F= '$1=="ID" { print $2 ;}' /etc/os-release)
    if [ "$distro" = "fedora" ]; then
        variant=$(awk -F= '$1=="VARIANT_ID" { print $2 ;}' /etc/os-release)
        if [ "$variant" = "toolbx" ]; then
            sudo dnf --assumeyes install carapace-bin nushell
        elif [ "$variant" = "iot" ] || [[ "$variant" = *-atomic ]]; then
            sudo rpm-ostree install --idempotent carapace-bin nushell
            echo "Reboot to finish installation."
        fi
    fi
    mkdir --parents "{{ config_directory() }}/nushell"
    ln --force --relative --symbolic nushell/*.nu "{{ config_directory() }}/nushell/"
