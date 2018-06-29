#!/bin/bash -eux

SSH_USER=${SSH_USERNAME:-vagrant}
SSH_USER_HOME=${SSH_USER_HOME:-/home/${SSH_USER}}

if [[ $PACKER_BUILDER_TYPE =~ virtualbox ]]; then
    echo "==> Installing VirtualBox guest additions"
    # Need to set the KERN_DIR in Fedora 26 and 27 or the VBox additions will not install
    /usr/libexec/system-python -mplatform | grep -qi "fedora-2[67]" && echo "Fedora 26 or 27 detected" && \
        KERN_DIR=/usr/src/kernels/"$(uname -r)" && export KERN_DIR
    if [ "x$KEN_DIR" != "x" ]; then
        # Some of these packages should already have been installed in the kickstart
        dnf -y install kernel-headers-"$(uname -r)" kernel-devel-"$(uname -r)" gcc make perl
        VBOX_VERSION=$(cat $SSH_USER_HOME/.vbox_version)
        mount -o loop $SSH_USER_HOME/VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
        sh /mnt/VBoxLinuxAdditions.run --nox11
        umount /mnt
    else
        echo "Detected no Fedora 26 or 27, so not attempting to install VirtualBox guest additions."
        # We're probably in Fedora 28 workstation
        # Try installation of vboxsf which dodn't make it : https://fedoraproject.org/wiki/Common_F28_bugs#VBox_Guest_Additions
        echo "Attempting installation of vboxsf"
        git clone https://github.com/jwrdegoede/vboxsf/
        dnf -y install dkms
        cd vboxsf
        make
        make modules_install
        modprobe vboxsf
    fi
    rm -rf $SSH_USER_HOME/VBoxGuestAdditions_$VBOX_VERSION.iso
    rm -f $SSH_USER_HOME/.vbox_version
fi
