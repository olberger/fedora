#!/bin/bash -eux

function ver { printf "%03d%03d%03d%03d" $(echo "$1" | tr '.' ' '); }

if [[ $UPDATE  =~ true || $UPDATE =~ 1 || $UPDATE =~ yes ]]; then
    echo "==> Applying updates"
    dnf -y update

    # Check if we're running Fedora 28
    grep -qi "Fedora release 28" /etc/fedora-release 
    if [ $? -eq 0 ]; then
        # Check if kernel is lower than required 4.17.4
        kernel_version=$(uname -r | sed 's/-.*//g')
        # if we lag behind, install not yet released kernel from https://koji.fedoraproject.org/koji/buildinfo?buildID=1102770
        if [ $(ver $kernel_version) -lt $(ver 4.17.4) ]; then
            echo "Need to update kernel to 4.17.4 needed for VirtualBox"
            mkdir kernel_update
            cd kernel_update
            packages="kernel-4.17.4-200.fc28.x86_64.rpm kernel-core-4.17.4-200.fc28.x86_64.rpm kernel-devel-4.17.4-200.fc28.x86_64.rpm kernel-headers-4.17.4-200.fc28.x86_64.rpm kernel-modules-4.17.4-200.fc28.x86_64.rpm kernel-modules-extra-4.17.4-200.fc28.x86_64.rpm"
            for p in $packages
            do
                wget -nv https://kojipkgs.fedoraproject.org//packages/kernel/4.17.4/200.fc28/x86_64/$p
            done
            dnf install -y $packages
            cd ..
            rm -fr kernel_update
        fi

    fi
    # reboot
    echo "Rebooting the machine..."
    reboot
fi
