--Step 1
root@docker-minikube-n01:~# df -Th
/*
Filesystem                        Type   Size  Used Avail Use% Mounted on
tmpfs                             tmpfs  488M  1.5M  486M   1% /run
/dev/mapper/ubuntu--vg-ubuntu--lv ext4    24G  7.3G   16G  33% /
tmpfs                             tmpfs  2.4G     0  2.4G   0% /dev/shm
tmpfs                             tmpfs  5.0M     0  5.0M   0% /run/lock
/dev/sda2                         ext4   2.0G  200M  1.6G  11% /boot
tmpfs                             tmpfs  487M   12K  487M   1% /run/user/1000
*/

--Step 1.0
root@docker-minikube-n01:~# hostnamectl
/*
 Static hostname: docker-minikube-n01.unidev.org.np
       Icon name: computer-vm
         Chassis: vm 🖴
      Machine ID: 50708e19b677484c92840925bff7e721
         Boot ID: e4ad18ac16ae40e99fbf08631c202c18
  Virtualization: vmware
Operating System: Ubuntu 24.04.4 LTS
          Kernel: Linux 6.8.0-111-generic
    Architecture: x86-64
 Hardware Vendor: VMware, Inc.
  Hardware Model: VMware Virtual Platform
Firmware Version: 6.00
   Firmware Date: Wed 2018-12-12
    Firmware Age: 7y 5month 2w 3d
*/

--Step 2 (Install Docker on Ubuntu)
root@docker-minikube-n01:~# apt update
/*
Get:1 http://security.ubuntu.com/ubuntu noble-security InRelease [126 kB]
Hit:2 http://archive.ubuntu.com/ubuntu noble InRelease
Get:3 http://security.ubuntu.com/ubuntu noble-security/main amd64 Components [42.4 kB]
Get:4 http://archive.ubuntu.com/ubuntu noble-updates InRelease [126 kB]
Get:5 http://security.ubuntu.com/ubuntu noble-security/universe amd64 Components [74.2 kB]
Get:6 http://archive.ubuntu.com/ubuntu noble-backports InRelease [126 kB]
Get:7 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 Packages [2,050 kB]
Get:8 http://archive.ubuntu.com/ubuntu noble-updates/main Translation-en [360 kB]
Get:9 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 Components [178 kB]
Get:10 http://archive.ubuntu.com/ubuntu noble-updates/universe amd64 Components [386 kB]
Get:11 http://archive.ubuntu.com/ubuntu noble-updates/multiverse amd64 Components [940 B]
Get:12 http://archive.ubuntu.com/ubuntu noble-backports/main amd64 Components [5,736 B]
Get:13 http://archive.ubuntu.com/ubuntu noble-backports/universe amd64 Components [10.5 kB]
Fetched 3,485 kB in 4s (907 kB/s)
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
18 packages can be upgraded. Run 'apt list --upgradable' to see them.
*/

--Step 2.1 (Install Docker on Ubuntu)
root@docker-minikube-n01:~# apt upgrade -y
/*
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
Calculating upgrade... Done
The following NEW packages will be installed:
  linux-headers-6.8.0-124 linux-headers-6.8.0-124-generic linux-image-6.8.0-124-generic linux-modules-6.8.0-124-generic linux-modules-extra-6.8.0-124-generic linux-tools-6.8.0-124
  linux-tools-6.8.0-124-generic
The following packages will be upgraded:
  bind9-dnsutils bind9-host bind9-libs libarchive13t64 libgcrypt20 libgnutls30t64 linux-generic linux-headers-generic linux-image-generic linux-libc-dev linux-tools-common rsync snapd vim
  vim-common vim-runtime vim-tiny xxd
18 upgraded, 7 newly installed, 0 to remove and 0 not upgraded.
12 standard LTS security updates
Need to get 226 MB/240 MB of archives.
After this operation, 302 MB of additional disk space will be used.
Get:1 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 linux-modules-6.8.0-124-generic amd64 6.8.0-124.124 [39.0 MB]
Get:2 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 linux-image-6.8.0-124-generic amd64 6.8.0-124.124 [14.8 MB]
Get:3 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 linux-modules-extra-6.8.0-124-generic amd64 6.8.0-124.124 [113 MB]
Get:4 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 linux-generic amd64 6.8.0-124.124 [1,696 B]
Get:5 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 linux-image-generic amd64 6.8.0-124.124 [11.4 kB]
Get:6 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 linux-headers-6.8.0-124 all 6.8.0-124.124 [13.5 MB]
Get:7 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 linux-headers-6.8.0-124-generic amd64 6.8.0-124.124 [3,659 kB]
Get:8 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 linux-headers-generic amd64 6.8.0-124.124 [11.2 kB]
Get:9 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 linux-libc-dev amd64 6.8.0-124.124 [1,442 kB]
Get:10 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 linux-tools-common all 6.8.0-124.124 [282 kB]
Get:11 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 linux-tools-6.8.0-124 amd64 6.8.0-124.124 [4,946 kB]
Get:12 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 linux-tools-6.8.0-124-generic amd64 6.8.0-124.124 [1,812 B]
Get:13 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 snapd amd64 2.75.2+ubuntu24.04 [35.1 MB]
Fetched 226 MB in 9s (25.4 MB/s)
(Reading database ... 126415 files and directories currently installed.)
Preparing to unpack .../rsync_3.2.7-1ubuntu1.4_amd64.deb ...
Unpacking rsync (3.2.7-1ubuntu1.4) over (3.2.7-1ubuntu1.2) ...
Preparing to unpack .../libgcrypt20_1.10.3-2ubuntu0.1_amd64.deb ...
Unpacking libgcrypt20:amd64 (1.10.3-2ubuntu0.1) over (1.10.3-2build1) ...
Setting up libgcrypt20:amd64 (1.10.3-2ubuntu0.1) ...
(Reading database ... 126415 files and directories currently installed.)
Preparing to unpack .../libgnutls30t64_3.8.3-1.1ubuntu3.6_amd64.deb ...
Unpacking libgnutls30t64:amd64 (3.8.3-1.1ubuntu3.6) over (3.8.3-1.1ubuntu3.5) ...
Setting up libgnutls30t64:amd64 (3.8.3-1.1ubuntu3.6) ...
(Reading database ... 126415 files and directories currently installed.)
Preparing to unpack .../00-vim_2%3a9.1.0016-1ubuntu7.14_amd64.deb ...
Unpacking vim (2:9.1.0016-1ubuntu7.14) over (2:9.1.0016-1ubuntu7.13) ...
Preparing to unpack .../01-vim-common_2%3a9.1.0016-1ubuntu7.14_all.deb ...
Unpacking vim-common (2:9.1.0016-1ubuntu7.14) over (2:9.1.0016-1ubuntu7.13) ...
Preparing to unpack .../02-vim-tiny_2%3a9.1.0016-1ubuntu7.14_amd64.deb ...
Unpacking vim-tiny (2:9.1.0016-1ubuntu7.14) over (2:9.1.0016-1ubuntu7.13) ...
Preparing to unpack .../03-vim-runtime_2%3a9.1.0016-1ubuntu7.14_all.deb ...
Unpacking vim-runtime (2:9.1.0016-1ubuntu7.14) over (2:9.1.0016-1ubuntu7.13) ...
Preparing to unpack .../04-xxd_2%3a9.1.0016-1ubuntu7.14_amd64.deb ...
Unpacking xxd (2:9.1.0016-1ubuntu7.14) over (2:9.1.0016-1ubuntu7.13) ...
Preparing to unpack .../05-bind9-dnsutils_1%3a9.18.39-0ubuntu0.24.04.5_amd64.deb ...
Unpacking bind9-dnsutils (1:9.18.39-0ubuntu0.24.04.5) over (1:9.18.39-0ubuntu0.24.04.3) ...
Preparing to unpack .../06-bind9-host_1%3a9.18.39-0ubuntu0.24.04.5_amd64.deb ...
Unpacking bind9-host (1:9.18.39-0ubuntu0.24.04.5) over (1:9.18.39-0ubuntu0.24.04.3) ...
Preparing to unpack .../07-bind9-libs_1%3a9.18.39-0ubuntu0.24.04.5_amd64.deb ...
Unpacking bind9-libs:amd64 (1:9.18.39-0ubuntu0.24.04.5) over (1:9.18.39-0ubuntu0.24.04.3) ...
Preparing to unpack .../08-libarchive13t64_3.7.2-2ubuntu0.7_amd64.deb ...
Unpacking libarchive13t64:amd64 (3.7.2-2ubuntu0.7) over (3.7.2-2ubuntu0.6) ...
Selecting previously unselected package linux-modules-6.8.0-124-generic.
Preparing to unpack .../09-linux-modules-6.8.0-124-generic_6.8.0-124.124_amd64.deb ...
Unpacking linux-modules-6.8.0-124-generic (6.8.0-124.124) ...
Selecting previously unselected package linux-image-6.8.0-124-generic.
Preparing to unpack .../10-linux-image-6.8.0-124-generic_6.8.0-124.124_amd64.deb ...
Unpacking linux-image-6.8.0-124-generic (6.8.0-124.124) ...
Selecting previously unselected package linux-modules-extra-6.8.0-124-generic.
Preparing to unpack .../11-linux-modules-extra-6.8.0-124-generic_6.8.0-124.124_amd64.deb ...
Unpacking linux-modules-extra-6.8.0-124-generic (6.8.0-124.124) ...
Preparing to unpack .../12-linux-generic_6.8.0-124.124_amd64.deb ...
Unpacking linux-generic (6.8.0-124.124) over (6.8.0-111.111) ...
Preparing to unpack .../13-linux-image-generic_6.8.0-124.124_amd64.deb ...
Unpacking linux-image-generic (6.8.0-124.124) over (6.8.0-111.111) ...
Selecting previously unselected package linux-headers-6.8.0-124.
Preparing to unpack .../14-linux-headers-6.8.0-124_6.8.0-124.124_all.deb ...
Unpacking linux-headers-6.8.0-124 (6.8.0-124.124) ...
Selecting previously unselected package linux-headers-6.8.0-124-generic.
Preparing to unpack .../15-linux-headers-6.8.0-124-generic_6.8.0-124.124_amd64.deb ...
Unpacking linux-headers-6.8.0-124-generic (6.8.0-124.124) ...
Preparing to unpack .../16-linux-headers-generic_6.8.0-124.124_amd64.deb ...
Unpacking linux-headers-generic (6.8.0-124.124) over (6.8.0-111.111) ...
Preparing to unpack .../17-linux-libc-dev_6.8.0-124.124_amd64.deb ...
Unpacking linux-libc-dev:amd64 (6.8.0-124.124) over (6.8.0-111.111) ...
Preparing to unpack .../18-linux-tools-common_6.8.0-124.124_all.deb ...
Unpacking linux-tools-common (6.8.0-124.124) over (6.8.0-111.111) ...
Selecting previously unselected package linux-tools-6.8.0-124.
Preparing to unpack .../19-linux-tools-6.8.0-124_6.8.0-124.124_amd64.deb ...
Unpacking linux-tools-6.8.0-124 (6.8.0-124.124) ...
Selecting previously unselected package linux-tools-6.8.0-124-generic.
Preparing to unpack .../20-linux-tools-6.8.0-124-generic_6.8.0-124.124_amd64.deb ...
Unpacking linux-tools-6.8.0-124-generic (6.8.0-124.124) ...
Preparing to unpack .../21-snapd_2.75.2+ubuntu24.04_amd64.deb ...
Unpacking snapd (2.75.2+ubuntu24.04) over (2.74.1+ubuntu24.04.4) ...
Setting up snapd (2.75.2+ubuntu24.04) ...
Installing new version of config file /etc/apparmor.d/usr.lib.snapd.snap-confine.real ...
snapd.failure.service is a disabled or a static unit not running, not starting it.
snapd.gpio-chardev-setup.target is a disabled or a static unit not running, not starting it.
snapd.snap-repair.service is a disabled or a static unit not running, not starting it.
Setting up bind9-libs:amd64 (1:9.18.39-0ubuntu0.24.04.5) ...
Setting up linux-libc-dev:amd64 (6.8.0-124.124) ...
Setting up xxd (2:9.1.0016-1ubuntu7.14) ...
Setting up linux-headers-6.8.0-124 (6.8.0-124.124) ...
Setting up vim-common (2:9.1.0016-1ubuntu7.14) ...
Setting up linux-modules-6.8.0-124-generic (6.8.0-124.124) ...
Setting up linux-modules-extra-6.8.0-124-generic (6.8.0-124.124) ...
Setting up linux-headers-6.8.0-124-generic (6.8.0-124.124) ...
Setting up vim-runtime (2:9.1.0016-1ubuntu7.14) ...
Setting up bind9-host (1:9.18.39-0ubuntu0.24.04.5) ...
Setting up linux-tools-common (6.8.0-124.124) ...
Setting up libarchive13t64:amd64 (3.7.2-2ubuntu0.7) ...
Setting up rsync (3.2.7-1ubuntu1.4) ...
rsync.service is a disabled or a static unit not running, not starting it.
Setting up linux-tools-6.8.0-124 (6.8.0-124.124) ...
Setting up vim (2:9.1.0016-1ubuntu7.14) ...
Setting up linux-image-6.8.0-124-generic (6.8.0-124.124) ...
I: /boot/vmlinuz.old is now a symlink to vmlinuz-6.8.0-111-generic
I: /boot/initrd.img.old is now a symlink to initrd.img-6.8.0-111-generic
I: /boot/vmlinuz is now a symlink to vmlinuz-6.8.0-124-generic
I: /boot/initrd.img is now a symlink to initrd.img-6.8.0-124-generic
Setting up linux-headers-generic (6.8.0-124.124) ...
Setting up vim-tiny (2:9.1.0016-1ubuntu7.14) ...
Setting up bind9-dnsutils (1:9.18.39-0ubuntu0.24.04.5) ...
Setting up linux-tools-6.8.0-124-generic (6.8.0-124.124) ...
Setting up linux-image-generic (6.8.0-124.124) ...
Setting up linux-generic (6.8.0-124.124) ...
Processing triggers for man-db (2.12.0-4build2) ...
Processing triggers for dbus (1.14.10-4ubuntu4.1) ...
Processing triggers for libc-bin (2.39-0ubuntu8.7) ...
Processing triggers for linux-image-6.8.0-124-generic (6.8.0-124.124) ...
/etc/kernel/postinst.d/initramfs-tools:
update-initramfs: Generating /boot/initrd.img-6.8.0-124-generic
/etc/kernel/postinst.d/zz-update-grub:
Sourcing file `/etc/default/grub'
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-6.8.0-124-generic
Found initrd image: /boot/initrd.img-6.8.0-124-generic
Found linux image: /boot/vmlinuz-6.8.0-111-generic
Found initrd image: /boot/initrd.img-6.8.0-111-generic
Found linux image: /boot/vmlinuz-6.8.0-41-generic
Found initrd image: /boot/initrd.img-6.8.0-41-generic
Warning: os-prober will not be executed to detect other bootable partitions.
Systems on them will not be added to the GRUB boot configuration.
Check GRUB_DISABLE_OS_PROBER documentation entry.
Adding boot menu entry for UEFI Firmware Settings ...
done
Scanning processes...
Scanning candidates...
Scanning linux images...

Pending kernel upgrade!
Running kernel version:
  6.8.0-111-generic
Diagnostics:
  The currently running kernel version is not the expected kernel version 6.8.0-124-generic.

Restarting the system to load the new kernel will not be handled automatically, so you should consider rebooting.

Restarting services...
 /etc/needrestart/restart.d/systemd-manager
 systemctl restart fwupd.service multipathd.service packagekit.service polkit.service rsyslog.service systemd-journald.service systemd-networkd.service systemd-resolved.service systemd-timesyncd.service udisks2.service

Service restarts being deferred:
 systemctl restart ModemManager.service
 /etc/needrestart/restart.d/dbus.service
 systemctl restart systemd-logind.service
 systemctl restart unattended-upgrades.service

No containers need to be restarted.

User sessions running outdated binaries:
 lab @ session #42: apt[2653], bash[2340]
 lab @ user manager service: systemd[2313]

No VM guests are running outdated hypervisor (qemu) binaries on this host.
*/

--Step 2.2 (Install Docker on Ubuntu)
root@docker-minikube-n01:~# apt install -y ca-certificates curl gnupg lsb-release
/*
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
ca-certificates is already the newest version (20240203).
ca-certificates set to manually installed.
curl is already the newest version (8.5.0-2ubuntu10.9).
curl set to manually installed.
gnupg is already the newest version (2.4.4-2ubuntu17.4).
gnupg set to manually installed.
lsb-release is already the newest version (12.0-2).
lsb-release set to manually installed.
The following packages were automatically installed and are no longer required:
  linux-headers-6.8.0-41 linux-headers-6.8.0-41-generic linux-image-6.8.0-41-generic linux-modules-6.8.0-41-generic linux-modules-extra-6.8.0-41-generic linux-tools-6.8.0-41
  linux-tools-6.8.0-41-generic
Use 'apt autoremove' to remove them.
0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
*/

--Step 2.3 (Install Docker on Ubuntu)
root@docker-minikube-n01:~# install -m 0755 -d /etc/apt/keyrings

--Step 2.4 (Install Docker on Ubuntu)
root@docker-minikube-n01:~# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

--Step 2.5 (Install Docker on Ubuntu)
root@docker-minikube-n01:~# chmod a+r /etc/apt/keyrings/docker.gpg

--Step 2.6 (Install Docker on Ubuntu)
root@docker-minikube-n01:~# echo \
  "deb [arch=$(dpkg --print-architecture) \
  signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

--Step 2.7 (Install Docker on Ubuntu)
root@docker-minikube-n01:~# apt update
/*
Get:1 https://download.docker.com/linux/ubuntu noble InRelease [48.5 kB]
Hit:2 http://security.ubuntu.com/ubuntu noble-security InRelease
Get:3 https://download.docker.com/linux/ubuntu noble/stable amd64 Packages [56.1 kB]
Hit:4 http://archive.ubuntu.com/ubuntu noble InRelease
Hit:5 http://archive.ubuntu.com/ubuntu noble-updates InRelease
Hit:6 http://archive.ubuntu.com/ubuntu noble-backports InRelease
Fetched 105 kB in 2s (50.1 kB/s)
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
All packages are up to date.
*/

--Step 2.8 (Install Docker on Ubuntu)
root@docker-minikube-n01:~# apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
/*
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following packages were automatically installed and are no longer required:
  linux-headers-6.8.0-41 linux-headers-6.8.0-41-generic linux-image-6.8.0-41-generic linux-modules-6.8.0-41-generic linux-modules-extra-6.8.0-41-generic linux-tools-6.8.0-41
  linux-tools-6.8.0-41-generic
Use 'apt autoremove' to remove them.
The following additional packages will be installed:
  docker-ce-rootless-extras pigz
Suggested packages:
  cgroupfs-mount | cgroup-lite docker-model-plugin
The following NEW packages will be installed:
  containerd.io docker-buildx-plugin docker-ce docker-ce-cli docker-ce-rootless-extras docker-compose-plugin pigz
0 upgraded, 7 newly installed, 0 to remove and 0 not upgraded.
Need to get 99.1 MB of archives.
After this operation, 378 MB of additional disk space will be used.
Get:1 http://archive.ubuntu.com/ubuntu noble/universe amd64 pigz amd64 2.8-1 [65.6 kB]
Get:2 https://download.docker.com/linux/ubuntu noble/stable amd64 containerd.io amd64 2.2.4-1~ubuntu.24.04~noble [23.6 MB]
Get:3 https://download.docker.com/linux/ubuntu noble/stable amd64 docker-ce-cli amd64 5:29.5.2-1~ubuntu.24.04~noble [17.0 MB]
Get:4 https://download.docker.com/linux/ubuntu noble/stable amd64 docker-ce amd64 5:29.5.2-1~ubuntu.24.04~noble [23.0 MB]
Get:5 https://download.docker.com/linux/ubuntu noble/stable amd64 docker-buildx-plugin amd64 0.34.1-1~ubuntu.24.04~noble [17.2 MB]
Get:6 https://download.docker.com/linux/ubuntu noble/stable amd64 docker-ce-rootless-extras amd64 5:29.5.2-1~ubuntu.24.04~noble [10.2 MB]
Get:7 https://download.docker.com/linux/ubuntu noble/stable amd64 docker-compose-plugin amd64 5.1.4-1~ubuntu.24.04~noble [8,126 kB]
Fetched 99.1 MB in 4s (22.7 MB/s)
Selecting previously unselected package containerd.io.
(Reading database ... 164441 files and directories currently installed.)
Preparing to unpack .../0-containerd.io_2.2.4-1~ubuntu.24.04~noble_amd64.deb ...
Unpacking containerd.io (2.2.4-1~ubuntu.24.04~noble) ...
Selecting previously unselected package docker-ce-cli.
Preparing to unpack .../1-docker-ce-cli_5%3a29.5.2-1~ubuntu.24.04~noble_amd64.deb ...
Unpacking docker-ce-cli (5:29.5.2-1~ubuntu.24.04~noble) ...
Selecting previously unselected package docker-ce.
Preparing to unpack .../2-docker-ce_5%3a29.5.2-1~ubuntu.24.04~noble_amd64.deb ...
Unpacking docker-ce (5:29.5.2-1~ubuntu.24.04~noble) ...
Selecting previously unselected package pigz.
Preparing to unpack .../3-pigz_2.8-1_amd64.deb ...
Unpacking pigz (2.8-1) ...
Selecting previously unselected package docker-buildx-plugin.
Preparing to unpack .../4-docker-buildx-plugin_0.34.1-1~ubuntu.24.04~noble_amd64.deb ...
Unpacking docker-buildx-plugin (0.34.1-1~ubuntu.24.04~noble) ...
Selecting previously unselected package docker-ce-rootless-extras.
Preparing to unpack .../5-docker-ce-rootless-extras_5%3a29.5.2-1~ubuntu.24.04~noble_amd64.deb ...
Unpacking docker-ce-rootless-extras (5:29.5.2-1~ubuntu.24.04~noble) ...
Selecting previously unselected package docker-compose-plugin.
Preparing to unpack .../6-docker-compose-plugin_5.1.4-1~ubuntu.24.04~noble_amd64.deb ...
Unpacking docker-compose-plugin (5.1.4-1~ubuntu.24.04~noble) ...
Setting up docker-buildx-plugin (0.34.1-1~ubuntu.24.04~noble) ...
Setting up containerd.io (2.2.4-1~ubuntu.24.04~noble) ...
Created symlink /etc/systemd/system/multi-user.target.wants/containerd.service → /usr/lib/systemd/system/containerd.service.
Setting up docker-compose-plugin (5.1.4-1~ubuntu.24.04~noble) ...
Setting up docker-ce-cli (5:29.5.2-1~ubuntu.24.04~noble) ...
Setting up pigz (2.8-1) ...
Setting up docker-ce-rootless-extras (5:29.5.2-1~ubuntu.24.04~noble) ...
Setting up docker-ce (5:29.5.2-1~ubuntu.24.04~noble) ...
Created symlink /etc/systemd/system/multi-user.target.wants/docker.service → /usr/lib/systemd/system/docker.service.
Created symlink /etc/systemd/system/sockets.target.wants/docker.socket → /usr/lib/systemd/system/docker.socket.
Processing triggers for man-db (2.12.0-4build2) ...
Scanning processes...
Scanning candidates...
Scanning linux images...

Pending kernel upgrade!
Running kernel version:
  6.8.0-111-generic
Diagnostics:
  The currently running kernel version is not the expected kernel version 6.8.0-124-generic.

Restarting the system to load the new kernel will not be handled automatically, so you should consider rebooting.

Restarting services...

Service restarts being deferred:
 /etc/needrestart/restart.d/dbus.service
 systemctl restart systemd-logind.service
 systemctl restart unattended-upgrades.service

No containers need to be restarted.

User sessions running outdated binaries:
 lab @ user manager service: systemd[2313]

No VM guests are running outdated hypervisor (qemu) binaries on this host.
*/

--Step 2.9 (Install Docker on Ubuntu)
root@docker-minikube-n01:~# systemctl status docker
/*
● docker.service - Docker Application Container Engine
     Loaded: loaded (/usr/lib/systemd/system/docker.service; enabled; preset: enabled)
     Active: active (running) since Sat 2026-05-30 17:15:41 +0545; 2min 15s ago
TriggeredBy: ● docker.socket
       Docs: https://docs.docker.com
   Main PID: 9486 (dockerd)
      Tasks: 9
     Memory: 27.6M (peak: 28.0M)
        CPU: 1.188s
     CGroup: /system.slice/docker.service
             └─9486 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock

May 30 17:15:40 docker-minikube-n01.unidev.org.np dockerd[9486]: time="2026-05-30T17:15:40.315632424+05:45" level=info msg="Restoring containers: start."
May 30 17:15:40 docker-minikube-n01.unidev.org.np dockerd[9486]: time="2026-05-30T17:15:40.428185593+05:45" level=info msg="Deleting nftables IPv4 rules" error="exit status 1" output="Er>
May 30 17:15:40 docker-minikube-n01.unidev.org.np dockerd[9486]: time="2026-05-30T17:15:40.448651037+05:45" level=info msg="Deleting nftables IPv6 rules" error="exit status 1" output="Er>
May 30 17:15:41 docker-minikube-n01.unidev.org.np dockerd[9486]: time="2026-05-30T17:15:41.461888924+05:45" level=info msg="Loading containers: done."
May 30 17:15:41 docker-minikube-n01.unidev.org.np dockerd[9486]: time="2026-05-30T17:15:41.492301771+05:45" level=info msg="Docker daemon" commit=568f755 containerd-snapshotter=true stor>
May 30 17:15:41 docker-minikube-n01.unidev.org.np dockerd[9486]: time="2026-05-30T17:15:41.492635151+05:45" level=info msg="Initializing buildkit"
May 30 17:15:41 docker-minikube-n01.unidev.org.np dockerd[9486]: time="2026-05-30T17:15:41.603648651+05:45" level=info msg="Completed buildkit initialization"
May 30 17:15:41 docker-minikube-n01.unidev.org.np dockerd[9486]: time="2026-05-30T17:15:41.626443198+05:45" level=info msg="Daemon has completed initialization"
May 30 17:15:41 docker-minikube-n01.unidev.org.np dockerd[9486]: time="2026-05-30T17:15:41.626619287+05:45" level=info msg="API listen on /run/docker.sock"
May 30 17:15:41 docker-minikube-n01.unidev.org.np systemd[1]: Started docker.service - Docker Application Container Engine.
*/

--Step 2.10 (Install Docker on Ubuntu)
root@docker-minikube-n01:~# systemctl enable docker
/*
Synchronizing state of docker.service with SysV service script with /usr/lib/systemd/systemd-sysv-install.
Executing: /usr/lib/systemd/systemd-sysv-install enable docker
*/

--Step 2.11 (Install Docker on Ubuntu)
root@docker-minikube-n01:~# docker --version
/*
Docker version 29.5.2, build 79eb04c
*/

--Step 2.12 (Install Docker on Ubuntu)
root@docker-minikube-n01:~# docker compose version
/*
Docker Compose version v5.1.4
*/

--Step 2.13 (Install Docker on Ubuntu)
root@docker-minikube-n01:~# docker images
/*                                                                                                                                                                         i Info →   U  In Use
IMAGE   ID             DISK USAGE   CONTENT SIZE   EXTRA
*/

--Step 2.14 (Install Docker on Ubuntu)
root@docker-minikube-n01:~# docker ps -a
/*
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
*/

--Step 3 (lab)
root@docker-minikube-n01:~# vi Dockerfile
/*
FROM nginx:latest
RUN apt update && apt install -y curl && apt install vim -y
COPY ./index.html /usr/share/nginx/html/
EXPOSE 80
*/

--Step 3.1 (lab)
root@docker-minikube-n01:~# vi index.html
/*
Hello World!!
*/

--Step 3.2 (lab)
root@docker-minikube-n01:~# docker login
/*
USING WEB-BASED LOGIN

i Info → To sign in with credentials on the command line, use 'docker login -u <username>'


Your one-time device confirmation code is: MHCV-LZMW
Press ENTER to open your browser or submit your device code here: https://login.docker.com/activate

Waiting for authentication in the browser…

WARNING! Your credentials are stored unencrypted in '/root/.docker/config.json'.
Configure a credential helper to remove this warning. See
https://docs.docker.com/go/credential-store/

Login Succeeded
*/

--Step 3.3 (lab)
root@docker-minikube-n01:~# docker build -t unidev39/undevetest:v1 .
/*
[+] Building 64.3s (9/9) FINISHED                                                                                                                                             docker:default
 => [internal] load build definition from Dockerfile                                                                                                                                    0.1s
 => => transferring dockerfile: 168B                                                                                                                                                    0.0s
 => [internal] load metadata for docker.io/library/nginx:latest                                                                                                                         3.5s
 => [auth] library/nginx:pull token for registry-1.docker.io                                                                                                                            0.0s
 => [internal] load .dockerignore                                                                                                                                                       0.0s
 => => transferring context: 2B                                                                                                                                                         0.0s
 => [1/3] FROM docker.io/library/nginx:latest@sha256:5aca99593157f4ae539a5dec1092a0ad8762f8e2eb1789085a13a0f5622369f6                                                                  12.6s
 => => resolve docker.io/library/nginx:latest@sha256:5aca99593157f4ae539a5dec1092a0ad8762f8e2eb1789085a13a0f5622369f6                                                                   0.1s
 => => sha256:13fd728be9eb1209aaccfb92774f28b57314202bfd8fde3c54179b84d60907d7 1.40kB / 1.40kB                                                                                          0.3s
 => => sha256:7f8b1a2b17d83cb2af2014ba3d9841933a83f729eefe67c5d73dd6a47263bbec 404B / 404B                                                                                              0.6s
 => => sha256:45381ecb0e2f57bc356fba7bca792013750edff8d0bf00c07ac2c7f1f0786aee 1.21kB / 1.21kB                                                                                          0.9s
 => => sha256:b4a248c845e558f875ac57f77d4498bb33110085b63ec15e966d186a939c94a0 955B / 955B                                                                                              0.9s
 => => sha256:5431d0092ffdcf1729150a2100fae1197ae414486b76bba246fe659a1b4a9b4e 628B / 628B                                                                                              0.7s
 => => sha256:830625e1ac85a8c72dd41b1403ea8210c7441aba69b752537d9a8a1b93ac87af 33.31MB / 33.31MB                                                                                        3.3s
 => => sha256:5b4d6ff92fc4e14e911b7753c954fac965d48c40fe1075758d284148ccace970 29.78MB / 29.78MB                                                                                        3.1s
 => => extracting sha256:5b4d6ff92fc4e14e911b7753c954fac965d48c40fe1075758d284148ccace970                                                                                               4.5s
 => => extracting sha256:830625e1ac85a8c72dd41b1403ea8210c7441aba69b752537d9a8a1b93ac87af                                                                                               3.8s
 => => extracting sha256:5431d0092ffdcf1729150a2100fae1197ae414486b76bba246fe659a1b4a9b4e                                                                                               0.0s
 => => extracting sha256:b4a248c845e558f875ac57f77d4498bb33110085b63ec15e966d186a939c94a0                                                                                               0.0s
 => => extracting sha256:7f8b1a2b17d83cb2af2014ba3d9841933a83f729eefe67c5d73dd6a47263bbec                                                                                               0.0s
 => => extracting sha256:45381ecb0e2f57bc356fba7bca792013750edff8d0bf00c07ac2c7f1f0786aee                                                                                               0.0s
 => => extracting sha256:13fd728be9eb1209aaccfb92774f28b57314202bfd8fde3c54179b84d60907d7                                                                                               0.0s
 => [internal] load build context                                                                                                                                                       0.0s
 => => transferring context: 51B                                                                                                                                                        0.0s
 => [2/3] RUN apt update && apt install -y curl && apt install vim -y                                                                                                                  31.5s
 => [3/3] COPY ./index.html /usr/share/nginx/html/                                                                                                                                      0.2s
 => exporting to image                                                                                                                                                                 16.0s
 => => exporting layers                                                                                                                                                                11.8s
 => => exporting manifest sha256:0491f6c8539ad7c0923cde7fed28e906aa4c0090f1071a648cae1612d6f7ef6a                                                                                       0.1s
 => => exporting config sha256:fb63ce5dcd503ae1cbf98dd871f34cf66612e4f0700a9262adac7ee240566e23                                                                                         0.0s
 => => exporting attestation manifest sha256:55d2e8c866cf0197afea960010a30712dcaf042dff728a8ad5b5d87de3df74a8                                                                           0.0s
 => => exporting manifest list sha256:36e06ac9a2ca2c75fd475ac48449620a6df642ca7dfd340b5d8136fe9caceafd                                                                                  0.0s
 => => naming to docker.io/unidev39/undevetest:v1                                                                                                                                       0.0s
 => => unpacking to docker.io/unidev39/undevetest:v1          
*/

--Step 3.4 (lab)
root@docker-minikube-n01:~# docker images
/*
                                                                                                                                                                         i Info →   U  In Use
IMAGE                    ID             DISK USAGE   CONTENT SIZE   EXTRA
unidev39/undevetest:v1   36e06ac9a2ca        342MB         94.6MB
*/

--Step 3.5 (lab)
root@docker-minikube-n01:~# docker push unidev39/undevetest:v1
/*
The push refers to repository [docker.io/unidev39/undevetest]
bdd37c9cf9ea: Pushed
5b4d6ff92fc4: Pushed
830625e1ac85: Pushed
45381ecb0e2f: Pushed
b4a248c845e5: Pushed
7f8b1a2b17d8: Pushed
57865ea86d0c: Pushed
3887646b5839: Pushed
5431d0092ffd: Pushed
13fd728be9eb: Pushed
v1: digest: sha256:36e06ac9a2ca2c75fd475ac48449620a6df642ca7dfd340b5d8136fe9caceafd size: 856
*/

--Step 3.6 (lab)
root@docker-minikube-n01:~# docker pull unidev39/undevetest:mytest2
/*
mytest2: Pulling from unidev39/undevetest
33d5d37cc0cf: Pull complete
b40150c1c271: Pull complete
Digest: sha256:918d591d0ac2b374e93ec831f3f39cf838bbf5f2b094dcb7c58ae6d7406fae2f
Status: Downloaded newer image for unidev39/undevetest:mytest2
docker.io/unidev39/undevetest:mytest2
*/

--Step 3.7 (lab)
root@docker-minikube-n01:~# docker images
/*                                                                                                                                                                         i Info →   U  In Use
                                                                                                                                                                         i Info →   U  In Use
IMAGE                         ID             DISK USAGE   CONTENT SIZE   EXTRA
unidev39/undevetest:mytest2   918d591d0ac2        347MB          101MB
unidev39/undevetest:v1        36e06ac9a2ca        342MB         94.6MB
*/

--Step 3.8 (lab)
root@docker-minikube-n01:~# docker run -d --name web-app -p 8081:80 unidev39/undevetest:v1
/*
ec511611a29ec8436c3ccfd1d7a4bc9d0c74f9c41dfbc63174318a4226bf31db
*/

--Step 3.9 (lab)
root@docker-minikube-n01:~# docker ps
/*
CONTAINER ID   IMAGE                    COMMAND                  CREATED          STATUS          PORTS                                     NAMES
ec511611a29e   unidev39/undevetest:v1   "/docker-entrypoint.…"   14 seconds ago   Up 14 seconds   0.0.0.0:8081->80/tcp, [::]:8081->80/tcp   web-app
*/

--Step 3.10 (lab)
root@docker-minikube-n01:~# docker exec -it ec511611a29e bash
root@ec511611a29e:/# curl localhost
/*
Hello World!!
*/

--Step 3.11 (lab)
root@ec511611a29e:/# exit
/*
exit
*/

--Step 4 (OS Configuration and KubeNet Installation)
root@kubnet-cp-1:~# vi prepare-node.sh
/*
#!/usr/bin/env bash
set -euo pipefail

# Usage: prepare-node.sh [k8s-minor-version]
# Example: prepare-node.sh 1.36   (default: 1.36)
K8S_VERSION="${1:-1.36}"

echo "==> Preparing node for Kubernetes ${K8S_VERSION}"

# ── Swap ──────────────────────────────────────────────────────────────────────
echo "==> Disabling swap"
swapoff -a
sed -i '/\bswap\b/d' /etc/fstab

# ── Kernel modules ────────────────────────────────────────────────────────────
echo "==> Loading kernel modules"
cat > /etc/modules-load.d/k8s.conf <<EOF
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

# ── sysctl ────────────────────────────────────────────────────────────────────
echo "==> Applying sysctl settings"
cat > /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system

# ── containerd ────────────────────────────────────────────────────────────────
echo "==> Installing containerd"
apt-get update -qq
apt-get install -y ca-certificates curl gnupg

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  > /etc/apt/sources.list.d/docker.list

apt-get update -qq
apt-get install -y containerd.io

echo "==> Configuring containerd (SystemdCgroup=true)"
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

systemctl enable --now containerd

# ── kubeadm / kubelet / kubectl ───────────────────────────────────────────────
echo "==> Installing kubeadm, kubelet, kubectl (v${K8S_VERSION})"
curl -fsSL "https://pkgs.k8s.io/core:/stable:/v${K8S_VERSION}/deb/Release.key" \
  | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
  https://pkgs.k8s.io/core:/stable:/v${K8S_VERSION}/deb/ /" \
  > /etc/apt/sources.list.d/kubernetes.list

apt-get update -qq
apt-get install kubeadm=1.36.0-1.1 kubelet=1.36.0-1.1 kubectl=1.36.0-1.1 -y
apt-mark hold kubelet kubeadm kubectl

systemctl enable --now kubelet

echo "==> Node ready for Kubernetes ${K8S_VERSION}"
echo "    Next: run 'kubeadm init' on the first control-plane node"
echo "          or 'kubeadm join' on worker/additional CP nodes"
*/

--Step 4.1 (OS Configuration and KubeNet Installation)
root@docker-minikube-n01:~# chmod -R 775 prepare-node.sh

--Step 4.2 (OS Configuration and KubeNet Installation)
root@docker-minikube-n01:~# ll prepare-node.sh
/*
-rwxrwxr-x 1 root root 3188 May 30 17:36 prepare-node.sh*
*/

--Step 4.3 (OS Configuration and KubeNet Installation)
root@docker-minikube-n01:~# bash ./prepare-node.sh
/*
==> Preparing node for Kubernetes 1.36
==> Disabling swap
==> Loading kernel modules
==> Applying sysctl settings
* Applying /usr/lib/sysctl.d/10-apparmor.conf ...
* Applying /etc/sysctl.d/10-bufferbloat.conf ...
* Applying /etc/sysctl.d/10-console-messages.conf ...
* Applying /etc/sysctl.d/10-ipv6-privacy.conf ...
* Applying /etc/sysctl.d/10-kernel-hardening.conf ...
* Applying /etc/sysctl.d/10-magic-sysrq.conf ...
* Applying /etc/sysctl.d/10-map-count.conf ...
* Applying /etc/sysctl.d/10-network-security.conf ...
* Applying /etc/sysctl.d/10-ptrace.conf ...
* Applying /etc/sysctl.d/10-zeropage.conf ...
* Applying /usr/lib/sysctl.d/50-pid-max.conf ...
* Applying /usr/lib/sysctl.d/99-protect-links.conf ...
* Applying /etc/sysctl.d/99-sysctl.conf ...
* Applying /etc/sysctl.d/k8s.conf ...
* Applying /etc/sysctl.conf ...
kernel.apparmor_restrict_unprivileged_userns = 1
net.core.default_qdisc = fq_codel
kernel.printk = 4 4 1 7
net.ipv6.conf.all.use_tempaddr = 2
net.ipv6.conf.default.use_tempaddr = 2
kernel.kptr_restrict = 1
kernel.sysrq = 176
vm.max_map_count = 1048576
net.ipv4.conf.default.rp_filter = 2
net.ipv4.conf.all.rp_filter = 2
kernel.yama.ptrace_scope = 1
vm.mmap_min_addr = 65536
kernel.pid_max = 4194304
fs.protected_fifos = 1
fs.protected_hardlinks = 1
fs.protected_regular = 2
fs.protected_symlinks = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
==> Installing containerd
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
ca-certificates is already the newest version (20240203).
curl is already the newest version (8.5.0-2ubuntu10.9).
gnupg is already the newest version (2.4.4-2ubuntu17.4).
The following packages were automatically installed and are no longer required:
  linux-headers-6.8.0-41 linux-headers-6.8.0-41-generic linux-image-6.8.0-41-generic linux-modules-6.8.0-41-generic linux-modules-extra-6.8.0-41-generic linux-tools-6.8.0-41
  linux-tools-6.8.0-41-generic
Use 'apt autoremove' to remove them.
0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
File '/etc/apt/keyrings/docker.gpg' exists. Overwrite? (y/N) y
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
containerd.io is already the newest version (2.2.4-1~ubuntu.24.04~noble).
The following packages were automatically installed and are no longer required:
  linux-headers-6.8.0-41 linux-headers-6.8.0-41-generic linux-image-6.8.0-41-generic linux-modules-6.8.0-41-generic linux-modules-extra-6.8.0-41-generic linux-tools-6.8.0-41
  linux-tools-6.8.0-41-generic
Use 'apt autoremove' to remove them.
0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
==> Configuring containerd (SystemdCgroup=true)
==> Installing kubeadm, kubelet, kubectl (v1.36)
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following packages were automatically installed and are no longer required:
  linux-headers-6.8.0-41 linux-headers-6.8.0-41-generic linux-image-6.8.0-41-generic linux-modules-6.8.0-41-generic linux-modules-extra-6.8.0-41-generic linux-tools-6.8.0-41
  linux-tools-6.8.0-41-generic
Use 'apt autoremove' to remove them.
The following additional packages will be installed:
  cri-tools kubernetes-cni
The following NEW packages will be installed:
  cri-tools kubeadm kubectl kubelet kubernetes-cni
0 upgraded, 5 newly installed, 0 to remove and 0 not upgraded.
Need to get 93.0 MB of archives.
After this operation, 331 MB of additional disk space will be used.
Get:1 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.36/deb  cri-tools 1.36.0-1.1 [16.3 MB]
Get:2 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.36/deb  kubeadm 1.36.0-1.1 [12.5 MB]
Get:3 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.36/deb  kubectl 1.36.0-1.1 [11.8 MB]
Get:4 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.36/deb  kubernetes-cni 1.9.1-1.1 [39.0 MB]
Get:5 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.36/deb  kubelet 1.36.0-1.1 [13.4 MB]
Fetched 93.0 MB in 6s (16.5 MB/s)
Selecting previously unselected package cri-tools.
(Reading database ... 164678 files and directories currently installed.)
Preparing to unpack .../cri-tools_1.36.0-1.1_amd64.deb ...
Unpacking cri-tools (1.36.0-1.1) ...
Selecting previously unselected package kubeadm.
Preparing to unpack .../kubeadm_1.36.0-1.1_amd64.deb ...
Unpacking kubeadm (1.36.0-1.1) ...
Selecting previously unselected package kubectl.
Preparing to unpack .../kubectl_1.36.0-1.1_amd64.deb ...
Unpacking kubectl (1.36.0-1.1) ...
Selecting previously unselected package kubernetes-cni.
Preparing to unpack .../kubernetes-cni_1.9.1-1.1_amd64.deb ...
Unpacking kubernetes-cni (1.9.1-1.1) ...
Selecting previously unselected package kubelet.
Preparing to unpack .../kubelet_1.36.0-1.1_amd64.deb ...
Unpacking kubelet (1.36.0-1.1) ...
Setting up kubectl (1.36.0-1.1) ...
Setting up cri-tools (1.36.0-1.1) ...
Setting up kubernetes-cni (1.9.1-1.1) ...
Setting up kubeadm (1.36.0-1.1) ...
Setting up kubelet (1.36.0-1.1) ...
Scanning processes...
Scanning linux images...

Running kernel seems to be up-to-date.

No services need to be restarted.

No containers need to be restarted.

No user sessions are running outdated binaries.

No VM guests are running outdated hypervisor (qemu) binaries on this host.
kubelet set on hold.
kubeadm set on hold.
kubectl set on hold.
==> Node ready for Kubernetes 1.36
    Next: run 'kubeadm init' on the first control-plane node
          or 'kubeadm join' on worker/additional CP nodes
*/


--Go To https://minikube.sigs.k8s.io/docs/start/?arch=%2Flinux%2Fx86-64%2Fstable%2Fbinary+download
--Step 5 (MiniKube Installation)
root@docker-minikube-n01:~# curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
/*
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
  0     0    0     0    0     0      0      0 --:--:--  0:00:01 --:--:--     0
100  128M  100  128M    0     0  17.8M      0  0:00:07  0:00:07 --:--:-- 23.0M
*/

--Step 5.1 (MiniKube Installation)
root@docker-minikube-n01:~# sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64

--Step 5.2 (Configuration of ContorlPlane and WorkerNode Using MiniKube)
root@docker-minikube-n01:~# minikube start --nodes 2 --force
/*
* minikube v1.38.1 on Ubuntu 24.04
! minikube skips various validations when --force is supplied; this may lead to unexpected behavior
* Automatically selected the docker driver. Other choices: none, ssh
* The "docker" driver should not be used with root privileges. If you wish to continue as root, use --force.
* If you are running minikube within a VM, consider using --driver=none:
*   https://minikube.sigs.k8s.io/docs/reference/drivers/none/
! Starting v1.39.0, minikube will default to "containerd" container runtime. See #21973 for more info.
* Using Docker driver with root privileges
* Starting "minikube" primary control-plane node in "minikube" cluster
* Pulling base image v0.0.50 ...
* Downloading Kubernetes v1.35.1 preload ...
    > preloaded-images-k8s-v18-v1...:  272.45 MiB / 272.45 MiB  100.00% 14.00 M
    > gcr.io/k8s-minikube/kicbase...:  519.58 MiB / 519.58 MiB  100.00% 16.95 M
* Creating docker container (CPUs=2, Memory=3072MB) ...
* Preparing Kubernetes v1.35.1 on Docker 29.2.1 ...
* Configuring CNI (Container Networking Interface) ...
* Verifying Kubernetes components...
  - Using image gcr.io/k8s-minikube/storage-provisioner:v5
* Enabled addons: storage-provisioner, default-storageclass

* Starting "minikube-m02" worker node in "minikube" cluster
* Pulling base image v0.0.50 ...
* Creating docker container (CPUs=2, Memory=3072MB) ...
* Found network options:
  - NO_PROXY=192.168.49.2
* Preparing Kubernetes v1.35.1 on Docker 29.2.1 ...
  - env NO_PROXY=192.168.49.2
* Verifying Kubernetes components...
* Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
*/

--Step 6
root@docker-minikube-n01:~# kubectl get nodes
/*
NAME           STATUS   ROLES           AGE     VERSION
minikube       Ready    control-plane   4m41s   v1.35.1
minikube-m02   Ready    <none>          2m35s   v1.35.1
*/

--Step 6.1
root@docker-minikube-n01:~# kubectl get nodes -o wide
/*
NAME           STATUS   ROLES           AGE     VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE                         KERNEL-VERSION      CONTAINER-RUNTIME
minikube       Ready    control-plane   2m43s   v1.35.1   192.168.49.2   <none>        Debian GNU/Linux 12 (bookworm)   6.8.0-124-generic   docker://29.2.1
minikube-m02   Ready    <none>          37s     v1.35.1   192.168.49.3   <none>        Debian GNU/Linux 12 (bookworm)   6.8.0-124-generic   docker://29.2.1
*/

--Step 6.2
root@docker-minikube-n01:~# kubectl get pods -A
/*
NAMESPACE     NAME                               READY   STATUS    RESTARTS   AGE
kube-system   coredns-7d764666f9-ml5ws           1/1     Running   0          2m41s
kube-system   etcd-minikube                      1/1     Running   0          2m49s
kube-system   kindnet-h4f8z                      1/1     Running   0          47s
kube-system   kindnet-kww4b                      1/1     Running   0          2m41s
kube-system   kube-apiserver-minikube            1/1     Running   0          2m50s
kube-system   kube-controller-manager-minikube   1/1     Running   0          2m50s
kube-system   kube-proxy-fz5t9                   1/1     Running   0          2m42s
kube-system   kube-proxy-jmrnt                   1/1     Running   0          47s
kube-system   kube-scheduler-minikube            1/1     Running   0          2m51s
kube-system   storage-provisioner                1/1     Running   0          2m40s
*/

--Step 7 (lab)
root@docker-minikube-n01:~# docker images
/*
                                                                                                                                                                         i Info →   U  In Use
IMAGE                                                                                                 ID             DISK USAGE   CONTENT SIZE   EXTRA
gcr.io/k8s-minikube/kicbase:v0.0.50                                                                   b97074569ae9       1.94GB          545MB
gcr.io/k8s-minikube/kicbase@sha256:eb4fec00e8ad70adf8e6436f195cc429825ffb85f95afcdb5d8d9deb576f3e93   eb4fec00e8ad       1.94GB          545MB    U
unidev39/undevetest:mytest2                                                                           918d591d0ac2        347MB          101MB    U
unidev39/undevetest:v1                                                                                36e06ac9a2ca        342MB         94.6MB    U
*/

--Step 7.1 (lab)
root@docker-minikube-n01:~# docker ps
/*
CONTAINER ID   IMAGE                                 COMMAND                  CREATED              STATUS              PORTS                                                                                                                                  NAMES
3de0dc7691a1   gcr.io/k8s-minikube/kicbase:v0.0.50   "/usr/local/bin/entr…"   About a minute ago   Up About a minute   127.0.0.1:32773->22/tcp, 127.0.0.1:32774->2376/tcp, 127.0.0.1:32775->5000/tcp, 127.0.0.1:32776->8443/tcp, 127.0.0.1:32777->32443/tcp   minikube-m02
aa9303d98953   gcr.io/k8s-minikube/kicbase:v0.0.50   "/usr/local/bin/entr…"   3 minutes ago        Up 3 minutes        127.0.0.1:32768->22/tcp, 127.0.0.1:32769->2376/tcp, 127.0.0.1:32770->5000/tcp, 127.0.0.1:32771->8443/tcp, 127.0.0.1:32772->32443/tcp   minikube
ec511611a29e   unidev39/undevetest:v1                "/docker-entrypoint.…"   33 minutes ago       Up 33 minutes       0.0.0.0:8081->80/tcp, [::]:8081->80/tcp                                                                                                web-app
*/

--Step 7.2 (lab)
root@docker-minikube-n01:~# kubectl create ns myapp
/*
namespace/myapp created
*/

--Step 7.3 (lab)
root@docker-minikube-n01:~# kubectl create deployment frontent-deploy --image 92manishmhr/hello-web:v1 --namespace=myapp --dry-run=client -o yaml
/*
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: frontent-deploy
  name: frontent-deploy
  namespace: myapp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: frontent-deploy
  strategy: {}
  template:
    metadata:
      labels:
        app: frontent-deploy
    spec:
      containers:
      - image: 92manishmhr/hello-web:v1
        name: hello-web
        resources: {}
status: {}
*/

--Step 7.4 (lab)
root@docker-minikube-n01:~# kubectl create deployment frontent-deploy --image 92manishmhr/hello-web:v1 --namespace=myapp --dry-run=client -o yaml > frontend-deploy.yaml

--Step 7.5 (lab)
root@docker-minikube-n01:~# kubectl get deployment
/*
No resources found in default namespace.
*/

--Step 7.6 (lab)
root@docker-minikube-n01:~# kubectl create -f frontend-deploy.yaml -n myapp
/*
deployment.apps/frontent-deploy created
*/

--Step 7.7 (lab)
root@docker-minikube-n01:~# kubectl get deployment -n myapp
/*
NAME              READY   UP-TO-DATE   AVAILABLE   AGE
frontent-deploy   0/1     1            0           16s
*/

--Step 7.8 (lab)
root@docker-minikube-n01:~# kubectl get pod -n myapp
/*
NAME                               READY   STATUS    RESTARTS   AGE
frontent-deploy-7b7b57c999-c4nll   1/1     Running   0          34s
*/

--Step 7.9 (lab)
root@docker-minikube-n01:~# kubectl exec -it frontent-deploy-7b7b57c999-c4nll -n myapp -- sh
# curl localhost
/*
<h1>Hello World!!</h1>
*/
# exit

--To Delete the deployment pods
--kubectl delete pod frontent-deploy-8f6566d5d-wpj55 -n myapp
--kubectl delete deployment frontent-deploy -n myapp

