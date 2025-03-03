#!/bin/bash
# purge packages and their configuration files
/usr/bin/apt purge \
    avahi-daemon \
    nano \
    network-manager \
    vim-common

# update package cache
/usr/bin/apt update

# install packages
/usr/bin/apt install \
    neovim

# install "log2ram"; see also "/etc/apt/sources.list.d/azlux.list"
/usr/bin/wget "https://azlux.fr/repo.gpg" \
    --output-document="/usr/share/keyrings/azlux-archive-keyring.gpg"
/usr/bin/apt install \
    log2ram

# disable unnecessary systemd service units
/usr/bin/systemctl disable \
    --now \
    apt-daily-upgrade.timer
