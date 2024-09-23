default: install

alias f := format
alias fmt := format

format:
    just --fmt --unstable

install:
    #!/usr/bin/env bash
    set -euxo pipefail
    if [ ! -f "/etc/yum.repos.d/rsteube-fury.repo" ] ; then
        sudo cp --update=none yum.repos.d/rsteube-fury.repo /etc/yum.repos.d/rsteube-fury.repo
    fi
    if [ ! -f "/etc/yum.repos.d/atim-nushell-fedora.repo" ] ; then
        curl --location https://copr.fedorainfracloud.org/coprs/atim/nushell/repo/fedora/atim-nushell-fedora.repo \
            | sudo tee /etc/yum.repos.d/atim-nushell-fedora.repo
    fi
    distro=$(awk -F= '$1=="ID" { print $2 ;}' /etc/os-release)
    if [ "$distro" = "fedora" ]; then
        variant=$(awk -F= '$1=="VARIANT_ID" { print $2 ;}' /etc/os-release)
        if [ "$variant" = "toolbx" ]; then
            sudo dnf --assumeyes install carapace-bin direnv nushell
        elif [ "$variant" = "iot" ] || [[ "$variant" = *-atomic ]]; then
            sudo rpm-ostree install --idempotent carapace-bin direnv nushell
            echo "Reboot to finish installation."
        fi
    fi
    mkdir --parents "{{ config_directory() }}/nushell"
    ln --force --relative --symbolic nushell/*.nu "{{ config_directory() }}/nushell/"
    ln --force --relative --symbolic nushell/config.d "{{ config_directory() }}/nushell/config.d"
    ln --force --relative --symbolic nushell/env.d "{{ config_directory() }}/nushell/env.d"
    if [ ! -d "nupm" ] ; then
        git clone https://github.com/nushell/nupm.git
    else
        git -C nupm pull
    fi
    if [ ! -d "nu_scripts" ] ; then
        git clone https://github.com/nushell/nu_scripts.git
    else
        git -C nu_scripts pull
    fi
    mkdir --parents "{{ config_directory() }}/nushell/nupm"
    nu --commands "use nupm/nupm; nupm install --force --path nupm"
    nu --commands "use nupm/nupm; nupm install --force --path nu_scripts/nu-hooks"

alias u := update
alias up := update

update:
    git -C nupm pull
    git -C nu_scripts pull
