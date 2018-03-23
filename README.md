# os-image-builder
####Table of Contents

1. [Overview](#overview)
2. [Requirements](#requirements)
3. [Configuration](#configuration)
4. [Usage](#usage)
5. [MOS9 build](#mos9-build)

## Overview

os-image-builder creates OS installation ISO image based on Ubuntu CD/CentOS 7 CD  
for offline installation of Managed Services appliances.

## Requirements

The image builder is known to work on Ubuntu and Mac OS X, so it is suggested to use this distribution on your build host.
You also need to download and install the following tools:
 * Packer image building tool (https://www.packer.io/docs/installation.html)
 * GnuPG
 * QEMU machine emulator and virtualizer for Linux
 * Virtual Box for MAC OS X

## Configuration

Before running the image builder for the first time please generate a new key pair:

~~~
$ gpg --gen-key
~~~

Follow the prompts to specify your name, email, and other items.

Make sure you can find pubring.gpg and secring.gpg files under $HOME/.gnupg directory. Also, you should be to see your newly generated keys by issuing `gpg -k` and `gpg -K` commands to list keys from the public and secret keyrings accordingly.

## Ubuntu-base image
Open `base.json` in your favorite text editor and find `variables` section at the top of the file, you may need to modify some parameters there. The following parameters are available:
 * `iso`: specifies a file system path to the official Ubuntu installation CD image
 * `iso_md5`: MD5 hash of the installation CD image
 * `preseed`: specifies a file system path to a custom preseed file to be used for the installation (`config/custom.seed` is used by default)
 * `gpg_pubring`: path to pubring.gpg file
 * `gpg_secring`: path to secring.gpg file
 * `gpg_uid`: user id of your key (`gpg -k` command can be used to retrieve it)
 * `deb_packages`: a list of extra deb packages to be included into the pool structure of your target image (note that these packages won't be installed unless you specify them in a custom preseed file too)
 * `py_packages`: a list of Python packages to be included into the PyPI repository on the target image  (note that these packages won't be installed unless you specify them in `d-i preseed/late_command` of your custom preseed file)
 * `dst_iso`: specifies a file system path to the target ISO image


## CentOS7 based image
Open `centos7_gluster.json` in your favorite text editor and find `variables` section at the top of the file, you may need to modify some parameters there. The following parameters are available:
 * `iso`: specifies a file system path to the official CentOS  installation CD image
 * `iso_md5`: MD5 hash of the installation CD image
 * `rpm_packages`: a list of extra rpm  packages to be included into the repo  on  your target image and will be installed
 * `py_packages`: a list of Python packages to be included into the PyPI repository on the target image  (note that these packages won't be installed unless you specify them in `d-i preseed/late_command` of your custom preseed file)
 * `dst_iso`: specifies a file system path to the target ISO image


## Usage


Simply run `packer build base.json` command from the project directory and wait until it's done.


For Mac OS:

~~~
$ brew install packer
~~~
~~~
$ packer build -only virtualbox-iso centos7_gluster.json
~~~

## MOS9 build

1. Install packer from packer.io
   ```
   # packer setup
   mkdir $HOME/packer
   cd $HOME/packer
   wget 'https://releases.hashicorp.com/packer/1.2.1/packer_1.2.1_linux_amd64.zip' -O  packer.zip \
   && unzip packer.zip && sudo install packer /usr/sbin/
   ```
2. Install hypervisor and rest required packages:
   ```
   apt install -y unzip devscripts mc git libvirt-bin qemu-kvm qemu-system-x86 virtinst \
   virt-goodies virt-what virt-top sshpass
   ```
   Also ensure that you are able to use kvm acceleration:
   ```
   cat /proc/cpuinfo | grep vmx
   ```
3. Update your host network setup like:
   ```
   # /etc/network/interfaces
   auto lo
   iface lo inet loopback
      dns-nameservers 10.10.11.1 223.5.5.5
      cdns-search maas mcp-demo-lab.local mcp-test mcp.local
   auto eno1
   iface eno1 inet manual
       mtu 1500
   auto eno2
   iface eno2 inet manual
       mtu 1500
   auto eno3
   iface eno3 inet manual
   auto br-mgm0
   iface br-mgm0 inet static
       address 10.10.11.117/24
       dns-nameservers 10.10.11.1 223.5.5.5
       gateway 10.10.11.254
       mtu 1500
       bridge_ports eno3
       bridge_stp off
       bridge_fd 0
       bridge_maxwait 0
   auto br-adm0
   iface br-adm0 inet static
       address 10.20.0.1/24
       mtu 1500
       bridge_ports none
       bridge_stp off
       bridge_fd 0
       bridge_maxwait 0
   ```
4. Generate unique MAC addresses and set *adm_mac* and *mgm_mac* parameters in the `fuel9-build.json` file.
   ```
   printf 'DE:AD:BE:EF:%02X:%02X\n' $((RANDOM%256)) $((RANDOM%256))
   ```
5. Make symlinks for qemy helper scripts:
   ```
   cd scripts
   ln -s qemu-ifup_brname qemu-ifup_br-adm0
   ln -s qemu-ifup_brname qemu-ifup_br-mgm0
   ln -s qemu-ifdown_brname qemu-ifdown_br-adm0
   ln -s qemu-ifdown_brname qemu-ifdown_br-mgm0
   cd ..
   ```
6. Download MOS - Mirantis OpenStack ISO from [official download page](https://www.mirantis.com/software/openstack/download/). Find md5 checksum:
   ```
   md5sum MirantisOpenStack-9.0.iso
   ```
   Update *fuel9_iso_md5* parameter in the `fuel9-build.json` file with obtained result if necessary.

6. Run build and capture qcow2 image under *output-virt-fuel* folder
   ```
   sudo PACKER_LOG=1 packer build fuel9-build.json
   ```
