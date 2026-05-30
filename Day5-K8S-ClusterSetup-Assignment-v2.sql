--Step 0
root@kubnet-lb:~# df -Th
/*
Filesystem                        Type   Size  Used Avail Use% Mounted on
tmpfs                             tmpfs  488M  1.5M  486M   1% /run
/dev/mapper/ubuntu--vg-ubuntu--lv ext4    24G  7.1G   16G  32% /
tmpfs                             tmpfs  2.4G     0  2.4G   0% /dev/shm
tmpfs                             tmpfs  5.0M     0  5.0M   0% /run/lock
/dev/sda2                         ext4   2.0G  200M  1.6G  11% /boot
tmpfs                             tmpfs  488M   12K  487M   1% /run/user/1000
*/

--Step 0.1
root@kubnet-lb:~# hostnamectl
/*
 Static hostname: kubnet-lb.unidev.org.np
       Icon name: computer-vm
         Chassis: vm 🖴
      Machine ID: 50708e19b677484c92840925bff7e721
         Boot ID: 4ee7f0b7205546f1a39c12f08503c389
  Virtualization: vmware
Operating System: Ubuntu 24.04.4 LTS
          Kernel: Linux 6.8.0-111-generic
    Architecture: x86-64
 Hardware Vendor: VMware, Inc.
  Hardware Model: VMware Virtual Platform
Firmware Version: 6.00
   Firmware Date: Wed 2018-12-12
    Firmware Age: 7y 5month 2w 2d
*/

--Step 1
root@kubnet-lb:~# vi /etc/netplan/50-cloud-init.yaml
/*
# This file is generated from information provided by the datasource.  Changes
# to it will not persist across an instance reboot.  To disable cloud-init's
# network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
    ethernets:
        ens192:
            addresses:
            - 192.1.6.28/24
            nameservers:
                addresses:
                - 192.1.4.11
                - 192.1.4.12
                search: []
            routes:
            -   to: default
                via: 192.1.6.1
    version: 2
*/

--Step 1.1
root@kubnet-lb:~# sudo systemctl restart network-online.target

--Step 1.2
root@kubnet-lb:~# sudo systemctl status network-online.target
/*
● network-online.target - Network is Online
     Loaded: loaded (/usr/lib/systemd/system/network-online.target; static)
     Active: active since Fri 2026-05-29 12:04:04 +0545; 6s ago
       Docs: man:systemd.special(7)
             https://systemd.io/NETWORK_ONLINE

May 29 12:04:04 kubnet-lb.unidev.org.np systemd[1]: Stopping network-online.target - Network is Online...
May 29 12:04:04 kubnet-lb.unidev.org.np systemd[1]: Reached target network-online.target - Network is Online.
*/

--Step 2
root@kubnet-lb:~# vi /etc/hosts
/*
#Kubnet-LB
192.1.6.28 kubnet-lb.unidev.org.np kubnet-lb

#Kubnet-CP-1
192.1.6.29 kubnet-cp-1.unidev.org.np kubnet-cp-1

#Kubnet-CP-2
192.1.6.30 kubnet-cp-2.unidev.org.np kubnet-cp-2

#Kubnet-CP-3
192.1.6.31 kubnet-cp-3.unidev.org.np kubnet-cp-3

#Kubnet-Worker-1
192.1.6.32 kubnet-worker-1.unidev.org.np kubnet-worker-1
*/

--Step 3
root@kubnet-lb:~# nslookup kubnet-lb.unidev.org.np
/*
Server:         127.0.0.53
Address:        127.0.0.53#53

Name:   kubnet-lb.unidev.org.np
Address: 192.1.6.28
*/

--Step 4
root@kubnet-lb:~# vi setup-haproxy-local.sh
/*
#!/usr/bin/env bash
set -euo pipefail

# Put the CP private IPs
CP1_IP=192.1.6.28
CP2_IP=192.1.6.29
CP3_IP=192.1.6.30

echo "CP IPs: ${CP1_IP}, ${CP2_IP}, ${CP3_IP}"

# Install HAProxy
apt-get update -qq
apt-get install -y haproxy dnsutils

# Write config
cat > /etc/haproxy/haproxy.cfg << EOF
global
    log /dev/log local0
    maxconn 4096
    daemon

defaults
    log     global
    mode    tcp
    option  tcplog
    option  dontlognull
    timeout connect 5s
    timeout client  1m
    timeout server  1m

frontend k8s-api
    bind *:6443
    default_backend k8s-cp

backend k8s-cp
    balance roundrobin
    option  tcp-check
    server cp1 ${CP1_IP}:6443 check
    server cp2 ${CP2_IP}:6443 check
    server cp3 ${CP3_IP}:6443 check
EOF

systemctl enable haproxy
systemctl restart haproxy

echo "HAProxy configured and running."
*/

--Step 4.1
root@kubnet-lb:~# chmod -R 775 setup-haproxy-local.sh

--Step 4.2
root@kubnet-lb:~# ll setup-haproxy-local.sh
/*
-rwxrwxr-x 1 root root 839 May 29 12:06 setup-haproxy-local.sh*
*/

--Step 4.3
root@kubnet-lb:~# bash ./setup-haproxy-local.sh
/*
CP IPs: 192.1.6.28, 192.1.6.29, 192.1.6.30
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following additional packages will be installed:
  liblua5.4-0
Suggested packages:
  vim-haproxy haproxy-doc
The following NEW packages will be installed:
  dnsutils haproxy liblua5.4-0
0 upgraded, 3 newly installed, 0 to remove and 6 not upgraded.
Need to get 2,240 kB of archives.
After this operation, 5,306 kB of additional disk space will be used.
Get:1 http://archive.ubuntu.com/ubuntu noble/main amd64 liblua5.4-0 amd64 5.4.6-3build2 [166 kB]
Get:2 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 haproxy amd64 2.8.16-0ubuntu0.24.04.2 [2,070 kB]
Get:3 http://archive.ubuntu.com/ubuntu noble-updates/universe amd64 dnsutils all 1:9.18.39-0ubuntu0.24.04.5 [3,686 B]
Fetched 2,240 kB in 0s (4,817 kB/s)
Selecting previously unselected package liblua5.4-0:amd64.
(Reading database ... 126438 files and directories currently installed.)
Preparing to unpack .../liblua5.4-0_5.4.6-3build2_amd64.deb ...
Unpacking liblua5.4-0:amd64 (5.4.6-3build2) ...
Selecting previously unselected package haproxy.
Preparing to unpack .../haproxy_2.8.16-0ubuntu0.24.04.2_amd64.deb ...
Unpacking haproxy (2.8.16-0ubuntu0.24.04.2) ...
Selecting previously unselected package dnsutils.
Preparing to unpack .../dnsutils_1%3a9.18.39-0ubuntu0.24.04.5_all.deb ...
Unpacking dnsutils (1:9.18.39-0ubuntu0.24.04.5) ...
Setting up dnsutils (1:9.18.39-0ubuntu0.24.04.5) ...
Setting up liblua5.4-0:amd64 (5.4.6-3build2) ...
Setting up haproxy (2.8.16-0ubuntu0.24.04.2) ...
Created symlink /etc/systemd/system/multi-user.target.wants/haproxy.service → /usr/lib/systemd/system/haproxy.service.
Processing triggers for libc-bin (2.39-0ubuntu8.7) ...
Processing triggers for rsyslog (8.2312.0-3ubuntu9.2) ...
Processing triggers for man-db (2.12.0-4build2) ...
Scanning processes...
Scanning candidates...
Scanning linux images...

Pending kernel upgrade!
Running kernel version:
  6.8.0-111-generic
Diagnostics:
  The currently running kernel version is not the expected kernel version 6.8.0-117-generic.

Restarting the system to load the new kernel will not be handled automatically, so you should consider rebooting.

Restarting services...

Service restarts being deferred:
 /etc/needrestart/restart.d/dbus.service
 systemctl restart systemd-logind.service
 systemctl restart unattended-upgrades.service

No containers need to be restarted.

No user sessions are running outdated binaries.

No VM guests are running outdated hypervisor (qemu) binaries on this host.
Synchronizing state of haproxy.service with SysV service script with /usr/lib/systemd/systemd-sysv-install.
Executing: /usr/lib/systemd/systemd-sysv-install enable haproxy
HAProxy configured and running.
*/

--Step 5
root@kubnet-lb:~# root@kubnet-lb:~# ssh lab@kubnet-cp-1.unidev.org.np
/*
###########################################################################
                                 WARNING!!!!

                           Welcome to the UNIDEV system.

                             Authorized Access Only.
Any unauthorized use may be monitored, recorded, and subject to legal action.
By accessing you consent to such monitoring if unauthorized use is suspected.
Violators may face criminal, civil, and/or administrative action.

                        This system is the property of UNIDEV.
############################################################################
lab@kubnet-cp-1.unidev.org.np's password:
Last login: Fri May 29 12:08:26 2026 from 192.1.6.28
*/

root@kubnet-cp-1:~# sudo su -
/*
[sudo] password for lab:
*/

--Step 5.1
root@kubnet-cp-1:~# df -Th
/*
Filesystem                        Type   Size  Used Avail Use% Mounted on
tmpfs                             tmpfs  488M  1.5M  486M   1% /run
/dev/mapper/ubuntu--vg-ubuntu--lv ext4    24G  7.1G   16G  32% /
tmpfs                             tmpfs  2.4G     0  2.4G   0% /dev/shm
tmpfs                             tmpfs  5.0M     0  5.0M   0% /run/lock
/dev/sda2                         ext4   2.0G  200M  1.6G  11% /boot
tmpfs                             tmpfs  487M   12K  487M   1% /run/user/1000
*/

--Step 5.2
root@kubnet-cp-1:~# hostnamectl
/*
 Static hostname: kubnet-cp-1.unidev.org.np
       Icon name: computer-vm
         Chassis: vm 🖴
      Machine ID: 50708e19b677484c92840925bff7e721
         Boot ID: 5b8327419d8345fa9f8e051be0974777
  Virtualization: vmware
Operating System: Ubuntu 24.04.4 LTS
          Kernel: Linux 6.8.0-111-generic
    Architecture: x86-64
 Hardware Vendor: VMware, Inc.
  Hardware Model: VMware Virtual Platform
Firmware Version: 6.00
   Firmware Date: Wed 2018-12-12
    Firmware Age: 7y 5month 2w 2d
*/

--Step 6
root@kubnet-cp-1:~# vi /etc/netplan/50-cloud-init.yaml
/*
# This file is generated from information provided by the datasource.  Changes
# to it will not persist across an instance reboot.  To disable cloud-init's
# network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
    ethernets:
        ens192:
            addresses:
            - 192.1.6.29/24
            nameservers:
                addresses:
                - 192.1.4.11
                - 192.1.4.12
                search: []
            routes:
            -   to: default
                via: 192.1.6.1
    version: 2
*/

--Step 6.1
root@kubnet-cp-1:~# systemctl restart network-online.target

--Step 6.2
root@kubnet-cp-1:~# systemctl status network-online.target
/*
● network-online.target - Network is Online
     Loaded: loaded (/usr/lib/systemd/system/network-online.target; static)
     Active: active since Tue 2026-05-19 16:19:05 +0545; 1 week 2 days ago
       Docs: man:systemd.special(7)
             https://systemd.io/NETWORK_ONLINE

May 19 16:19:05 kubnet-cp-1.unidev.org.np systemd[1]: Reached target network-online.target - Network is Online.
*/

--Step 7
root@kubnet-cp-1:~# vi /etc/hosts
/*
#Kubnet-LB
192.1.6.28 kubnet-lb.unidev.org.np kubnet-lb

#Kubnet-CP-1
192.1.6.29 kubnet-cp-1.unidev.org.np kubnet-cp-1

#Kubnet-CP-2
192.1.6.30 kubnet-cp-2.unidev.org.np kubnet-cp-2

#Kubnet-CP-3
192.1.6.31 kubnet-cp-3.unidev.org.np kubnet-cp-3

#Kubnet-Worker-1
192.1.6.32 kubnet-worker-1.unidev.org.np kubnet-worker-1
*/

--Step 7.1
root@kubnet-cp-1:~# nslookup kubnet-cp-1.unidev.org.np
/*
Server:         127.0.0.53
Address:        127.0.0.53#53

Name:   kubnet-cp-1.unidev.org.np
Address: 192.1.6.29
*/

--Step 8
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
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

systemctl enable --now kubelet

echo "==> Node ready for Kubernetes ${K8S_VERSION}"
echo "    Next: run 'kubeadm init' on the first control-plane node"
echo "          or 'kubeadm join' on worker/additional CP nodes"
*/

--Step 8.1
root@kubnet-cp-1:~# chmod -R 775 prepare-node.sh

--Step 8.2
root@kubnet-cp-1:~# ll prepare-node.sh
/*
-rwxrwxr-x 1 root root 3188 May 29 12:12 prepare-node.sh*
*/

--Step 8.3
root@kubnet-cp-1:~# bash ./prepare-node.sh
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
ca-certificates set to manually installed.
curl is already the newest version (8.5.0-2ubuntu10.9).
curl set to manually installed.
gnupg is already the newest version (2.4.4-2ubuntu17.4).
gnupg set to manually installed.
0 upgraded, 0 newly installed, 0 to remove and 6 not upgraded.
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following NEW packages will be installed:
  containerd.io
0 upgraded, 1 newly installed, 0 to remove and 6 not upgraded.
Need to get 23.6 MB of archives.
After this operation, 93.5 MB of additional disk space will be used.
Get:1 https://download.docker.com/linux/ubuntu noble/stable amd64 containerd.io amd64 2.2.4-1~ubuntu.24.04~noble [23.6 MB]
Fetched 23.6 MB in 1s (16.9 MB/s)
Selecting previously unselected package containerd.io.
(Reading database ... 126437 files and directories currently installed.)
Preparing to unpack .../containerd.io_2.2.4-1~ubuntu.24.04~noble_amd64.deb ...
Unpacking containerd.io (2.2.4-1~ubuntu.24.04~noble) ...
Setting up containerd.io (2.2.4-1~ubuntu.24.04~noble) ...
Created symlink /etc/systemd/system/multi-user.target.wants/containerd.service → /usr/lib/systemd/system/containerd.service.
Processing triggers for man-db (2.12.0-4build2) ...
Scanning processes...
Scanning candidates...
Scanning linux images...

Pending kernel upgrade!
Running kernel version:
  6.8.0-111-generic
Diagnostics:
  The currently running kernel version is not the expected kernel version 6.8.0-117-generic.

Restarting the system to load the new kernel will not be handled automatically, so you should consider rebooting.

Restarting services...

Service restarts being deferred:
 /etc/needrestart/restart.d/dbus.service
 systemctl restart systemd-logind.service
 systemctl restart unattended-upgrades.service

No containers need to be restarted.

No user sessions are running outdated binaries.

No VM guests are running outdated hypervisor (qemu) binaries on this host.
==> Configuring containerd (SystemdCgroup=true)
==> Installing kubeadm, kubelet, kubectl (v1.36)
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following additional packages will be installed:
  kubernetes-cni
The following NEW packages will be installed:
  kubeadm kubectl kubelet kubernetes-cni
0 upgraded, 4 newly installed, 0 to remove and 6 not upgraded.
Need to get 76.7 MB of archives.
After this operation, 291 MB of additional disk space will be used.
Get:1 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.36/deb  kubeadm 1.36.1-1.1 [12.6 MB]
Get:2 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.36/deb  kubectl 1.36.1-1.1 [11.8 MB]
Get:3 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.36/deb  kubernetes-cni 1.9.1-1.1 [39.0 MB]
Get:4 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.36/deb  kubelet 1.36.1-1.1 [13.4 MB]
Fetched 76.7 MB in 4s (20.0 MB/s)
Selecting previously unselected package kubeadm.
(Reading database ... 126451 files and directories currently installed.)
Preparing to unpack .../kubeadm_1.36.1-1.1_amd64.deb ...
Unpacking kubeadm (1.36.1-1.1) ...
Selecting previously unselected package kubectl.
Preparing to unpack .../kubectl_1.36.1-1.1_amd64.deb ...
Unpacking kubectl (1.36.1-1.1) ...
Selecting previously unselected package kubernetes-cni.
Preparing to unpack .../kubernetes-cni_1.9.1-1.1_amd64.deb ...
Unpacking kubernetes-cni (1.9.1-1.1) ...
Selecting previously unselected package kubelet.
Preparing to unpack .../kubelet_1.36.1-1.1_amd64.deb ...
Unpacking kubelet (1.36.1-1.1) ...
Setting up kubeadm (1.36.1-1.1) ...
Setting up kubectl (1.36.1-1.1) ...
Setting up kubernetes-cni (1.9.1-1.1) ...
Setting up kubelet (1.36.1-1.1) ...
Scanning processes...
Scanning candidates...
Scanning linux images...

Pending kernel upgrade!
Running kernel version:
  6.8.0-111-generic
Diagnostics:
  The currently running kernel version is not the expected kernel version 6.8.0-117-generic.

Restarting the system to load the new kernel will not be handled automatically, so you should consider rebooting.

Restarting services...

Service restarts being deferred:
 /etc/needrestart/restart.d/dbus.service
 systemctl restart systemd-logind.service
 systemctl restart unattended-upgrades.service

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

--Step 8.4
root@kubnet-cp-1:~# systemctl restart containerd.service

--Step 8.5
root@kubnet-cp-1:~# systemctl status containerd.service
/*
● containerd.service - containerd container runtime
     Loaded: loaded (/usr/lib/systemd/system/containerd.service; enabled; preset: enabled)
     Active: active (running) since Fri 2026-05-29 12:14:20 +0545; 5s ago
       Docs: https://containerd.io
    Process: 35657 ExecStartPre=/sbin/modprobe overlay (code=exited, status=0/SUCCESS)
   Main PID: 35658 (containerd)
      Tasks: 8
     Memory: 14.1M (peak: 18.0M)
        CPU: 274ms
     CGroup: /system.slice/containerd.service
             └─35658 /usr/bin/containerd

May 29 12:14:20 kubnet-cp-1.unidev.org.np containerd[35658]: time="2026-05-29T12:14:20.440621264+05:45" level=info msg="Start cni network conf syncer for default"
May 29 12:14:20 kubnet-cp-1.unidev.org.np containerd[35658]: time="2026-05-29T12:14:20.440681297+05:45" level=info msg="Start streaming server"
May 29 12:14:20 kubnet-cp-1.unidev.org.np containerd[35658]: time="2026-05-29T12:14:20.440751246+05:45" level=info msg="Registered namespace \"k8s.io\" with NRI"
May 29 12:14:20 kubnet-cp-1.unidev.org.np containerd[35658]: time="2026-05-29T12:14:20.440810913+05:45" level=info msg="runtime interface starting up..."
May 29 12:14:20 kubnet-cp-1.unidev.org.np containerd[35658]: time="2026-05-29T12:14:20.440865543+05:45" level=info msg="starting plugins..."
May 29 12:14:20 kubnet-cp-1.unidev.org.np containerd[35658]: time="2026-05-29T12:14:20.441067942+05:45" level=info msg="Synchronizing NRI (plugin) with current runtime state"
May 29 12:14:20 kubnet-cp-1.unidev.org.np containerd[35658]: time="2026-05-29T12:14:20.441860072+05:45" level=info msg=serving... address=/run/containerd/containerd.sock.ttrpc
May 29 12:14:20 kubnet-cp-1.unidev.org.np containerd[35658]: time="2026-05-29T12:14:20.442130326+05:45" level=info msg=serving... address=/run/containerd/containerd.sock
May 29 12:14:20 kubnet-cp-1.unidev.org.np systemd[1]: Started containerd.service - containerd container runtime.
May 29 12:14:20 kubnet-cp-1.unidev.org.np containerd[35658]: time="2026-05-29T12:14:20.446283958+05:45" level=info msg="containerd successfully booted in 0.117121s"
*/

--Step 8.6
root@kubnet-cp-1:~# which kubelet
/*
/usr/bin/kubelet
*/

--Step 8.7
root@kubnet-cp-1:~# which kubeadm
/*
/usr/bin/kubeadm
*/

--Step 8.8
root@kubnet-cp-1:~# which kubectl
/*
/usr/bin/kubectl
*/

--Step 9
root@kubnet-cp-1:~# kubeadm init --control-plane-endpoint kubnet-lb.unidev.org.np:6443 --upload-certs --dry-run
/*
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/tmp/kubeadm-init-dryrun2005996500/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

You can now join any number of control-plane nodes running the following command on each as root:

  kubeadm join kubnet-lb.unidev.org.np:6443 --token 30qc41.em5sar08dd7zcjy7 \
        --discovery-token-ca-cert-hash sha256:d19fcd656e669391be31a43cdc8fc0eaae45043092a7559fae2c379ff5889ba3 \
        --control-plane --certificate-key be369c1c4ab3982c525ffb1cd76fb7cbac4e5868e74a1e73c8f9521793429540

Please note that the certificate-key gives access to cluster sensitive data, keep it secret!
As a safeguard, uploaded-certs will be deleted in two hours; If necessary, you can use
"kubeadm init phase upload-certs --upload-certs" to reload certs afterward.

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join kubnet-lb.unidev.org.np:6443 --token 30qc41.em5sar08dd7zcjy7 \
        --discovery-token-ca-cert-hash sha256:d19fcd656e669391be31a43cdc8fc0eaae45043092a7559fae2c379ff5889ba3
*/

--Step 9.1
root@kubnet-cp-1:~# kubeadm init --control-plane-endpoint kubnet-lb.unidev.org.np:6443 --upload-certs
/*
[init] Using Kubernetes version: v1.36.1
[preflight] Running pre-flight checks
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action beforehand using 'kubeadm config images pull'
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local kubnet-cp-1.unidev.org.np kubnet-lb.unidev.org.np] and IPs [10.96.0.1 192.1.6.29]
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "front-proxy-ca" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/ca" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [kubnet-cp-1.unidev.org.np localhost] and IPs [192.1.6.29 127.0.0.1 ::1]
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [kubnet-cp-1.unidev.org.np localhost] and IPs [192.1.6.29 127.0.0.1 ::1]
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Generating "apiserver-etcd-client" certificate and key
[certs] Generating "sa" key and public key
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
[kubeconfig] Writing "admin.conf" kubeconfig file
[kubeconfig] Writing "super-admin.conf" kubeconfig file
[kubeconfig] Writing "kubelet.conf" kubeconfig file
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
[kubeconfig] Writing "scheduler.conf" kubeconfig file
[etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
[control-plane] Creating static Pod manifest for "kube-scheduler"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/instance-config.yaml"
[patches] Applied patch of type "application/strategic-merge-patch+json" to target "kubeletconfiguration"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Starting the kubelet
[wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests"
[kubelet-check] Waiting for a healthy kubelet at http://127.0.0.1:10248/healthz. This can take up to 4m0s
[kubelet-check] The kubelet is healthy after 3.267988ms
[control-plane-check] Waiting for healthy control plane components. This can take up to 4m0s
[control-plane-check] Checking kube-apiserver at https://192.1.6.29:6443/livez
[control-plane-check] Checking kube-controller-manager at https://127.0.0.1:10257/healthz
[control-plane-check] Checking kube-scheduler at https://127.0.0.1:10259/livez
[control-plane-check] kube-controller-manager is healthy after 25.974945ms
[control-plane-check] kube-scheduler is healthy after 51.562185ms
[control-plane-check] kube-apiserver is healthy after 2.504178328s
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config" in namespace kube-system with the configuration for the kubelets in the cluster
[upload-certs] Storing the certificates in Secret "kubeadm-certs" in the "kube-system" Namespace
[upload-certs] Using certificate key:
1d5eb84966950543a3aabb28fb811e0f9178b48044bc4fedd301b2bb09cb8fa7
[mark-control-plane] Marking the node kubnet-cp-1.unidev.org.np as control-plane by adding the labels: [node-role.kubernetes.io/control-plane node.kubernetes.io/exclude-from-external-load-balancers]
[mark-control-plane] Marking the node kubnet-cp-1.unidev.org.np as control-plane by adding the taints [node-role.kubernetes.io/control-plane:NoSchedule]
[bootstrap-token] Using token: 3onebk.aoa1qp57iqf2ewzb
[bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to get nodes
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] Configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] Configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstrap-token] Configured RBAC rules to allow the API server kubelet client certificate to access the kubelet API
[bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
[kubelet-finalize] Updating "/etc/kubernetes/kubelet.conf" to point to a rotatable kubelet client certificate and key
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

You can now join any number of control-plane nodes running the following command on each as root:

  kubeadm join kubnet-lb.unidev.org.np:6443 --token 3onebk.aoa1qp57iqf2ewzb \
        --discovery-token-ca-cert-hash sha256:b2b102ceb40e00c1c8ee67e83c6f30686b2d58ff35d62017b7d5a845e92f0a92 \
        --control-plane --certificate-key 1d5eb84966950543a3aabb28fb811e0f9178b48044bc4fedd301b2bb09cb8fa7

Please note that the certificate-key gives access to cluster sensitive data, keep it secret!
As a safeguard, uploaded-certs will be deleted in two hours; If necessary, you can use
"kubeadm init phase upload-certs --upload-certs" to reload certs afterward.

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join kubnet-lb.unidev.org.np:6443 --token 3onebk.aoa1qp57iqf2ewzb \
        --discovery-token-ca-cert-hash sha256:b2b102ceb40e00c1c8ee67e83c6f30686b2d58ff35d62017b7d5a845e92f0a92
*/

--Step 9.2
root@kubnet-cp-1:~# mkdir -p $HOME/.kube

--Step 9.3
root@kubnet-cp-1:~# sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

--Step 9.4
root@kubnet-cp-1:~# sudo chown $(id -u):$(id -g) $HOME/.kube/config

--Step 10
root@kubnet-cp-1:~# kubectl get nodes
/*
NAME                          STATUS     ROLES           AGE   VERSION
kubnet-cp-1.unidev.org.np   NotReady   control-plane   73s   v1.36.1
*/

--Step 10.1
root@kubnet-cp-1:~# kubectl get nodes -o wide
/*
NAME                          STATUS     ROLES           AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION              CONTAINER-RUNTIME
kubnet-cp-1.unidev.org.np   NotReady   control-plane   81s   v1.36.1   192.1.6.29   <none>        Ubuntu 24.04.4 LTS   6.8.0-111-generic (amd64)   containerd://2.2.4
*/

--Step 10.2
root@kubnet-cp-1:~# exit
/*
logout
*/
lab@kubnet-cp-1:~$ exit
/*
logout
Connection to kubnet-cp-1.unidev.org.np closed.
*/

--Step 11
root@kubnet-lb:~# ssh lab@kubnet-cp-2.unidev.org.np
/*
###########################################################################
                                 WARNING!!!!

                           Welcome to the UNIDEV system.

                             Authorized Access Only.
Any unauthorized use may be monitored, recorded, and subject to legal action.
By accessing you consent to such monitoring if unauthorized use is suspected.
Violators may face criminal, civil, and/or administrative action.

                        This system is the property of UNIDEV.
############################################################################
lab@kubnet-cp-2.unidev.org.np's password:
Last login: Fri May 29 12:21:37 2026 from 192.1.6.28
*/

lab@kubnet-cp-2:~$  sudo su -
/*
[sudo] password for lab:
*/

--Step 11.1
root@kubnet-cp-2:~# df -Th
/*
Filesystem                        Type   Size  Used Avail Use% Mounted on
tmpfs                             tmpfs  487M  1.5M  486M   1% /run
/dev/mapper/ubuntu--vg-ubuntu--lv ext4    24G  7.1G   16G  32% /
tmpfs                             tmpfs  2.4G     0  2.4G   0% /dev/shm
tmpfs                             tmpfs  5.0M     0  5.0M   0% /run/lock
/dev/sda2                         ext4   2.0G  200M  1.6G  11% /boot
tmpfs                             tmpfs  487M   12K  487M   1% /run/user/1000
*/

--Step 11.2
root@kubnet-cp-2:~# hostnamectl
/*
 Static hostname: kubnet-cp-2.unidev.org.np
       Icon name: computer-vm
         Chassis: vm 🖴
      Machine ID: 50708e19b677484c92840925bff7e721
         Boot ID: 6b26e050ebe745329d1fe28027e0b5ce
  Virtualization: vmware
Operating System: Ubuntu 24.04.4 LTS
          Kernel: Linux 6.8.0-111-generic
    Architecture: x86-64
 Hardware Vendor: VMware, Inc.
  Hardware Model: VMware Virtual Platform
Firmware Version: 6.00
   Firmware Date: Wed 2018-12-12
    Firmware Age: 7y 5month 2w 2d
*/

--Step 12
root@kubnet-cp-2:~# vi /etc/netplan/50-cloud-init.yaml
/*
# This file is generated from information provided by the datasource.  Changes
# to it will not persist across an instance reboot.  To disable cloud-init's
# network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
    ethernets:
        ens192:
            addresses:
            - 192.1.6.30/24
            nameservers:
                addresses:
                - 192.1.4.11
                - 192.1.4.12
                search: []
            routes:
            -   to: default
                via: 192.1.6.1
    version: 2
*/

--Step 12.1
root@kubnet-cp-2:~# systemctl restart network-online.target

--Step 12.2
root@kubnet-cp-2:~# systemctl status network-online.target
/*
● network-online.target - Network is Online
     Loaded: loaded (/usr/lib/systemd/system/network-online.target; static)
     Active: active since Tue 2026-05-19 16:22:23 +0545; 1 week 2 days ago
       Docs: man:systemd.special(7)
             https://systemd.io/NETWORK_ONLINE

May 19 16:22:23 kubnet-cp-2.unidev.org.np systemd[1]: Reached target network-online.target - Network is Online.
*/

--Step 13
root@kubnet-cp-2:~# vi /etc/hosts
/*
#Kubnet-LB
192.1.6.28 kubnet-lb.unidev.org.np kubnet-lb

#Kubnet-CP-1
192.1.6.29 kubnet-cp-1.unidev.org.np kubnet-cp-1

#Kubnet-CP-2
192.1.6.30 kubnet-cp-2.unidev.org.np kubnet-cp-2

#Kubnet-CP-3
192.1.6.31 kubnet-cp-3.unidev.org.np kubnet-cp-3

#Kubnet-Worker-1
192.1.6.32 kubnet-worker-1.unidev.org.np kubnet-worker-1
*/

--Step 13.1
root@kubnet-cp-2:~# nslookup kubnet-cp-2.unidev.org.np
/*
Server:         127.0.0.53
Address:        127.0.0.53#53

Name:   kubnet-cp-2.unidev.org.np
Address: 192.1.6.30
*/

--Step 14
root@kubnet-cp-2:~# vi prepare-node.sh
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
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

systemctl enable --now kubelet

echo "==> Node ready for Kubernetes ${K8S_VERSION}"
echo "    Next: run 'kubeadm init' on the first control-plane node"
echo "          or 'kubeadm join' on worker/additional CP nodes"
*/

--Step 14.1
root@kubnet-cp-2:~# chmod -R 775 prepare-node.sh

--Step 14.2
root@kubnet-cp-2:~# ll prepare-node.sh
/*
-rwxrwxr-x 1 root root 3188 May 29 12:23 prepare-node.sh*
*/

--Step 14.3
root@kubnet-cp-2:~# bash ./prepare-node.sh
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
ca-certificates set to manually installed.
curl is already the newest version (8.5.0-2ubuntu10.9).
curl set to manually installed.
gnupg is already the newest version (2.4.4-2ubuntu17.4).
gnupg set to manually installed.
0 upgraded, 0 newly installed, 0 to remove and 6 not upgraded.
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following NEW packages will be installed:
  containerd.io
0 upgraded, 1 newly installed, 0 to remove and 6 not upgraded.
Need to get 23.6 MB of archives.
After this operation, 93.5 MB of additional disk space will be used.
Get:1 https://download.docker.com/linux/ubuntu noble/stable amd64 containerd.io amd64 2.2.4-1~ubuntu.24.04~noble [23.6 MB]
Fetched 23.6 MB in 1s (18.3 MB/s)
Selecting previously unselected package containerd.io.
(Reading database ... 126437 files and directories currently installed.)
Preparing to unpack .../containerd.io_2.2.4-1~ubuntu.24.04~noble_amd64.deb ...
Unpacking containerd.io (2.2.4-1~ubuntu.24.04~noble) ...
Setting up containerd.io (2.2.4-1~ubuntu.24.04~noble) ...
Created symlink /etc/systemd/system/multi-user.target.wants/containerd.service → /usr/lib/systemd/system/containerd.service.
Processing triggers for man-db (2.12.0-4build2) ...
Scanning processes...
Scanning candidates...
Scanning linux images...

Pending kernel upgrade!
Running kernel version:
  6.8.0-111-generic
Diagnostics:
  The currently running kernel version is not the expected kernel version 6.8.0-117-generic.

Restarting the system to load the new kernel will not be handled automatically, so you should consider rebooting.

Restarting services...

Service restarts being deferred:
 /etc/needrestart/restart.d/dbus.service
 systemctl restart systemd-logind.service
 systemctl restart unattended-upgrades.service

No containers need to be restarted.

No user sessions are running outdated binaries.

No VM guests are running outdated hypervisor (qemu) binaries on this host.
==> Configuring containerd (SystemdCgroup=true)
==> Installing kubeadm, kubelet, kubectl (v1.36)
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following additional packages will be installed:
  kubernetes-cni
The following NEW packages will be installed:
  kubeadm kubectl kubelet kubernetes-cni
0 upgraded, 4 newly installed, 0 to remove and 6 not upgraded.
Need to get 76.7 MB of archives.
After this operation, 291 MB of additional disk space will be used.
Get:1 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.36/deb  kubeadm 1.36.1-1.1 [12.6 MB]
Get:2 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.36/deb  kubectl 1.36.1-1.1 [11.8 MB]
Get:3 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.36/deb  kubernetes-cni 1.9.1-1.1 [39.0 MB]
Get:4 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.36/deb  kubelet 1.36.1-1.1 [13.4 MB]
Fetched 76.7 MB in 3s (23.7 MB/s)
Selecting previously unselected package kubeadm.
(Reading database ... 126451 files and directories currently installed.)
Preparing to unpack .../kubeadm_1.36.1-1.1_amd64.deb ...
Unpacking kubeadm (1.36.1-1.1) ...
Selecting previously unselected package kubectl.
Preparing to unpack .../kubectl_1.36.1-1.1_amd64.deb ...
Unpacking kubectl (1.36.1-1.1) ...
Selecting previously unselected package kubernetes-cni.
Preparing to unpack .../kubernetes-cni_1.9.1-1.1_amd64.deb ...
Unpacking kubernetes-cni (1.9.1-1.1) ...
Selecting previously unselected package kubelet.
Preparing to unpack .../kubelet_1.36.1-1.1_amd64.deb ...
Unpacking kubelet (1.36.1-1.1) ...
Setting up kubeadm (1.36.1-1.1) ...
Setting up kubectl (1.36.1-1.1) ...
Setting up kubernetes-cni (1.9.1-1.1) ...
Setting up kubelet (1.36.1-1.1) ...
Scanning processes...
Scanning candidates...
Scanning linux images...

Pending kernel upgrade!
Running kernel version:
  6.8.0-111-generic
Diagnostics:
  The currently running kernel version is not the expected kernel version 6.8.0-117-generic.

Restarting the system to load the new kernel will not be handled automatically, so you should consider rebooting.

Restarting services...

Service restarts being deferred:
 /etc/needrestart/restart.d/dbus.service
 systemctl restart systemd-logind.service
 systemctl restart unattended-upgrades.service

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

--Step 14.4
root@kubnet-cp-2:~# systemctl restart containerd.service

--Step 14.5
root@kubnet-cp-2:~# systemctl status containerd.service
/*
● containerd.service - containerd container runtime
     Loaded: loaded (/usr/lib/systemd/system/containerd.service; enabled; preset: enabled)
     Active: active (running) since Fri 2026-05-29 12:25:58 +0545; 5s ago
       Docs: https://containerd.io
    Process: 36071 ExecStartPre=/sbin/modprobe overlay (code=exited, status=0/SUCCESS)
   Main PID: 36073 (containerd)
      Tasks: 8
     Memory: 14.3M (peak: 17.9M)
        CPU: 262ms
     CGroup: /system.slice/containerd.service
             └─36073 /usr/bin/containerd

May 29 12:25:58 kubnet-cp-2.unidev.org.np containerd[36073]: time="2026-05-29T12:25:58.395111457+05:45" level=info msg=serving... address=/run/containerd/containerd.sock.ttrpc
May 29 12:25:58 kubnet-cp-2.unidev.org.np containerd[36073]: time="2026-05-29T12:25:58.395151568+05:45" level=info msg="Start cni network conf syncer for default"
May 29 12:25:58 kubnet-cp-2.unidev.org.np containerd[36073]: time="2026-05-29T12:25:58.395367426+05:45" level=info msg="Start streaming server"
May 29 12:25:58 kubnet-cp-2.unidev.org.np containerd[36073]: time="2026-05-29T12:25:58.395342714+05:45" level=info msg=serving... address=/run/containerd/containerd.sock
May 29 12:25:58 kubnet-cp-2.unidev.org.np containerd[36073]: time="2026-05-29T12:25:58.395496218+05:45" level=info msg="Registered namespace \"k8s.io\" with NRI"
May 29 12:25:58 kubnet-cp-2.unidev.org.np containerd[36073]: time="2026-05-29T12:25:58.395725102+05:45" level=info msg="runtime interface starting up..."
May 29 12:25:58 kubnet-cp-2.unidev.org.np containerd[36073]: time="2026-05-29T12:25:58.395781719+05:45" level=info msg="starting plugins..."
May 29 12:25:58 kubnet-cp-2.unidev.org.np containerd[36073]: time="2026-05-29T12:25:58.395860214+05:45" level=info msg="Synchronizing NRI (plugin) with current runtime state"
May 29 12:25:58 kubnet-cp-2.unidev.org.np containerd[36073]: time="2026-05-29T12:25:58.396230959+05:45" level=info msg="containerd successfully booted in 0.104730s"
May 29 12:25:58 kubnet-cp-2.unidev.org.np systemd[1]: Started containerd.service - containerd container runtime.
*/

--Step 14.6
root@kubnet-cp-2:~# which kubelet
/*
/usr/bin/kubelet
*/

--Step 14.7
root@kubnet-cp-2:~# which kubeadm
/*
/usr/bin/kubeadm
*/

--Step 14.8
root@kubnet-cp-2:~# which kubectl
/*
/usr/bin/kubectl
*/

--Step 15
root@kubnet-cp-2:~# kubeadm join kubnet-lb.unidev.org.np:6443 --token 3onebk.aoa1qp57iqf2ewzb \
        --discovery-token-ca-cert-hash sha256:b2b102ceb40e00c1c8ee67e83c6f30686b2d58ff35d62017b7d5a845e92f0a92 \
        --control-plane --certificate-key 1d5eb84966950543a3aabb28fb811e0f9178b48044bc4fedd301b2bb09cb8fa7 --dry-run
/*
[etcd] Would wait for the new etcd member to join the cluster
[kubelet-wait] Would wait for the kubelet to be bootstrapped
[control-plane-join] Would mark node kubnet-cp-2.unidev.org.np as a control-plane

This node has joined the cluster and a new control plane instance was created:

* Certificate signing request was sent to apiserver and approval was received.
* The Kubelet was informed of the new secure connection details.
* Control plane label and taint were applied to the new node.
* The Kubernetes control plane instances scaled up.
* A new etcd member was added to the local/stacked etcd cluster.

To start administering your cluster from this node, you need to run the following as a regular user:

        mkdir -p $HOME/.kube
        sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
        sudo chown $(id -u):$(id -g) $HOME/.kube/config

Run 'kubectl get nodes' to see this node join the cluster.
*/

--Step 15.1
root@kubnet-cp-2:~# kubeadm join kubnet-lb.unidev.org.np:6443 --token 3onebk.aoa1qp57iqf2ewzb \
        --discovery-token-ca-cert-hash sha256:b2b102ceb40e00c1c8ee67e83c6f30686b2d58ff35d62017b7d5a845e92f0a92 \
        --control-plane --certificate-key 1d5eb84966950543a3aabb28fb811e0f9178b48044bc4fedd301b2bb09cb8fa7
/*
[preflight] Running pre-flight checks
[preflight] Reading configuration from the "kubeadm-config" ConfigMap in namespace "kube-system"...
[preflight] Use 'kubeadm init phase upload-config kubeadm --config your-config-file' to re-upload it.
W0529 12:27:39.641859   36193 utils.go:69] The recommended value for "bindAddress" in "KubeProxyConfiguration" is: ::; the provided value is: 0.0.0.0
[preflight] Running pre-flight checks before initializing the new control plane instance
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action beforehand using 'kubeadm config images pull'
[download-certs] Downloading the certificates in Secret "kubeadm-certs" in the "kube-system" Namespace
[download-certs] Saving the certificates to the folder: "/etc/kubernetes/pki"
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local kubnet-cp-2.unidev.org.np kubnet-lb.unidev.org.np] and IPs [10.96.0.1 192.1.6.30]
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [kubnet-cp-2.unidev.org.np localhost] and IPs [192.1.6.30 127.0.0.1 ::1]
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [kubnet-cp-2.unidev.org.np localhost] and IPs [192.1.6.30 127.0.0.1 ::1]
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Generating "apiserver-etcd-client" certificate and key
[certs] Valid certificates and keys now exist in "/etc/kubernetes/pki"
[certs] Using the existing "sa" key
[kubeconfig] Generating kubeconfig files
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
[kubeconfig] Writing "admin.conf" kubeconfig file
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
[kubeconfig] Writing "scheduler.conf" kubeconfig file
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
[control-plane] Creating static Pod manifest for "kube-scheduler"
[check-etcd] Checking that the etcd cluster is healthy
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/instance-config.yaml"
[patches] Applied patch of type "application/strategic-merge-patch+json" to target "kubeletconfiguration"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Starting the kubelet
[etcd] Announced new etcd member joining to the existing etcd cluster
[etcd] Creating static Pod manifest for "etcd"
{"level":"warn","ts":"2026-05-29T12:29:12.536311+0545","logger":"etcd-client","caller":"v3@v3.6.8/retry_interceptor.go:65","msg":"retrying of unary invoker failed","target":"etcd-endpoints://0x377e126f83c0/192.1.6.29:2379","method":"/etcdserverpb.Cluster/MemberPromote","attempt":0,"error":"rpc error: code = FailedPrecondition desc = etcdserver: can only promote a learner member which is in sync with leader"}
[etcd] Waiting for the new etcd member to join the cluster. This can take up to 40s
[kubelet-check] Waiting for a healthy kubelet at http://127.0.0.1:10248/healthz. This can take up to 4m0s
[kubelet-check] The kubelet is healthy after 5.906674ms
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap
[mark-control-plane] Marking the node kubnet-cp-2.unidev.org.np as control-plane by adding the labels: [node-role.kubernetes.io/control-plane node.kubernetes.io/exclude-from-external-load-balancers]
[mark-control-plane] Marking the node kubnet-cp-2.unidev.org.np as control-plane by adding the taints [node-role.kubernetes.io/control-plane:NoSchedule]
[control-plane-check] Waiting for healthy control plane components. This can take up to 4m0s
[control-plane-check] Checking kube-apiserver at https://192.1.6.30:6443/livez
[control-plane-check] Checking kube-controller-manager at https://127.0.0.1:10257/healthz
[control-plane-check] Checking kube-scheduler at https://127.0.0.1:10259/livez
[control-plane-check] kube-controller-manager is healthy after 35.234787ms
[control-plane-check] kube-scheduler is healthy after 39.524536ms
[control-plane-check] kube-apiserver is healthy after 38.374677ms

This node has joined the cluster and a new control plane instance was created:

* Certificate signing request was sent to apiserver and approval was received.
* The Kubelet was informed of the new secure connection details.
* Control plane label and taint were applied to the new node.
* The Kubernetes control plane instances scaled up.
* A new etcd member was added to the local/stacked etcd cluster.

To start administering your cluster from this node, you need to run the following as a regular user:

        mkdir -p $HOME/.kube
        sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
        sudo chown $(id -u):$(id -g) $HOME/.kube/config

Run 'kubectl get nodes' to see this node join the cluster.
*/

--Step 15.2
root@kubnet-cp-2:~# mkdir -p $HOME/.kube

--Step 15.3
root@kubnet-cp-2:~# sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

--Step 15.4
root@kubnet-cp-2:~# sudo chown $(id -u):$(id -g) $HOME/.kube/config

--Step 16
root@kubnet-cp-2:~# kubectl get nodes
/*
NAME                          STATUS     ROLES           AGE   VERSION
kubnet-cp-1.unidev.org.np   NotReady   control-plane   47m   v1.36.1
kubnet-cp-2.unidev.org.np   NotReady   control-plane   49s   v1.36.1
*/

--Step 16.1
root@kubnet-cp-2:~# kubectl get nodes -o wide
/*
NAME                          STATUS     ROLES           AGE    VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION              CONTAINER-RUNTIME
kubnet-cp-1.unidev.org.np   NotReady   control-plane   12m    v1.36.1   192.1.6.29   <none>        Ubuntu 24.04.4 LTS   6.8.0-111-generic (amd64)   containerd://2.2.4
kubnet-cp-2.unidev.org.np   NotReady   control-plane   103s   v1.36.1   192.1.6.30   <none>        Ubuntu 24.04.4 LTS   6.8.0-111-generic (amd64)   containerd://2.2.4
*/

--Step 16.2
root@kubnet-cp-2:~# exit
/*
logout
*/

lab@kubnet-cp-2:~$ exit
/*
logout
Connection to kubnet-cp-2.unidev.org.np closed.
*/

--Step 17
root@kubnet-lb:~# ssh lab@kubnet-cp-3.unidev.org.np
/*
###########################################################################
                                 WARNING!!!!

                           Welcome to the UNIDEV system.

                             Authorized Access Only.
Any unauthorized use may be monitored, recorded, and subject to legal action.
By accessing you consent to such monitoring if unauthorized use is suspected.
Violators may face criminal, civil, and/or administrative action.

                        This system is the property of UNIDEV.
############################################################################
lab@kubnet-cp-3.unidev.org.np's password:
Last login: Fri May 29 12:32:08 2026 from 192.1.6.28
*/

lab@kubnet-cp-3:~$ sudo su -
/*
[sudo] password for lab:
*/

--Step 17.1
root@kubnet-cp-3:~# df -Th
/*
Filesystem                        Type   Size  Used Avail Use% Mounted on
tmpfs                             tmpfs  488M  1.5M  486M   1% /run
/dev/mapper/ubuntu--vg-ubuntu--lv ext4    24G  7.1G   16G  32% /
tmpfs                             tmpfs  2.4G     0  2.4G   0% /dev/shm
tmpfs                             tmpfs  5.0M     0  5.0M   0% /run/lock
/dev/sda2                         ext4   2.0G  200M  1.6G  11% /boot
tmpfs                             tmpfs  488M   12K  487M   1% /run/user/1000
*/

--Step 17.2
root@kubnet-cp-3:~# hostnamectl
/*
 Static hostname: kubnet-cp-3.unidev.org.np
       Icon name: computer-vm
         Chassis: vm 🖴
      Machine ID: 50708e19b677484c92840925bff7e721
         Boot ID: 6ad6d61c492449e09f1ad6ca8fa17024
  Virtualization: vmware
Operating System: Ubuntu 24.04.4 LTS
          Kernel: Linux 6.8.0-111-generic
    Architecture: x86-64
 Hardware Vendor: VMware, Inc.
  Hardware Model: VMware Virtual Platform
Firmware Version: 6.00
   Firmware Date: Wed 2018-12-12
    Firmware Age: 7y 5month 2w 2d
*/

--Step 18
root@kubnet-cp-3:~# vi /etc/netplan/50-cloud-init.yaml
/*
# This file is generated from information provided by the datasource.  Changes
# to it will not persist across an instance reboot.  To disable cloud-init's
# network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
    ethernets:
        ens192:
            addresses:
            - 192.1.6.31/24
            nameservers:
                addresses:
                - 192.1.4.11
                - 192.1.4.12
                search: []
            routes:
            -   to: default
                via: 192.1.6.1
    version: 2
*/

--Step 18.1
root@kubnet-cp-3:~# systemctl restart network-online.target

--Step 18.2
root@kubnet-cp-3:~# systemctl status network-online.target
/*
● network-online.target - Network is Online
     Loaded: loaded (/usr/lib/systemd/system/network-online.target; static)
     Active: active since Fri 2026-05-29 12:33:26 +0545; 34s ago
       Docs: man:systemd.special(7)
             https://systemd.io/NETWORK_ONLINE

May 29 12:33:26 kubnet-cp-3.unidev.org.np systemd[1]: Stopped target network-online.target - Network is Online.
May 29 12:33:26 kubnet-cp-3.unidev.org.np systemd[1]: Stopping network-online.target - Network is Online...
May 29 12:33:26 kubnet-cp-3.unidev.org.np systemd[1]: Reached target network-online.target - Network is Online.
*/

--Step 19
root@kubnet-cp-3:~# vi /etc/hosts
/*
#Kubnet-LB
192.1.6.28 kubnet-lb.unidev.org.np kubnet-lb

#Kubnet-CP-1
192.1.6.29 kubnet-cp-1.unidev.org.np kubnet-cp-1

#Kubnet-CP-2
192.1.6.30 kubnet-cp-2.unidev.org.np kubnet-cp-2

#Kubnet-CP-3
192.1.6.31 kubnet-cp-3.unidev.org.np kubnet-cp-3

#Kubnet-Worker-1
192.1.6.32 kubnet-worker-1.unidev.org.np kubnet-worker-1
*/

--Step 19.1
root@kubnet-cp-3:~# nslookup kubnet-cp-3.unidev.org.np
/*
Server:         127.0.0.53
Address:        127.0.0.53#53

Name:   kubnet-cp-3.unidev.org.np
Address: 192.1.6.31
*/

--Step 20
root@kubnet-cp-3:~# vi prepare-node.sh
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
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

systemctl enable --now kubelet

echo "==> Node ready for Kubernetes ${K8S_VERSION}"
echo "    Next: run 'kubeadm init' on the first control-plane node"
echo "          or 'kubeadm join' on worker/additional CP nodes"
*/

--Step 20.2
root@kubnet-cp-3:~# chmod -R 775 prepare-node.sh

--Step 20.3
root@kubnet-cp-3:~# ll prepare-node.sh
/*
-rwxrwxr-x 1 root root 3188 May 29 12:34 prepare-node.sh*
*/

--Step 20.4
root@kubnet-cp-3:~# bash ./prepare-node.sh
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
ca-certificates set to manually installed.
curl is already the newest version (8.5.0-2ubuntu10.9).
curl set to manually installed.
gnupg is already the newest version (2.4.4-2ubuntu17.4).
gnupg set to manually installed.
0 upgraded, 0 newly installed, 0 to remove and 6 not upgraded.
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following NEW packages will be installed:
  containerd.io
0 upgraded, 1 newly installed, 0 to remove and 6 not upgraded.
Need to get 23.6 MB of archives.
After this operation, 93.5 MB of additional disk space will be used.
Get:1 https://download.docker.com/linux/ubuntu noble/stable amd64 containerd.io amd64 2.2.4-1~ubuntu.24.04~noble [23.6 MB]
Fetched 23.6 MB in 2s (14.1 MB/s)
Selecting previously unselected package containerd.io.
(Reading database ... 126438 files and directories currently installed.)
Preparing to unpack .../containerd.io_2.2.4-1~ubuntu.24.04~noble_amd64.deb ...
Unpacking containerd.io (2.2.4-1~ubuntu.24.04~noble) ...
Setting up containerd.io (2.2.4-1~ubuntu.24.04~noble) ...
Created symlink /etc/systemd/system/multi-user.target.wants/containerd.service → /usr/lib/systemd/system/containerd.service.
Processing triggers for man-db (2.12.0-4build2) ...
Scanning processes...
Scanning candidates...
Scanning linux images...

Pending kernel upgrade!
Running kernel version:
  6.8.0-111-generic
Diagnostics:
  The currently running kernel version is not the expected kernel version 6.8.0-117-generic.

Restarting the system to load the new kernel will not be handled automatically, so you should consider rebooting.

Restarting services...

Service restarts being deferred:
 /etc/needrestart/restart.d/dbus.service
 systemctl restart systemd-logind.service
 systemctl restart unattended-upgrades.service

No containers need to be restarted.

No user sessions are running outdated binaries.

No VM guests are running outdated hypervisor (qemu) binaries on this host.
==> Configuring containerd (SystemdCgroup=true)
==> Installing kubeadm, kubelet, kubectl (v1.36)
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following additional packages will be installed:
  kubernetes-cni
The following NEW packages will be installed:
  kubeadm kubectl kubelet kubernetes-cni
0 upgraded, 4 newly installed, 0 to remove and 6 not upgraded.
Need to get 76.7 MB of archives.
After this operation, 291 MB of additional disk space will be used.
Get:1 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.36/deb  kubeadm 1.36.1-1.1 [12.6 MB]
Get:2 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.36/deb  kubectl 1.36.1-1.1 [11.8 MB]
Get:3 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.36/deb  kubernetes-cni 1.9.1-1.1 [39.0 MB]
Get:4 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.36/deb  kubelet 1.36.1-1.1 [13.4 MB]
Fetched 76.7 MB in 4s (21.8 MB/s)
Selecting previously unselected package kubeadm.
(Reading database ... 126452 files and directories currently installed.)
Preparing to unpack .../kubeadm_1.36.1-1.1_amd64.deb ...
Unpacking kubeadm (1.36.1-1.1) ...
Selecting previously unselected package kubectl.
Preparing to unpack .../kubectl_1.36.1-1.1_amd64.deb ...
Unpacking kubectl (1.36.1-1.1) ...
Selecting previously unselected package kubernetes-cni.
Preparing to unpack .../kubernetes-cni_1.9.1-1.1_amd64.deb ...
Unpacking kubernetes-cni (1.9.1-1.1) ...
Selecting previously unselected package kubelet.
Preparing to unpack .../kubelet_1.36.1-1.1_amd64.deb ...
Unpacking kubelet (1.36.1-1.1) ...
Setting up kubeadm (1.36.1-1.1) ...
Setting up kubectl (1.36.1-1.1) ...
Setting up kubernetes-cni (1.9.1-1.1) ...
Setting up kubelet (1.36.1-1.1) ...
Scanning processes...
Scanning candidates...
Scanning linux images...

Pending kernel upgrade!
Running kernel version:
  6.8.0-111-generic
Diagnostics:
  The currently running kernel version is not the expected kernel version 6.8.0-117-generic.

Restarting the system to load the new kernel will not be handled automatically, so you should consider rebooting.

Restarting services...

Service restarts being deferred:
 /etc/needrestart/restart.d/dbus.service
 systemctl restart systemd-logind.service
 systemctl restart unattended-upgrades.service

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

--Step 20.5
root@kubnet-cp-3:~# systemctl restart containerd.service

--Step 20.6
root@kubnet-cp-3:~# systemctl status containerd.service
/*
● containerd.service - containerd container runtime
     Loaded: loaded (/usr/lib/systemd/system/containerd.service; enabled; preset: enabled)
     Active: active (running) since Fri 2026-05-29 12:36:53 +0545; 5s ago
       Docs: https://containerd.io
    Process: 35006 ExecStartPre=/sbin/modprobe overlay (code=exited, status=0/SUCCESS)
   Main PID: 35008 (containerd)
      Tasks: 8
     Memory: 14.1M (peak: 17.7M)
        CPU: 265ms
     CGroup: /system.slice/containerd.service
             └─35008 /usr/bin/containerd

May 29 12:36:53 kubnet-cp-3.unidev.org.np containerd[35008]: time="2026-05-29T12:36:53.425008274+05:45" level=info msg="Start cni network conf syncer for default"
May 29 12:36:53 kubnet-cp-3.unidev.org.np containerd[35008]: time="2026-05-29T12:36:53.425046169+05:45" level=info msg="Start streaming server"
May 29 12:36:53 kubnet-cp-3.unidev.org.np containerd[35008]: time="2026-05-29T12:36:53.425084221+05:45" level=info msg="Registered namespace \"k8s.io\" with NRI"
May 29 12:36:53 kubnet-cp-3.unidev.org.np containerd[35008]: time="2026-05-29T12:36:53.425120021+05:45" level=info msg="runtime interface starting up..."
May 29 12:36:53 kubnet-cp-3.unidev.org.np containerd[35008]: time="2026-05-29T12:36:53.425149639+05:45" level=info msg="starting plugins..."
May 29 12:36:53 kubnet-cp-3.unidev.org.np containerd[35008]: time="2026-05-29T12:36:53.425207508+05:45" level=info msg="Synchronizing NRI (plugin) with current runtime state"
May 29 12:36:53 kubnet-cp-3.unidev.org.np containerd[35008]: time="2026-05-29T12:36:53.426832628+05:45" level=info msg=serving... address=/run/containerd/containerd.sock.ttrpc
May 29 12:36:53 kubnet-cp-3.unidev.org.np containerd[35008]: time="2026-05-29T12:36:53.427315951+05:45" level=info msg=serving... address=/run/containerd/containerd.sock
May 29 12:36:53 kubnet-cp-3.unidev.org.np systemd[1]: Started containerd.service - containerd container runtime.
May 29 12:36:53 kubnet-cp-3.unidev.org.np containerd[35008]: time="2026-05-29T12:36:53.433862954+05:45" level=info msg="containerd successfully booted in 0.110208s"
*/

--Step 20.7
root@kubnet-cp-3:~# which kubelet
/*
/usr/bin/kubelet
*/

--Step 20.8
root@kubnet-cp-3:~# which kubeadm
/*
/usr/bin/kubeadm
*/

--Step 20.9
root@kubnet-cp-3:~# which kubectl
/*
/usr/bin/kubectl
*/

--Step 21
root@kubnet-cp-3:~# kubeadm join kubnet-lb.unidev.org.np:6443 --token 3onebk.aoa1qp57iqf2ewzb \
        --discovery-token-ca-cert-hash sha256:b2b102ceb40e00c1c8ee67e83c6f30686b2d58ff35d62017b7d5a845e92f0a92 \
        --control-plane --certificate-key 1d5eb84966950543a3aabb28fb811e0f9178b48044bc4fedd301b2bb09cb8fa7 --dry-run
/*
[etcd] Would wait for the new etcd member to join the cluster
[kubelet-wait] Would wait for the kubelet to be bootstrapped
[control-plane-join] Would mark node kubnet-cp-3.unidev.org.np as a control-plane

This node has joined the cluster and a new control plane instance was created:

* Certificate signing request was sent to apiserver and approval was received.
* The Kubelet was informed of the new secure connection details.
* Control plane label and taint were applied to the new node.
* The Kubernetes control plane instances scaled up.
* A new etcd member was added to the local/stacked etcd cluster.

To start administering your cluster from this node, you need to run the following as a regular user:

        mkdir -p $HOME/.kube
        sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
        sudo chown $(id -u):$(id -g) $HOME/.kube/config

Run 'kubectl get nodes' to see this node join the cluster.
*/

--Step 21.1
root@kubnet-cp-3:~# kubeadm join kubnet-lb.unidev.org.np:6443 --token 3onebk.aoa1qp57iqf2ewzb \
        --discovery-token-ca-cert-hash sha256:b2b102ceb40e00c1c8ee67e83c6f30686b2d58ff35d62017b7d5a845e92f0a92 \
        --control-plane --certificate-key 1d5eb84966950543a3aabb28fb811e0f9178b48044bc4fedd301b2bb09cb8fa7
/*
[preflight] Running pre-flight checks
[preflight] Reading configuration from the "kubeadm-config" ConfigMap in namespace "kube-system"...
[preflight] Use 'kubeadm init phase upload-config kubeadm --config your-config-file' to re-upload it.
W0529 12:37:41.410874   35085 utils.go:69] The recommended value for "bindAddress" in "KubeProxyConfiguration" is: ::; the provided value is: 0.0.0.0
[preflight] Running pre-flight checks before initializing the new control plane instance
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action beforehand using 'kubeadm config images pull'
[download-certs] Downloading the certificates in Secret "kubeadm-certs" in the "kube-system" Namespace
[download-certs] Saving the certificates to the folder: "/etc/kubernetes/pki"
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [kubnet-cp-3.unidev.org.np localhost] and IPs [192.1.6.31 127.0.0.1 ::1]
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Generating "apiserver-etcd-client" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [kubnet-cp-3.unidev.org.np localhost] and IPs [192.1.6.31 127.0.0.1 ::1]
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local kubnet-cp-3.unidev.org.np kubnet-lb.unidev.org.np] and IPs [10.96.0.1 192.1.6.31]
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Valid certificates and keys now exist in "/etc/kubernetes/pki"
[certs] Using the existing "sa" key
[kubeconfig] Generating kubeconfig files
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
[kubeconfig] Writing "admin.conf" kubeconfig file
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
[kubeconfig] Writing "scheduler.conf" kubeconfig file
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
[control-plane] Creating static Pod manifest for "kube-scheduler"
[check-etcd] Checking that the etcd cluster is healthy
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/instance-config.yaml"
[patches] Applied patch of type "application/strategic-merge-patch+json" to target "kubeletconfiguration"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Starting the kubelet
[etcd] Announced new etcd member joining to the existing etcd cluster
[etcd] Creating static Pod manifest for "etcd"
{"level":"warn","ts":"2026-05-29T12:39:13.732997+0545","logger":"etcd-client","caller":"v3@v3.6.8/retry_interceptor.go:65","msg":"retrying of unary invoker failed","target":"etcd-endpoints://0x85b876621e0/192.1.6.30:2379","method":"/etcdserverpb.Cluster/MemberPromote","attempt":0,"error":"rpc error: code = FailedPrecondition desc = etcdserver: can only promote a learner member which is in sync with leader"}
[etcd] Waiting for the new etcd member to join the cluster. This can take up to 40s
[kubelet-check] Waiting for a healthy kubelet at http://127.0.0.1:10248/healthz. This can take up to 4m0s
[kubelet-check] The kubelet is healthy after 3.632118ms
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap
[mark-control-plane] Marking the node kubnet-cp-3.unidev.org.np as control-plane by adding the labels: [node-role.kubernetes.io/control-plane node.kubernetes.io/exclude-from-external-load-balancers]
[mark-control-plane] Marking the node kubnet-cp-3.unidev.org.np as control-plane by adding the taints [node-role.kubernetes.io/control-plane:NoSchedule]
[control-plane-check] Waiting for healthy control plane components. This can take up to 4m0s
[control-plane-check] Checking kube-apiserver at https://192.1.6.31:6443/livez
[control-plane-check] Checking kube-controller-manager at https://127.0.0.1:10257/healthz
[control-plane-check] Checking kube-scheduler at https://127.0.0.1:10259/livez
[control-plane-check] kube-controller-manager is healthy after 65.956021ms
[control-plane-check] kube-scheduler is healthy after 79.162342ms
[control-plane-check] kube-apiserver is healthy after 118.873552ms

This node has joined the cluster and a new control plane instance was created:

* Certificate signing request was sent to apiserver and approval was received.
* The Kubelet was informed of the new secure connection details.
* Control plane label and taint were applied to the new node.
* The Kubernetes control plane instances scaled up.
* A new etcd member was added to the local/stacked etcd cluster.

To start administering your cluster from this node, you need to run the following as a regular user:

        mkdir -p $HOME/.kube
        sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
        sudo chown $(id -u):$(id -g) $HOME/.kube/config

Run 'kubectl get nodes' to see this node join the cluster.
*/

--Step 21.2
root@kubnet-cp-3:~# mkdir -p $HOME/.kube

--Step 21.3
root@kubnet-cp-3:~# sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

--Step 21.4
root@kubnet-cp-3:~# sudo chown $(id -u):$(id -g) $HOME/.kube/config

--Step 22
root@kubnet-cp-3:~# kubectl get nodes
/*
NAME                          STATUS     ROLES           AGE    VERSION
kubnet-cp-1.unidev.org.np   NotReady   control-plane   141m   v1.36.1
kubnet-cp-2.unidev.org.np   NotReady   control-plane   94m    v1.36.1
kubnet-cp-3.unidev.org.np   NotReady   control-plane   102s   v1.36.1
*/

--Step 22.1
root@kubnet-cp-3:~# kubectl get nodes -o wide
/*
NAME                          STATUS     ROLES           AGE    VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION              CONTAINER-RUNTIME
kubnet-cp-1.unidev.org.np   NotReady   control-plane   22m    v1.36.1   192.1.6.29   <none>        Ubuntu 24.04.4 LTS   6.8.0-111-generic (amd64)   containerd://2.2.4
kubnet-cp-2.unidev.org.np   NotReady   control-plane   11m    v1.36.1   192.1.6.30   <none>        Ubuntu 24.04.4 LTS   6.8.0-111-generic (amd64)   containerd://2.2.4
kubnet-cp-3.unidev.org.np   NotReady   control-plane   106s   v1.36.1   192.1.6.31   <none>        Ubuntu 24.04.4 LTS   6.8.0-111-generic (amd64)   containerd://2.2.4
*/

--Step 22.3
root@kubnet-cp-3:~# exit
/*
logout
*/

--Step 22.4
root@kubnet-cp-3:~# exit
/*
logout
Connection to kubnet-cp-3.unidev.org.np closed.
*/

--Step 23
root@kubnet-lb:~# ssh lab@kubnet-worker-1.unidev.org.np
/*
###########################################################################
                                 WARNING!!!!

                           Welcome to the UNIDEV system.

                             Authorized Access Only.
Any unauthorized use may be monitored, recorded, and subject to legal action.
By accessing you consent to such monitoring if unauthorized use is suspected.
Violators may face criminal, civil, and/or administrative action.

                        This system is the property of UNIDEV.
############################################################################
lab@kubnet-worker-1.unidev.org.np's password:
Last login: Fri May 29 12:45:27 2026 from 192.1.6.28
*/

--Step 23.0
lab@kubnet-worker-1:~$ sudo su -
/*
[sudo] password for lab:
*/

--Step 23.1
root@kubnet-worker-1:~# df -Th
/*
Filesystem                        Type   Size  Used Avail Use% Mounted on
tmpfs                             tmpfs  488M  1.5M  486M   1% /run
/dev/mapper/ubuntu--vg-ubuntu--lv ext4    24G  7.1G   16G  32% /
tmpfs                             tmpfs  2.4G     0  2.4G   0% /dev/shm
tmpfs                             tmpfs  5.0M     0  5.0M   0% /run/lock
/dev/sda2                         ext4   2.0G  200M  1.6G  11% /boot
tmpfs                             tmpfs  487M   12K  487M   1% /run/user/1000
*/

--Step 23.2
root@kubnet-worker-1:~# hostnamectl
/*
 Static hostname: kubnet-worker-1.unidev.org.np
       Icon name: computer-vm
         Chassis: vm 🖴
      Machine ID: 50708e19b677484c92840925bff7e721
         Boot ID: 18226d253f0f483ab19620742b8dfd92
  Virtualization: vmware
Operating System: Ubuntu 24.04.4 LTS
          Kernel: Linux 6.8.0-117-generic
    Architecture: x86-64
 Hardware Vendor: VMware, Inc.
  Hardware Model: VMware Virtual Platform
Firmware Version: 6.00
   Firmware Date: Wed 2018-12-12
    Firmware Age: 7y 5month 2w 2d
*/

--Step 24
root@kubnet-worker-1:~# vi /etc/netplan/50-cloud-init.yaml
/*
# This file is generated from information provided by the datasource.  Changes
# to it will not persist across an instance reboot.  To disable cloud-init's
# network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
    ethernets:
        ens192:
            addresses:
            - 192.1.6.32/24
            nameservers:
                addresses:
                - 192.1.4.11
                - 192.1.4.12
                search: []
            routes:
            -   to: default
                via: 192.1.6.1
    version: 2
*/

--Step 24.1
root@kubnet-worker-1:~# systemctl restart network-online.target

--Step 24.2
root@kubnet-worker-1:~# systemctl status network-online.target
/*
● network-online.target - Network is Online
     Loaded: loaded (/usr/lib/systemd/system/network-online.target; static)
     Active: active since Fri 2026-05-29 12:45:10 +0545; 43s ago
       Docs: man:systemd.special(7)
             https://systemd.io/NETWORK_ONLINE

May 29 12:45:10 kubnet-worker-1.unidev.org.np systemd[1]: Reached target network-online.target - Network is Online.
*/

--Step 25
root@kubnet-worker-1:~# vi /etc/hosts
/*
#Kubnet-LB
192.1.6.28 kubnet-lb.unidev.org.np kubnet-lb

#Kubnet-CP-1
192.1.6.29 kubnet-cp-1.unidev.org.np kubnet-cp-1

#Kubnet-CP-2
192.1.6.30 kubnet-cp-2.unidev.org.np kubnet-cp-2

#Kubnet-CP-3
192.1.6.31 kubnet-cp-3.unidev.org.np kubnet-cp-3

#Kubnet-Worker-1
192.1.6.32 kubnet-worker-1.unidev.org.np kubnet-worker-1
*/

--Step 25.1
root@kubnet-worker-1:~# nslookup kubnet-worker-1.unidev.org.np
/*
Server:         127.0.0.53
Address:        127.0.0.53#53

Name:   kubnet-worker-1.unidev.org.np
Address: 192.1.6.32
*/

--Step 26
root@kubnet-worker-1:~# vi prepare-node.sh
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
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

systemctl enable --now kubelet

echo "==> Node ready for Kubernetes ${K8S_VERSION}"
echo "    Next: run 'kubeadm init' on the first control-plane node"
echo "          or 'kubeadm join' on worker/additional CP nodes"
*/

--Step 26.1
root@kubnet-worker-1:~# chmod -R 775 prepare-node.sh

--Step 26.2
root@kubnet-worker-1:~# ll prepare-node.sh
/*
-rwxrwxr-x 1 root root 3188 May 29 12:46 prepare-node.sh*
*/

--Step 26.3
root@kubnet-worker-1:~# bash ./prepare-node.sh
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
ca-certificates set to manually installed.
curl is already the newest version (8.5.0-2ubuntu10.9).
curl set to manually installed.
gnupg is already the newest version (2.4.4-2ubuntu17.4).
gnupg set to manually installed.
0 upgraded, 0 newly installed, 0 to remove and 12 not upgraded.
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following NEW packages will be installed:
  containerd.io
0 upgraded, 1 newly installed, 0 to remove and 12 not upgraded.
Need to get 23.6 MB of archives.
After this operation, 93.5 MB of additional disk space will be used.
Get:1 https://download.docker.com/linux/ubuntu noble/stable amd64 containerd.io amd64 2.2.4-1~ubuntu.24.04~noble [23.6 MB]
Fetched 23.6 MB in 2s (14.0 MB/s)
Selecting previously unselected package containerd.io.
(Reading database ... 126437 files and directories currently installed.)
Preparing to unpack .../containerd.io_2.2.4-1~ubuntu.24.04~noble_amd64.deb ...
Unpacking containerd.io (2.2.4-1~ubuntu.24.04~noble) ...
Setting up containerd.io (2.2.4-1~ubuntu.24.04~noble) ...
Created symlink /etc/systemd/system/multi-user.target.wants/containerd.service → /usr/lib/systemd/system/containerd.service.
Processing triggers for man-db (2.12.0-4build2) ...
Scanning processes...
Scanning linux images...

Running kernel seems to be up-to-date.

No services need to be restarted.

No containers need to be restarted.

No user sessions are running outdated binaries.

No VM guests are running outdated hypervisor (qemu) binaries on this host.
==> Configuring containerd (SystemdCgroup=true)
==> Installing kubeadm, kubelet, kubectl (v1.36)
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following additional packages will be installed:
  kubernetes-cni
The following NEW packages will be installed:
  kubeadm kubectl kubelet kubernetes-cni
0 upgraded, 4 newly installed, 0 to remove and 12 not upgraded.
Need to get 76.7 MB of archives.
After this operation, 291 MB of additional disk space will be used.
Get:1 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.36/deb  kubeadm 1.36.1-1.1 [12.6 MB]
Get:2 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.36/deb  kubectl 1.36.1-1.1 [11.8 MB]
Get:3 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.36/deb  kubernetes-cni 1.9.1-1.1 [39.0 MB]
Get:4 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.36/deb  kubelet 1.36.1-1.1 [13.4 MB]
Fetched 76.7 MB in 4s (20.2 MB/s)
Selecting previously unselected package kubeadm.
(Reading database ... 126451 files and directories currently installed.)
Preparing to unpack .../kubeadm_1.36.1-1.1_amd64.deb ...
Unpacking kubeadm (1.36.1-1.1) ...
Selecting previously unselected package kubectl.
Preparing to unpack .../kubectl_1.36.1-1.1_amd64.deb ...
Unpacking kubectl (1.36.1-1.1) ...
Selecting previously unselected package kubernetes-cni.
Preparing to unpack .../kubernetes-cni_1.9.1-1.1_amd64.deb ...
Unpacking kubernetes-cni (1.9.1-1.1) ...
Selecting previously unselected package kubelet.
Preparing to unpack .../kubelet_1.36.1-1.1_amd64.deb ...
Unpacking kubelet (1.36.1-1.1) ...
Setting up kubeadm (1.36.1-1.1) ...
Setting up kubectl (1.36.1-1.1) ...
Setting up kubernetes-cni (1.9.1-1.1) ...
Setting up kubelet (1.36.1-1.1) ...
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

--Step 26.4
root@kubnet-worker-1:~# systemctl restart containerd.service

--Step 26.5
root@kubnet-worker-1:~# systemctl status containerd.service
/*
● containerd.service - containerd container runtime
     Loaded: loaded (/usr/lib/systemd/system/containerd.service; enabled; preset: enabled)
     Active: active (running) since Fri 2026-05-29 12:49:24 +0545; 5s ago
       Docs: https://containerd.io
    Process: 2850 ExecStartPre=/sbin/modprobe overlay (code=exited, status=0/SUCCESS)
   Main PID: 2852 (containerd)
      Tasks: 8
     Memory: 14.6M (peak: 18.5M)
        CPU: 273ms
     CGroup: /system.slice/containerd.service
             └─2852 /usr/bin/containerd

May 29 12:49:24 kubnet-worker-1.unidev.org.np containerd[2852]: time="2026-05-29T12:49:24.449337456+05:45" level=info msg="Start cni network conf syncer for default"
May 29 12:49:24 kubnet-worker-1.unidev.org.np containerd[2852]: time="2026-05-29T12:49:24.449385026+05:45" level=info msg="Start streaming server"
May 29 12:49:24 kubnet-worker-1.unidev.org.np containerd[2852]: time="2026-05-29T12:49:24.449564373+05:45" level=info msg="Registered namespace \"k8s.io\" with NRI"
May 29 12:49:24 kubnet-worker-1.unidev.org.np containerd[2852]: time="2026-05-29T12:49:24.449614860+05:45" level=info msg="runtime interface starting up..."
May 29 12:49:24 kubnet-worker-1.unidev.org.np containerd[2852]: time="2026-05-29T12:49:24.449652965+05:45" level=info msg="starting plugins..."
May 29 12:49:24 kubnet-worker-1.unidev.org.np containerd[2852]: time="2026-05-29T12:49:24.449712909+05:45" level=info msg="Synchronizing NRI (plugin) with current runtime state"
May 29 12:49:24 kubnet-worker-1.unidev.org.np containerd[2852]: time="2026-05-29T12:49:24.452306499+05:45" level=info msg=serving... address=/run/containerd/containerd.sock.ttrpc
May 29 12:49:24 kubnet-worker-1.unidev.org.np containerd[2852]: time="2026-05-29T12:49:24.453164042+05:45" level=info msg=serving... address=/run/containerd/containerd.sock
May 29 12:49:24 kubnet-worker-1.unidev.org.np containerd[2852]: time="2026-05-29T12:49:24.453781055+05:45" level=info msg="containerd successfully booted in 0.113188s"
May 29 12:49:24 kubnet-worker-1.unidev.org.np systemd[1]: Started containerd.service - containerd container runtime.
*/

--Step 26.6
root@kubnet-worker-1:~# which kubelet
/*
/usr/bin/kubelet
*/

--Step 26.7
root@kubnet-worker-1:~# which kubeadm
/*
/usr/bin/kubeadm
*/

--Step 26.8
root@kubnet-worker-1:~# which kubectl
/*
/usr/bin/kubectl
*/

--Step 27
root@kubnet-worker-1:~# kubeadm join kubnet-lb.unidev.org.np:6443 --token 3onebk.aoa1qp57iqf2ewzb \
        --discovery-token-ca-cert-hash sha256:b2b102ceb40e00c1c8ee67e83c6f30686b2d58ff35d62017b7d5a845e92f0a92 --dry-run
/*
[dryrun] Would write file "/var/lib/kubelet/kubeadm-flags.env" with content:
KUBELET_KUBEADM_ARGS=""
[kubelet-wait] Would wait for the kubelet to be bootstrapped

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.
*/

--Step 27.1
root@kubnet-worker-1:~# kubeadm join kubnet-lb.unidev.org.np:6443 --token 3onebk.aoa1qp57iqf2ewzb \
        --discovery-token-ca-cert-hash sha256:b2b102ceb40e00c1c8ee67e83c6f30686b2d58ff35d62017b7d5a845e92f0a92
/*
[preflight] Running pre-flight checks
[preflight] Reading configuration from the "kubeadm-config" ConfigMap in namespace "kube-system"...
[preflight] Use 'kubeadm init phase upload-config kubeadm --config your-config-file' to re-upload it.
W0529 12:50:19.181865    2942 utils.go:69] The recommended value for "bindAddress" in "KubeProxyConfiguration" is: ::; the provided value is: 0.0.0.0
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/instance-config.yaml"
[patches] Applied patch of type "application/strategic-merge-patch+json" to target "kubeletconfiguration"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Starting the kubelet
[kubelet-check] Waiting for a healthy kubelet at http://127.0.0.1:10248/healthz. This can take up to 4m0s
[kubelet-check] The kubelet is healthy after 1.003983582s
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.
*/

--Step 27.2
root@kubnet-worker-1:~# systemctl status kubelet
/*
● kubelet.service - kubelet: The Kubernetes Node Agent
     Loaded: loaded (/usr/lib/systemd/system/kubelet.service; enabled; preset: enabled)
    Drop-In: /usr/lib/systemd/system/kubelet.service.d
             └─10-kubeadm.conf
     Active: active (running) since Fri 2026-05-29 12:50:20 +0545; 23s ago
       Docs: https://kubernetes.io/docs/
   Main PID: 3012 (kubelet)
      Tasks: 12 (limit: 5746)
     Memory: 24.6M (peak: 25.1M)
        CPU: 2.490s
     CGroup: /system.slice/kubelet.service
             └─3012 /usr/bin/kubelet --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf --config=/var/lib/kubelet/config.yaml

May 29 12:50:21 kubnet-worker-1.unidev.org.np kubelet[3012]: I0529 12:50:21.817734    3012 transport.go:147] "Certificate rotation detected, shutting down client connections to start usi>
May 29 12:50:21 kubnet-worker-1.unidev.org.np kubelet[3012]: I0529 12:50:21.818363    3012 reflector.go:664] "Warning: watch ended with error" reflector="k8s.io/client-go/informers/facto>
May 29 12:50:21 kubnet-worker-1.unidev.org.np kubelet[3012]: I0529 12:50:21.818600    3012 reflector.go:664] "Warning: watch ended with error" reflector="k8s.io/client-go/informers/facto>
May 29 12:50:21 kubnet-worker-1.unidev.org.np kubelet[3012]: I0529 12:50:21.818803    3012 reflector.go:664] "Warning: watch ended with error" reflector="k8s.io/client-go/informers/facto>
May 29 12:50:21 kubnet-worker-1.unidev.org.np kubelet[3012]: I0529 12:50:21.865176    3012 apiserver.go:51] "Watching apiserver"
May 29 12:50:21 kubnet-worker-1.unidev.org.np kubelet[3012]: I0529 12:50:21.933981    3012 desired_state_of_world_populator.go:154] "Finished populating initial desired state of world"
May 29 12:50:21 kubnet-worker-1.unidev.org.np kubelet[3012]: I0529 12:50:21.939907    3012 reconciler_common.go:251] "operationExecutor.VerifyControllerAttachedVolume started for volume >
May 29 12:50:21 kubnet-worker-1.unidev.org.np kubelet[3012]: I0529 12:50:21.940268    3012 reconciler_common.go:251] "operationExecutor.VerifyControllerAttachedVolume started for volume >
May 29 12:50:21 kubnet-worker-1.unidev.org.np kubelet[3012]: I0529 12:50:21.940340    3012 reconciler_common.go:251] "operationExecutor.VerifyControllerAttachedVolume started for volume >
May 29 12:50:21 kubnet-worker-1.unidev.org.np kubelet[3012]: I0529 12:50:21.940522    3012 reconciler_common.go:251] "operationExecutor.VerifyControllerAttachedVolume started for volume >
*/

--Step 27.3
root@kubnet-worker-1:~# exit
/*
logout
*/

--Step 27.4
lab@kubnet-worker-1:~$ exit
/*
logout
Connection to kubnet-worker-1.unidev.org.np closed.
*/

--Step 28
root@kubnet-lb:~# ssh lab@kubnet-cp-1.unidev.org.np
/*
###########################################################################
                                 WARNING!!!!

                           Welcome to the UNIDEV system.

                             Authorized Access Only.
Any unauthorized use may be monitored, recorded, and subject to legal action.
By accessing you consent to such monitoring if unauthorized use is suspected.
Violators may face criminal, civil, and/or administrative action.

                        This system is the property of UNIDEV.
############################################################################
lab@kubnet-cp-1.unidev.org.np's password:
Last login: Fri May 29 12:09:24 2026 from 192.1.6.28
*/

--Step 28.0
lab@kubnet-cp-1:~$ sudo su -
/*
[sudo] password for lab:
*/

--Step 28.1
root@kubnet-cp-1:~# kubectl get nodes
/*
NAME                              STATUS     ROLES           AGE    VERSION
kubnet-cp-1.unidev.org.np       NotReady   control-plane   34m    v1.36.1
kubnet-cp-2.unidev.org.np       NotReady   control-plane   23m    v1.36.1
kubnet-cp-3.unidev.org.np       NotReady   control-plane   13m    v1.36.1
kubnet-worker-1.unidev.org.np   NotReady   <none>          3m8s   v1.36.1
*/

--Step 28.2
root@kubnet-cp-1:~# kubectl get nodes -o wide
/*
NAME                              STATUS     ROLES           AGE     VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION              CONTAINER-RUNTIME
kubnet-cp-1.unidev.org.np       NotReady   control-plane   34m     v1.36.1   192.1.6.29   <none>        Ubuntu 24.04.4 LTS   6.8.0-111-generic (amd64)   containerd://2.2.4
kubnet-cp-2.unidev.org.np       NotReady   control-plane   24m     v1.36.1   192.1.6.30   <none>        Ubuntu 24.04.4 LTS   6.8.0-111-generic (amd64)   containerd://2.2.4
kubnet-cp-3.unidev.org.np       NotReady   control-plane   14m     v1.36.1   192.1.6.31   <none>        Ubuntu 24.04.4 LTS   6.8.0-111-generic (amd64)   containerd://2.2.4
kubnet-worker-1.unidev.org.np   NotReady   <none>          3m25s   v1.36.1   192.1.6.32   <none>        Ubuntu 24.04.4 LTS   6.8.0-117-generic (amd64)   containerd://2.2.4
*/

--Step 29
root@kubnet-cp-1:~# vi cilium_pkg.sh
/*
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
*/

--Step 29.1
root@kubnet-cp-1:~# chmod -R 775 cilium_pkg.sh

--Step 29.2
root@kubnet-cp-1:~# ll cilium_pkg.sh
/*
-rwxrwxr-x 1 root root 496 May 29 12:56 cilium_pkg.sh*
*/

--Step 29.3
root@kubnet-cp-1:~# bash ./cilium_pkg.sh
/*
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100 67.1M  100 67.1M    0     0  14.6M      0  0:00:04  0:00:04 --:--:-- 17.9M
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100    92  100    92    0     0    117      0 --:--:-- --:--:-- --:--:--   117
cilium-linux-amd64.tar.gz: OK
cilium
*/

--Step 29.4
root@kubnet-cp-1:~#  which cilium
/*
/usr/local/bin/cilium
*/

--Step 29.5
root@kubnet-cp-1:~# cilium install --version 1.19.4
/*
ℹ️  Using Cilium version 1.19.4
🔮 Auto-detected cluster name: kubernetes
🔮 Auto-detected kube-proxy has been installed
*/

--Step 29.6
root@kubnet-cp-1:~# cilium status
/*
    /¯¯\
 /¯¯\__/¯¯\    Cilium:             1 errors, 4 warnings
 \__/¯¯\__/    Operator:           1 errors, 2 warnings
 /¯¯\__/¯¯\    Envoy DaemonSet:    1 errors, 4 warnings
 \__/¯¯\__/    Hubble Relay:       disabled
    \__/       ClusterMesh:        disabled

DaemonSet              cilium                   Desired: 4, Unavailable: 4/4
DaemonSet              cilium-envoy             Desired: 4, Unavailable: 4/4
Deployment             cilium-operator          Desired: 1, Unavailable: 1/1
Containers:            cilium                   Pending: 4
                       cilium-envoy             Pending: 4
                       cilium-operator          Pending: 1
                       clustermesh-apiserver
                       hubble-relay
Cluster Pods:          0/2 managed by Cilium
Helm chart version:    1.19.4
Image versions         cilium             quay.io/cilium/cilium:v1.19.4@sha256:2eb67991eaa9368ba199c2fac2c573cb0ffdeb79184533344f42fc9a7ff6af3c: 4
                       cilium-envoy       quay.io/cilium/cilium-envoy:v1.36.6-1778235340-b87d1e32f522b33bd51701c6476d199326f01496@sha256:71d4fa0ec45e8d546dbd5604e169dc77fe92be63b799313bff031d00d89762e3: 4
                       cilium-operator    quay.io/cilium/operator-generic:v1.19.4@sha256:1aa2b62735e7d8ab49ee840ae59c346932024c88901579121395c1271b435f71: 1
Errors:                cilium             cilium                             4 pods of DaemonSet cilium are not ready
                       cilium-envoy       cilium-envoy                       4 pods of DaemonSet cilium-envoy are not ready
                       cilium-operator    cilium-operator                    1 pods of Deployment cilium-operator are not ready
Warnings:              cilium             cilium-c6pk2                       pod is pending
                       cilium             cilium-dlj6t                       pod is pending
                       cilium             cilium-nf6dk                       pod is pending
                       cilium             cilium-nwdg2                       pod is pending
                       cilium-envoy       cilium-envoy-94wdm                 pod is pending
                       cilium-envoy       cilium-envoy-mlk5f                 pod is pending
                       cilium-envoy       cilium-envoy-qzx9w                 pod is pending
                       cilium-envoy       cilium-envoy-tbcvb                 pod is pending
                       cilium-operator    cilium-operator-bbdd9c45f-9wj7x    pod is pending
                       cilium-operator    cilium-operator-bbdd9c45f-9wj7x    pod is pending
*/

--Step 30
root@kubnet-cp-1:~# kubectl get nodes
/*
NAME                              STATUS   ROLES           AGE   VERSION
kubnet-cp-1.unidev.org.np       Ready    control-plane   41m   v1.36.1
kubnet-cp-2.unidev.org.np       Ready    control-plane   30m   v1.36.1
kubnet-cp-3.unidev.org.np       Ready    control-plane   20m   v1.36.1
kubnet-worker-1.unidev.org.np   Ready    <none>          10m   v1.36.1
*/

--Step 30.1
root@kubnet-cp-1:~# kubectl get nodes -o wide
/*
NAME                              STATUS   ROLES           AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION              CONTAINER-RUNTIME
kubnet-cp-1.unidev.org.np       Ready    control-plane   41m   v1.36.1   192.1.6.29   <none>        Ubuntu 24.04.4 LTS   6.8.0-111-generic (amd64)   containerd://2.2.4
kubnet-cp-2.unidev.org.np       Ready    control-plane   30m   v1.36.1   192.1.6.30   <none>        Ubuntu 24.04.4 LTS   6.8.0-111-generic (amd64)   containerd://2.2.4
kubnet-cp-3.unidev.org.np       Ready    control-plane   21m   v1.36.1   192.1.6.31   <none>        Ubuntu 24.04.4 LTS   6.8.0-111-generic (amd64)   containerd://2.2.4
kubnet-worker-1.unidev.org.np   Ready    <none>          10m   v1.36.1   192.1.6.32   <none>        Ubuntu 24.04.4 LTS   6.8.0-117-generic (amd64)   containerd://2.2.4
*/

--Step 30.2
root@kubnet-cp-1:~# kubectl get pods -A
/*
NAMESPACE     NAME                                                  READY   STATUS    RESTARTS   AGE
kube-system   cilium-c6pk2                                          1/1     Running   0          2m36s
kube-system   cilium-dlj6t                                          1/1     Running   0          2m36s
kube-system   cilium-envoy-94wdm                                    1/1     Running   0          2m36s
kube-system   cilium-envoy-mlk5f                                    1/1     Running   0          2m36s
kube-system   cilium-envoy-qzx9w                                    1/1     Running   0          2m36s
kube-system   cilium-envoy-tbcvb                                    1/1     Running   0          2m36s
kube-system   cilium-nf6dk                                          1/1     Running   0          2m36s
kube-system   cilium-nwdg2                                          1/1     Running   0          2m36s
kube-system   cilium-operator-bbdd9c45f-9wj7x                       1/1     Running   0          2m36s
kube-system   coredns-589f44dc88-h9m9x                              1/1     Running   0          41m
kube-system   coredns-589f44dc88-lzv48                              1/1     Running   0          41m
kube-system   etcd-kubnet-cp-1.unidev.org.np                      1/1     Running   0          42m
kube-system   etcd-kubnet-cp-2.unidev.org.np                      1/1     Running   0          31m
kube-system   etcd-kubnet-cp-3.unidev.org.np                      1/1     Running   0          21m
kube-system   kube-apiserver-kubnet-cp-1.unidev.org.np            1/1     Running   0          42m
kube-system   kube-apiserver-kubnet-cp-2.unidev.org.np            1/1     Running   0          31m
kube-system   kube-apiserver-kubnet-cp-3.unidev.org.np            1/1     Running   0          21m
kube-system   kube-controller-manager-kubnet-cp-1.unidev.org.np   1/1     Running   0          42m
kube-system   kube-controller-manager-kubnet-cp-2.unidev.org.np   1/1     Running   0          31m
kube-system   kube-controller-manager-kubnet-cp-3.unidev.org.np   1/1     Running   0          21m
kube-system   kube-proxy-hrb78                                      1/1     Running   0          21m
kube-system   kube-proxy-lql9d                                      1/1     Running   0          10m
kube-system   kube-proxy-sqv6x                                      1/1     Running   0          31m
kube-system   kube-proxy-x8ftj                                      1/1     Running   0          41m
kube-system   kube-scheduler-kubnet-cp-1.unidev.org.np            1/1     Running   0          42m
kube-system   kube-scheduler-kubnet-cp-2.unidev.org.np            1/1     Running   0          31m
kube-system   kube-scheduler-kubnet-cp-3.unidev.org.np            1/1     Running   0          21m
*/

--Step 31
root@kubnet-cp-1:~# exit
/*
logout
*/

--Step 32
lab@kubnet-cp-1:~$ exit
/*
logout
Connection to kubnet-cp-1.unidev.org.np closed.
*/

--Step 33
root@kubnet-lb:~# ssh lab@kubnet-cp-2.unidev.org.np
/*
###########################################################################
                                 WARNING!!!!

                           Welcome to the UNIDEV system.

                             Authorized Access Only.
Any unauthorized use may be monitored, recorded, and subject to legal action.
By accessing you consent to such monitoring if unauthorized use is suspected.
Violators may face criminal, civil, and/or administrative action.

                        This system is the property of UNIDEV.
############################################################################
lab@kubnet-cp-2.unidev.org.np's password:
Last login: Fri May 29 13:02:35 2026 from 192.1.6.28
*/

--Step 33.0
lab@kubnet-cp-2:~$ sudo su -
/*
[sudo] password for lab:
*/

--Step 34
root@kubnet-cp-2:~# which cilium

--Step 34.1
root@kubnet-cp-2:~# vi cilium_pkg.sh
/*
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
*/

--Step 34.2
root@kubnet-cp-2:~# chmod -R 775 cilium_pkg.sh

--Step 34.3
root@kubnet-cp-2:~# ll cilium_pkg.sh
/*
-rwxrwxr-x 1 root root 496 May 29 13:04 cilium_pkg.sh*
*/

--Step 34.4
root@kubnet-cp-2:~# bash ./cilium_pkg.sh
/*
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100 67.1M  100 67.1M    0     0  20.9M      0  0:00:03  0:00:03 --:--:-- 29.1M
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100    92  100    92    0     0    186      0 --:--:-- --:--:-- --:--:--   186
cilium-linux-amd64.tar.gz: OK
cilium
*/

--Step 34.5
root@kubnet-cp-2:~# which cilium
/*
/usr/local/bin/cilium
*/

--(Not Needed On chiled master nodes)
root@kubnet-cp-2:~# cilium install --version 1.19.4
/*
ℹ️  Using Cilium version 1.19.4
🔮 Auto-detected cluster name: kubernetes
🔮 Auto-detected kube-proxy has been installed

Error: Unable to install Cilium: release name check failed: cannot reuse a name that is still in use
*/

--Step 34.6
root@kubnet-cp-2:~# cilium status
/*
    /¯¯\
 /¯¯\__/¯¯\    Cilium:             OK
 \__/¯¯\__/    Operator:           OK
 /¯¯\__/¯¯\    Envoy DaemonSet:    OK
 \__/¯¯\__/    Hubble Relay:       disabled
    \__/       ClusterMesh:        disabled

DaemonSet              cilium                   Desired: 4, Ready: 4/4, Available: 4/4
DaemonSet              cilium-envoy             Desired: 4, Ready: 4/4, Available: 4/4
Deployment             cilium-operator          Desired: 1, Ready: 1/1, Available: 1/1
Containers:            cilium                   Running: 4
                       cilium-envoy             Running: 4
                       cilium-operator          Running: 1
                       clustermesh-apiserver
                       hubble-relay
Cluster Pods:          2/2 managed by Cilium
Helm chart version:    1.19.4
Image versions         cilium             quay.io/cilium/cilium:v1.19.4@sha256:2eb67991eaa9368ba199c2fac2c573cb0ffdeb79184533344f42fc9a7ff6af3c: 4
                       cilium-envoy       quay.io/cilium/cilium-envoy:v1.36.6-1778235340-b87d1e32f522b33bd51701c6476d199326f01496@sha256:71d4fa0ec45e8d546dbd5604e169dc77fe92be63b799313bff031d00d89762e3: 4
                       cilium-operator    quay.io/cilium/operator-generic:v1.19.4@sha256:1aa2b62735e7d8ab49ee840ae59c346932024c88901579121395c1271b435f71: 1
*/

--Step 35
root@kubnet-cp-2:~# kubectl get nodes
/*
NAME                              STATUS   ROLES           AGE   VERSION
kubnet-cp-1.unidev.org.np       Ready    control-plane   49m   v1.36.1
kubnet-cp-2.unidev.org.np       Ready    control-plane   38m   v1.36.1
kubnet-cp-3.unidev.org.np       Ready    control-plane   28m   v1.36.1
kubnet-worker-1.unidev.org.np   Ready    <none>          17m   v1.36.1
*/

--Step 35.1
root@kubnet-cp-2:~# kubectl get nodes -o wide
/*
NAME                              STATUS   ROLES           AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION              CONTAINER-RUNTIME
kubnet-cp-1.unidev.org.np       Ready    control-plane   49m   v1.36.1   192.1.6.29   <none>        Ubuntu 24.04.4 LTS   6.8.0-111-generic (amd64)   containerd://2.2.4
kubnet-cp-2.unidev.org.np       Ready    control-plane   38m   v1.36.1   192.1.6.30   <none>        Ubuntu 24.04.4 LTS   6.8.0-111-generic (amd64)   containerd://2.2.4
kubnet-cp-3.unidev.org.np       Ready    control-plane   28m   v1.36.1   192.1.6.31   <none>        Ubuntu 24.04.4 LTS   6.8.0-111-generic (amd64)   containerd://2.2.4
kubnet-worker-1.unidev.org.np   Ready    <none>          18m   v1.36.1   192.1.6.32   <none>        Ubuntu 24.04.4 LTS   6.8.0-117-generic (amd64)   containerd://2.2.4
*/

--Step 35.2
root@kubnet-cp-2:~# kubectl get pods -A
/*
NAMESPACE     NAME                                                  READY   STATUS    RESTARTS   AGE
kube-system   cilium-c6pk2                                          1/1     Running   0          10m
kube-system   cilium-dlj6t                                          1/1     Running   0          10m
kube-system   cilium-envoy-94wdm                                    1/1     Running   0          10m
kube-system   cilium-envoy-mlk5f                                    1/1     Running   0          10m
kube-system   cilium-envoy-qzx9w                                    1/1     Running   0          10m
kube-system   cilium-envoy-tbcvb                                    1/1     Running   0          10m
kube-system   cilium-nf6dk                                          1/1     Running   0          10m
kube-system   cilium-nwdg2                                          1/1     Running   0          10m
kube-system   cilium-operator-bbdd9c45f-9wj7x                       1/1     Running   0          10m
kube-system   coredns-589f44dc88-h9m9x                              1/1     Running   0          49m
kube-system   coredns-589f44dc88-lzv48                              1/1     Running   0          49m
kube-system   etcd-kubnet-cp-1.unidev.org.np                      1/1     Running   0          49m
kube-system   etcd-kubnet-cp-2.unidev.org.np                      1/1     Running   0          38m
kube-system   etcd-kubnet-cp-3.unidev.org.np                      1/1     Running   0          28m
kube-system   kube-apiserver-kubnet-cp-1.unidev.org.np            1/1     Running   0          49m
kube-system   kube-apiserver-kubnet-cp-2.unidev.org.np            1/1     Running   0          38m
kube-system   kube-apiserver-kubnet-cp-3.unidev.org.np            1/1     Running   0          28m
kube-system   kube-controller-manager-kubnet-cp-1.unidev.org.np   1/1     Running   0          49m
kube-system   kube-controller-manager-kubnet-cp-2.unidev.org.np   1/1     Running   0          38m
kube-system   kube-controller-manager-kubnet-cp-3.unidev.org.np   1/1     Running   0          28m
kube-system   kube-proxy-hrb78                                      1/1     Running   0          28m
kube-system   kube-proxy-lql9d                                      1/1     Running   0          18m
kube-system   kube-proxy-sqv6x                                      1/1     Running   0          38m
kube-system   kube-proxy-x8ftj                                      1/1     Running   0          49m
kube-system   kube-scheduler-kubnet-cp-1.unidev.org.np            1/1     Running   0          49m
kube-system   kube-scheduler-kubnet-cp-2.unidev.org.np            1/1     Running   0          38m
kube-system   kube-scheduler-kubnet-cp-3.unidev.org.np            1/1     Running   0          28m
*/

--Step 36
root@kubnet-cp-2:~# exit
/*
logout
*/

--Step 36.1
lab@kubnet-cp-2:~$ exit
/*
logout
Connection to kubnet-cp-2.unidev.org.np closed.
*/

--Step 37
root@kubnet-lb:~# ssh lab@kubnet-cp-3.unidev.org.np
/*
###########################################################################
                                 WARNING!!!!

                           Welcome to the UNIDEV system.

                             Authorized Access Only.
Any unauthorized use may be monitored, recorded, and subject to legal action.
By accessing you consent to such monitoring if unauthorized use is suspected.
Violators may face criminal, civil, and/or administrative action.

                        This system is the property of UNIDEV.
############################################################################
lab@kubnet-cp-3.unidev.org.np's password:
*/

--Step 37.0
lab@kubnet-cp-3:~$ sudo su -
/*
[sudo] password for lab:
*/

--Step 38
root@kubnet-cp-3:~# which cilium

--Step 38.1
root@kubnet-cp-3:~# vi cilium_pkg.sh
/*
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
*/

--Step 38.2
root@kubnet-cp-3:~# chmod -R 775 cilium_pkg.sh

--Step 38.3
root@kubnet-cp-3:~# ll cilium_pkg.sh
/*
-rwxrwxr-x 1 root root 496 May 29 13:11 cilium_pkg.sh*
*/

--Step 38.4
root@kubnet-cp-3:~# bash ./cilium_pkg.sh
/*
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100 67.1M  100 67.1M    0     0  25.8M      0  0:00:02  0:00:02 --:--:-- 42.8M
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100    92  100    92    0     0    218      0 --:--:-- --:--:-- --:--:--   218
cilium-linux-amd64.tar.gz: OK
cilium
*/

--Step 38.5
root@kubnet-cp-3:~# which cilium
/*
/usr/local/bin/cilium
*/

--Step 38.6
root@kubnet-cp-3:~# cilium status
/*
    /¯¯\
 /¯¯\__/¯¯\    Cilium:             OK
 \__/¯¯\__/    Operator:           OK
 /¯¯\__/¯¯\    Envoy DaemonSet:    OK
 \__/¯¯\__/    Hubble Relay:       disabled
    \__/       ClusterMesh:        disabled

DaemonSet              cilium                   Desired: 4, Ready: 4/4, Available: 4/4
DaemonSet              cilium-envoy             Desired: 4, Ready: 4/4, Available: 4/4
Deployment             cilium-operator          Desired: 1, Ready: 1/1, Available: 1/1
Containers:            cilium                   Running: 4
                       cilium-envoy             Running: 4
                       cilium-operator          Running: 1
                       clustermesh-apiserver
                       hubble-relay
Cluster Pods:          2/2 managed by Cilium
Helm chart version:    1.19.4
Image versions         cilium             quay.io/cilium/cilium:v1.19.4@sha256:2eb67991eaa9368ba199c2fac2c573cb0ffdeb79184533344f42fc9a7ff6af3c: 4
                       cilium-envoy       quay.io/cilium/cilium-envoy:v1.36.6-1778235340-b87d1e32f522b33bd51701c6476d199326f01496@sha256:71d4fa0ec45e8d546dbd5604e169dc77fe92be63b799313bff031d00d89762e3: 4
                       cilium-operator    quay.io/cilium/operator-generic:v1.19.4@sha256:1aa2b62735e7d8ab49ee840ae59c346932024c88901579121395c1271b435f71: 1
*/

--Step 39
root@kubnet-cp-3:~# kubectl get nodes
/*
NAME                              STATUS   ROLES           AGE   VERSION
kubnet-cp-1.unidev.org.np       Ready    control-plane   53m   v1.36.1
kubnet-cp-2.unidev.org.np       Ready    control-plane   43m   v1.36.1
kubnet-cp-3.unidev.org.np       Ready    control-plane   33m   v1.36.1
kubnet-worker-1.unidev.org.np   Ready    <none>          22m   v1.36.1
*/

--Step 39.1
root@kubnet-cp-3:~# kubectl get nodes -o wide
/*
NAME                              STATUS   ROLES           AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION              CONTAINER-RUNTIME
kubnet-cp-1.unidev.org.np       Ready    control-plane   54m   v1.36.1   192.1.6.29   <none>        Ubuntu 24.04.4 LTS   6.8.0-111-generic (amd64)   containerd://2.2.4
kubnet-cp-2.unidev.org.np       Ready    control-plane   43m   v1.36.1   192.1.6.30   <none>        Ubuntu 24.04.4 LTS   6.8.0-111-generic (amd64)   containerd://2.2.4
kubnet-cp-3.unidev.org.np       Ready    control-plane   33m   v1.36.1   192.1.6.31   <none>        Ubuntu 24.04.4 LTS   6.8.0-111-generic (amd64)   containerd://2.2.4
kubnet-worker-1.unidev.org.np   Ready    <none>          22m   v1.36.1   192.1.6.32   <none>        Ubuntu 24.04.4 LTS   6.8.0-117-generic (amd64)   containerd://2.2.4
*/

--Step 39.2
root@kubnet-cp-3:~# kubectl get pods -A
/*
NAMESPACE     NAME                                                  READY   STATUS    RESTARTS   AGE
kube-system   cilium-c6pk2                                          1/1     Running   0          14m
kube-system   cilium-dlj6t                                          1/1     Running   0          14m
kube-system   cilium-envoy-94wdm                                    1/1     Running   0          14m
kube-system   cilium-envoy-mlk5f                                    1/1     Running   0          14m
kube-system   cilium-envoy-qzx9w                                    1/1     Running   0          14m
kube-system   cilium-envoy-tbcvb                                    1/1     Running   0          14m
kube-system   cilium-nf6dk                                          1/1     Running   0          14m
kube-system   cilium-nwdg2                                          1/1     Running   0          14m
kube-system   cilium-operator-bbdd9c45f-9wj7x                       1/1     Running   0          14m
kube-system   coredns-589f44dc88-h9m9x                              1/1     Running   0          54m
kube-system   coredns-589f44dc88-lzv48                              1/1     Running   0          54m
kube-system   etcd-kubnet-cp-1.unidev.org.np                      1/1     Running   0          54m
kube-system   etcd-kubnet-cp-2.unidev.org.np                      1/1     Running   0          43m
kube-system   etcd-kubnet-cp-3.unidev.org.np                      1/1     Running   0          33m
kube-system   kube-apiserver-kubnet-cp-1.unidev.org.np            1/1     Running   0          54m
kube-system   kube-apiserver-kubnet-cp-2.unidev.org.np            1/1     Running   0          43m
kube-system   kube-apiserver-kubnet-cp-3.unidev.org.np            1/1     Running   0          33m
kube-system   kube-controller-manager-kubnet-cp-1.unidev.org.np   1/1     Running   0          54m
kube-system   kube-controller-manager-kubnet-cp-2.unidev.org.np   1/1     Running   0          43m
kube-system   kube-controller-manager-kubnet-cp-3.unidev.org.np   1/1     Running   0          33m
kube-system   kube-proxy-hrb78                                      1/1     Running   0          33m
kube-system   kube-proxy-lql9d                                      1/1     Running   0          22m
kube-system   kube-proxy-sqv6x                                      1/1     Running   0          43m
kube-system   kube-proxy-x8ftj                                      1/1     Running   0          54m
kube-system   kube-scheduler-kubnet-cp-1.unidev.org.np            1/1     Running   0          54m
kube-system   kube-scheduler-kubnet-cp-2.unidev.org.np            1/1     Running   0          43m
kube-system   kube-scheduler-kubnet-cp-3.unidev.org.np            1/1     Running   0          33m
*/

--Step 40
root@kubnet-cp-3:~# exit
/*
logout
*/

--Step 40.1
lab@kubnet-cp-3:~$ exit
/*
logout
Connection to kubnet-cp-3.unidev.org.np closed.
*/
