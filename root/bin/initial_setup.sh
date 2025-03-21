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

# global variables
script_directory_path="${0%/*}"

# disable swap
if [[ -e "/usr/sbin/dphys-swapfile" ]]
then
    echo -e "\e[01;33mRemoving swapfile...\e[0m\n" >&2
    /usr/sbin/dphys-swapfile swapoff
    /usr/sbin/dphys-swapfile uninstall
fi

# purge packages and their configuration files
echo -e "\n\e[01;33mPurging packages...\e[0m" >&2
/usr/bin/apt purge \
    avahi-daemon \
    dphys-swapfile \
    nano \
    network-manager \
    pi-bluetooth \
    rpicam-apps-lite \
    triggerhappy \
    vim-common

# update package cache
echo -e "\n\e[01;33mUpdating package cache...\e[0m" >&2
/usr/bin/apt update
# install packages
echo -e "\n\e[01;33mInstalling packages...\e[0m" >&2
/usr/bin/apt install \
    neovim

# install "log2ram"; see also "/etc/apt/sources.list.d/azlux.list"
/usr/bin/wget "https://azlux.fr/repo.gpg" \
    --output-document="/usr/share/keyrings/azlux-archive-keyring.gpg"
/usr/bin/apt install \
    log2ram

# clean up
echo -e "\n\e[01;33mCleaning up packages...\e[0m" >&2
/usr/bin/apt autoclean
/usr/bin/apt autoremove

# set country for wifi frequencies
echo -e "\n\e[01;33mSetting country for wifi frequencies...\e[0m" >&2
/usr/bin/raspi-config nonint do_wifi_country DE

# enable necessary systemd service units
echo -e "\n\e[01;33mEnabling necessary systemd service units...\e[0m" >&2
declare -a service_unit_enable_array
service_unit_enable_array=(\
                                "ssh.service" \
                                "systemd-networkd.service" \
                          )
for service_unit_enable in "${service_unit_enable_array[@]}"
do
    /usr/bin/systemctl enable --now "${service_unit_enable}"
done

# disable unnecessary systemd service units
echo -e "\n\e[01;33mDisabling unnecessary systemd service units...\e[0m" >&2
declare -a service_unit_disable_array
service_unit_disable_array=(\
                                "apt-daily.timer" \
                                "apt-daily.service" \
                                "apt-daily-upgrade.timer" \
                                "apt-daily-upgrade.service" \
                                "avahi-daemon.service" \
                                "bluetooth.service" \
                                "dphys-swapfile.service" \
                                "systemd-network-generator.service" \
                                "wpa_supplicant.service" \
                                "wpa_supplicant@wlan0.service" \
                           )
for service_unit_disable in "${service_unit_disable_array[@]}"
do
    /usr/bin/systemctl disable --now "${service_unit_disable}"
done

# mask unnecessary systemd service units
echo -e "\n\e[01;33mMasking unnecessary systemd service units...\e[0m" >&2
declare -a service_unit_mask_array
service_unit_mask_array=(\
                            "systemd-binfmt.service" \
                            "proc-sys-fs-binfmt_misc.mount" \
                            "proc-sys-fs-binfmt_misc.automount" \
                        )
for service_unit_mask in "${service_unit_mask_array[@]}"
do
    /usr/bin/systemctl mask --now "${service_unit_mask}"
done

# include custom configurations
source "${script_directory_path}/initial_setup_local.sh"
