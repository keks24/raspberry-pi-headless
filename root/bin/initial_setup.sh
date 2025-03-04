#!/bin/bash
############################################################################
# Copyright 2025 Ramon Fischer                                             #
#                                                                          #
# Licensed under the Apache License, Version 2.0 (the "License");          #
# you may not use this file except in compliance with the License.         #
# You may obtain a copy of the License at                                  #
#                                                                          #
#     http://www.apache.org/licenses/LICENSE-2.0                           #
#                                                                          #
# Unless required by applicable law or agreed to in writing, software      #
# distributed under the License is distributed on an "AS IS" BASIS,        #
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. #
# See the License for the specific language governing permissions and      #
# limitations under the License.                                           #
############################################################################

# disable swap
if [[ -e "/usr/sbin/dphys-swapfile" ]]
then
    /usr/sbin/dphys-swapfile swapoff
    /usr/sbin/dphys-swapfile uninstall
fi

# purge packages and their configuration files
/usr/bin/apt purge \
    avahi-daemon \
    dphys-swapfile \
    nano \
    network-manager \
    pi-bluetooth \
    triggerhappy \
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

# clean up
/usr/bin/apt autoclean
/usr/bin/apt autoremove

# set country for wifi frequencies
/usr/bin/raspi-config nonint do_wifi_country DE

# enable necessary systemd service units
/usr/bin/systemctl enable \
    --now \
    ssh.service \
    systemd-networkd.service \
    wpa_supplicant \
    wpa_supplicant@wlan0.service

# disable unnecessary systemd service units
/usr/bin/systemctl disable \
    --now \
    apt-daily.timer \
    apt-daily.service \
    apt-daily-upgrade.timer \
    apt-daily-upgrade.service \
    avahi-daemon.service \
    dphys-swapfile.service \
    bluetooth.service

# mask unnecessary systemd service units
/usr/bin/systemctl mask \
    --now \
    systemd-binfmt.service \
    proc-sys-fs-binfmt_misc.mount \
    proc-sys-fs-binfmt_misc.automount
