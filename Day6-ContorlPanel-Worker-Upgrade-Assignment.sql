--Step 1
root@kubnet-cp-01:~# vi prepare-node.sh
/*
#!/usr/bin/env bash
set -euo pipefail

# Usage: prepare-node.sh [k8s-minor-version]
# Example: prepare-node.sh 1.32   (default: 1.32)
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

--Step 1.1
root@kubnet-cp-01:~# chmod -R 775 prepare-node.sh

--Step 1.2
root@kubnet-cp-01:~# ll prepare-node.sh
/*
-rwxrwxr-x 1 root root 3188 May 15 16:21 prepare-node.sh*
*/

--Step 1.3
root@kubnet-cp-01:~# cat prepare-node.sh | grep -i -E "K8S_VERSION=|apt-get install kubeadm="
/*
K8S_VERSION="${1:-1.36}"
apt-get install kubeadm=1.36.0-1.1 kubelet=1.36.0-1.1 kubectl=1.36.0-1.1 -y
*/

--Step 1.4
root@kubnet-cp-01:~# bash ./prepare-node.sh
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
0 upgraded, 0 newly installed, 0 to remove and 18 not upgraded.
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following NEW packages will be installed:
  containerd.io
0 upgraded, 1 newly installed, 0 to remove and 18 not upgraded.
Need to get 23.6 MB of archives.
After this operation, 93.5 MB of additional disk space will be used.
Get:1 https://download.docker.com/linux/ubuntu noble/stable amd64 containerd.io amd64 2.2.4-1                                                                                                ~ubuntu.24.04~noble [23.6 MB]
Fetched 23.6 MB in 2s (15.2 MB/s)
Selecting previously unselected package containerd.io.
(Reading database ... 126415 files and directories currently installed.)
Preparing to unpack .../containerd.io_2.2.4-1~ubuntu.24.04~noble_amd64.deb ...
Unpacking containerd.io (2.2.4-1~ubuntu.24.04~noble) ...
Setting up containerd.io (2.2.4-1~ubuntu.24.04~noble) ...
Created symlink /etc/systemd/system/multi-user.target.wants/containerd.service → /usr/lib/sys                                                                                                temd/system/containerd.service.
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
  cri-tools kubernetes-cni
The following NEW packages will be installed:
  cri-tools kubeadm kubectl kubelet kubernetes-cni
0 upgraded, 5 newly installed, 0 to remove and 18 not upgraded.
Need to get 93.0 MB of archives.
After this operation, 331 MB of additional disk space will be used.
Get:1 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.36/deb                                                                                                  cri-tools 1.36.0-1.1 [16.3 MB]
Get:2 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.36/deb                                                                                                  kubeadm 1.36.0-1.1 [12.5 MB]
Get:3 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.36/deb                                                                                                  kubectl 1.36.0-1.1 [11.8 MB]
Get:4 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.36/deb                                                                                                  kubernetes-cni 1.9.1-1.1 [39.0 MB]
Get:5 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.36/deb                                                                                                  kubelet 1.36.0-1.1 [13.4 MB]
Fetched 93.0 MB in 4s (22.9 MB/s)
Selecting previously unselected package cri-tools.
(Reading database ... 126429 files and directories currently installed.)
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

--Step 2
root@kubnet-cp-01:~# which containerd
/*
/usr/bin/containerd
*/

--Step 2.1
root@kubnet-cp-01:~# containerd --version
/*
containerd containerd.io v2.2.4 193637f7ee8ae5f5aa5248f49e7baa3e6164966e
*/

--Step 2.3
root@kubnet-cp-01:~# systemctl restart containerd.service

--Step 2.4
root@kubnet-cp-01:~# systemctl status containerd.service
/*
● containerd.service - containerd container runtime
     Loaded: loaded (/usr/lib/systemd/system/containerd.service; enabled; preset: enabled)
     Active: active (running) since Sat 2026-05-30 12:30:43 +0545; 10s ago
       Docs: https://containerd.io
    Process: 6112 ExecStartPre=/sbin/modprobe overlay (code=exited, status=0/SUCCESS)
   Main PID: 6114 (containerd)
      Tasks: 7
     Memory: 14.2M (peak: 18.1M)
        CPU: 271ms
     CGroup: /system.slice/containerd.service
             └─6114 /usr/bin/containerd

May 30 12:30:43 kubnet-cp-01.unidev.org.np containerd[6114]: time="2026-05-30T12:30:43.007111972+05:45" level=info msg="Start event monitor"
May 30 12:30:43 kubnet-cp-01.unidev.org.np containerd[6114]: time="2026-05-30T12:30:43.007159855+05:45" level=info msg="Start cni network conf syncer for default"
May 30 12:30:43 kubnet-cp-01.unidev.org.np containerd[6114]: time="2026-05-30T12:30:43.007192942+05:45" level=info msg="Start streaming server"
May 30 12:30:43 kubnet-cp-01.unidev.org.np containerd[6114]: time="2026-05-30T12:30:43.007257601+05:45" level=info msg="Registered namespace \"k8s.io\" with NRI"
May 30 12:30:43 kubnet-cp-01.unidev.org.np containerd[6114]: time="2026-05-30T12:30:43.007297367+05:45" level=info msg="runtime interface starting up..."
May 30 12:30:43 kubnet-cp-01.unidev.org.np containerd[6114]: time="2026-05-30T12:30:43.007337965+05:45" level=info msg="starting plugins..."
May 30 12:30:43 kubnet-cp-01.unidev.org.np containerd[6114]: time="2026-05-30T12:30:43.007475570+05:45" level=info msg="Synchronizing NRI (plugin) with current runtime state"
May 30 12:30:43 kubnet-cp-01.unidev.org.np containerd[6114]: time="2026-05-30T12:30:43.007261880+05:45" level=info msg=serving... address=/run/containerd/containerd.sock
May 30 12:30:43 kubnet-cp-01.unidev.org.np containerd[6114]: time="2026-05-30T12:30:43.009359514+05:45" level=info msg="containerd successfully booted in 0.113480s"
May 30 12:30:43 kubnet-cp-01.unidev.org.np systemd[1]: Started containerd.service - containerd container runtime.
*/

--Step 3
root@kubnet-cp-01:~# which kubeadm
/*
/usr/bin/kubeadm
*/

--Step 3.1
root@kubnet-cp-01:~# which kubelet
/*
/usr/bin/kubelet
*/

--Step 3.2
root@kubnet-cp-01:~# which kubectl
/*
/usr/bin/kubectl
*/

--Step 4
root@kubnet-cp-01:~# kubeadm version -o short
/*
v1.36.0
*/

--Step 4.1
root@kubnet-cp-01:~# kubeadm version
/*
kubeadm version: &version.Info{Major:"1", Minor:"36", EmulationMajor:"", EmulationMinor:"", MinCompatibilityMajor:"", MinCompatibilityMinor:"", GitVersion:"v1.36.0", GitCommit:"ecf6decece6a6de25a57aad9ba90b6ce580f6f78", GitTreeState:"clean", BuildDate:"2026-04-22T13:54:03Z", GoVersion:"go1.26.2", Compiler:"gc", Platform:"linux/amd64"}
*/

--Step 4.2
root@kubnet-cp-01:~# kubectl version
/*
Client Version: v1.36.0
Kustomize Version: v5.8.1
The connection to the server localhost:8080 was refused - did you specify the right host or port?
*/

--Step 4.3
root@kubnet-cp-01:~# kubelet --version
/*
Kubernetes v1.36.0
*/

--Step 5
root@kubnet-cp-01:~# which crictl
/*
/usr/bin/crictl
*/

--Step 5.1
root@kubnet-cp-01:~# apt show kubeadm -a
/*
Package: kubeadm
Version: 1.36.1-1.1
Priority: optional
Section: admin
Maintainer: Kubernetes Authors <dev@kubernetes.io>
Installed-Size: 73.0 MB
Homepage: https://kubernetes.io
Download-Size: 12.6 MB
APT-Sources: https://pkgs.k8s.io/core:/stable:/v1.36/deb  Packages
Description: Command-line utility for administering a Kubernetes cluster
 Command-line utility for administering a Kubernetes cluster.

Package: kubeadm
Version: 1.36.0-1.1
Priority: optional
Section: admin
Maintainer: Kubernetes Authors <dev@kubernetes.io>
Installed-Size: 73.0 MB
Depends: cri-tools (>= 1.30.0)
Homepage: https://kubernetes.io
Download-Size: 12.5 MB
APT-Manual-Installed: yes
APT-Sources: https://pkgs.k8s.io/core:/stable:/v1.36/deb  Packages
Description: Command-line utility for administering a Kubernetes cluster
 Command-line utility for administering a Kubernetes cluster.
*/

--Step 6
root@kubnet-cp-01:~# apt-cache madison kubeadm
/*
   kubeadm | 1.36.1-1.1 | https://pkgs.k8s.io/core:/stable:/v1.36/deb  Packages
   kubeadm | 1.36.0-1.1 | https://pkgs.k8s.io/core:/stable:/v1.36/deb  Packages
*/

--Step 6.1
root@kubnet-cp-01:~# apt-cache madison kubeadm | head -2
/*
   kubeadm | 1.36.1-1.1 | https://pkgs.k8s.io/core:/stable:/v1.36/deb  Packages
   kubeadm | 1.36.0-1.1 | https://pkgs.k8s.io/core:/stable:/v1.36/deb  Packages
*/

--Step 7
root@kubnet-cp-01:~# hostname -I
/*
192.1.6.33
*/


--Step 8
root@kubnet-wr-01:~# vi prepare-node.sh
/*
#!/usr/bin/env bash
set -euo pipefail

# Usage: prepare-node.sh [k8s-minor-version]
# Example: prepare-node.sh 1.32   (default: 1.32)
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

--Step 8.1
root@kubnet-wr-01:~# chmod -R 775 prepare-node.sh

--Step 8.2
root@kubnet-wr-01:~# ll prepare-node.sh
/*
-rwxrwxr-x 1 root root 3194 May 30 12:08 prepare-node.sh*
*/

--Step 8.3
root@kubnet-wr-01:~# cat prepare-node.sh | grep -i -E "K8S_VERSION=|apt-get install kubeadm="
/*
K8S_VERSION="${1:-1.36}"
apt-get install kubeadm=1.36.0-1.1 kubelet=1.36.0-1.1 kubectl=1.36.0-1.1 -y
*/

--Step 8.4
root@kubnet-wr-01:~# bash ./prepare-node.sh
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
0 upgraded, 0 newly installed, 0 to remove and 18 not upgraded.
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following NEW packages will be installed:
  containerd.io
0 upgraded, 1 newly installed, 0 to remove and 18 not upgraded.
Need to get 23.6 MB of archives.
After this operation, 93.5 MB of additional disk space will be used.
Get:1 https://download.docker.com/linux/ubuntu noble/stable amd64 containerd.io amd64 2.2.4-1                                                                                                ~ubuntu.24.04~noble [23.6 MB]
Fetched 23.6 MB in 2s (15.2 MB/s)
Selecting previously unselected package containerd.io.
(Reading database ... 126415 files and directories currently installed.)
Preparing to unpack .../containerd.io_2.2.4-1~ubuntu.24.04~noble_amd64.deb ...
Unpacking containerd.io (2.2.4-1~ubuntu.24.04~noble) ...
Setting up containerd.io (2.2.4-1~ubuntu.24.04~noble) ...
Created symlink /etc/systemd/system/multi-user.target.wants/containerd.service → /usr/lib/sys                                                                                                temd/system/containerd.service.
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
  cri-tools kubernetes-cni
The following NEW packages will be installed:
  cri-tools kubeadm kubectl kubelet kubernetes-cni
0 upgraded, 5 newly installed, 0 to remove and 18 not upgraded.
Need to get 93.0 MB of archives.
After this operation, 331 MB of additional disk space will be used.
Get:1 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.36/deb                                                                                                  cri-tools 1.36.0-1.1 [16.3 MB]
Get:2 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.36/deb                                                                                                  kubeadm 1.36.0-1.1 [12.5 MB]
Get:3 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.36/deb                                                                                                  kubectl 1.36.0-1.1 [11.8 MB]
Get:4 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.36/deb                                                                                                  kubernetes-cni 1.9.1-1.1 [39.0 MB]
Get:5 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.36/deb                                                                                                  kubelet 1.36.0-1.1 [13.4 MB]
Fetched 93.0 MB in 4s (22.9 MB/s)
Selecting previously unselected package cri-tools.
(Reading database ... 126429 files and directories currently installed.)
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

--Step 9
root@kubnet-wr-01:~# which containerd
/*
/usr/bin/containerd
*/

--Step 9.1
root@kubnet-wr-01:~# containerd --version
/*
containerd containerd.io v2.2.4 193637f7ee8ae5f5aa5248f49e7baa3e6164966e
*/

--Step 9.2
root@kubnet-wr-01:~# systemctl restart containerd.service

--Step 9.3
root@kubnet-wr-01:~# systemctl status containerd.service
/*
● containerd.service - containerd container runtime
     Loaded: loaded (/usr/lib/systemd/system/containerd.service; enabled; preset: enabled)
     Active: active (running) since Sat 2026-05-30 12:49:12 +0545; 5s ago
       Docs: https://containerd.io
    Process: 3501 ExecStartPre=/sbin/modprobe overlay (code=exited, status=0/SUCCESS)
   Main PID: 3503 (containerd)
      Tasks: 8
     Memory: 14.4M (peak: 18.4M)
        CPU: 259ms
     CGroup: /system.slice/containerd.service
             └─3503 /usr/bin/containerd

May 30 12:49:12 kubnet-wr-01.unidev.org.np containerd[3503]: time="2026-05-30T12:49:12.626778761+05:45" level=info msg="Start cni network conf syncer for default"
May 30 12:49:12 kubnet-wr-01.unidev.org.np containerd[3503]: time="2026-05-30T12:49:12.626835988+05:45" level=info msg="Start streaming server"
May 30 12:49:12 kubnet-wr-01.unidev.org.np containerd[3503]: time="2026-05-30T12:49:12.626902584+05:45" level=info msg="Registered namespace \"k8s.io\" with NRI"
May 30 12:49:12 kubnet-wr-01.unidev.org.np containerd[3503]: time="2026-05-30T12:49:12.626938814+05:45" level=info msg="runtime interface starting up..."
May 30 12:49:12 kubnet-wr-01.unidev.org.np containerd[3503]: time="2026-05-30T12:49:12.626968068+05:45" level=info msg="starting plugins..."
May 30 12:49:12 kubnet-wr-01.unidev.org.np containerd[3503]: time="2026-05-30T12:49:12.627041953+05:45" level=info msg="Synchronizing NRI (plugin) with current runtime state"
May 30 12:49:12 kubnet-wr-01.unidev.org.np containerd[3503]: time="2026-05-30T12:49:12.627769958+05:45" level=info msg=serving... address=/run/containerd/containerd.sock.ttrpc
May 30 12:49:12 kubnet-wr-01.unidev.org.np containerd[3503]: time="2026-05-30T12:49:12.627956951+05:45" level=info msg=serving... address=/run/containerd/containerd.sock
May 30 12:49:12 kubnet-wr-01.unidev.org.np containerd[3503]: time="2026-05-30T12:49:12.628315270+05:45" level=info msg="containerd successfully booted in 0.097089s"
May 30 12:49:12 kubnet-wr-01.unidev.org.np systemd[1]: Started containerd.service - containerd container runtime.
*/

--Step 10
root@kubnet-wr-01:~# which kubeadm
/*
/usr/bin/kubeadm
*/

--Step 10.1
root@kubnet-wr-01:~# which kubelet
/*
/usr/bin/kubelet
*/

--Step 10.2
root@kubnet-wr-01:~# which kubectl
/*
/usr/bin/kubectl
*/

--Step 11
root@kubnet-wr-01:~# kubeadm version -o short
/*
v1.36.0
*/

--Step 11.1
root@kubnet-wr-01:~# kubeadm version
/*
kubeadm version: &version.Info{Major:"1", Minor:"36", EmulationMajor:"", EmulationMinor:"", MinCompatibilityMajor:"", MinCompatibilityMinor:"", GitVersion:"v1.36.0", GitCommit:"ecf6decece6a6de25a57aad9ba90b6ce580f6f78", GitTreeState:"clean", BuildDate:"2026-04-22T13:54:03Z", GoVersion:"go1.26.2", Compiler:"gc", Platform:"linux/amd64"}*/

--Step 11.2
root@kubnet-wr-01:~# kubectl version
/*
Client Version: v1.36.0
Kustomize Version: v5.8.1
The connection to the server localhost:8080 was refused - did you specify the right host or port?
*/

--Step 11.3
root@kubnet-wr-01:~# kubelet --version
/*
Kubernetes v1.36.0
*/

--Step 12
root@kubnet-wr-01:~# which crictl
/*
/usr/bin/crictl
*/

--Step 12.1
root@kubnet-wr-01:~# apt show kubeadm -a
/*
Package: kubeadm
Version: 1.36.1-1.1
Priority: optional
Section: admin
Maintainer: Kubernetes Authors <dev@kubernetes.io>
Installed-Size: 73.0 MB
Homepage: https://kubernetes.io
Download-Size: 12.6 MB
APT-Sources: https://pkgs.k8s.io/core:/stable:/v1.36/deb  Packages
Description: Command-line utility for administering a Kubernetes cluster
 Command-line utility for administering a Kubernetes cluster.

Package: kubeadm
Version: 1.36.0-1.1
Priority: optional
Section: admin
Maintainer: Kubernetes Authors <dev@kubernetes.io>
Installed-Size: 73.0 MB
Depends: cri-tools (>= 1.30.0)
Homepage: https://kubernetes.io
Download-Size: 12.5 MB
APT-Manual-Installed: yes
APT-Sources: https://pkgs.k8s.io/core:/stable:/v1.36/deb  Packages
Description: Command-line utility for administering a Kubernetes cluster
 Command-line utility for administering a Kubernetes cluster.
*/

--Step 12.2
root@kubnet-wr-01:~# apt-cache madison kubeadm | head -2
/*
   kubeadm | 1.36.1-1.1 | https://pkgs.k8s.io/core:/stable:/v1.36/deb  Packages
   kubeadm | 1.36.0-1.1 | https://pkgs.k8s.io/core:/stable:/v1.36/deb  Packages
*/

--Step 13
root@kubnet-cp-01:~# kubeadm init --control-plane-endpoint kubnet-cp-01.unidev.org.np:6443 --kubernetes-version=v1.36.0 --upload-certs --dry-run
/*
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/tmp/kubeadm-init-dryrun3046281856/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

You can now join any number of control-plane nodes running the following command on each as root:

  kubeadm join kubnet-cp-01.unidev.org.np:6443 --token 9u2xqf.nodhzhcrs10h5k7f \
        --discovery-token-ca-cert-hash sha256:696a3e86247cb69e716dc0c30e2828d420eaa121b88b6f8f75e608c6bb7a67d0 \
        --control-plane --certificate-key a31629dc2485be468629e85aea015d15ed083ad2d45cd42e5a5307638534d965

Please note that the certificate-key gives access to cluster sensitive data, keep it secret!
As a safeguard, uploaded-certs will be deleted in two hours; If necessary, you can use
"kubeadm init phase upload-certs --upload-certs" to reload certs afterward.

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join kubnet-cp-01.unidev.org.np:6443 --token 9u2xqf.nodhzhcrs10h5k7f \
        --discovery-token-ca-cert-hash sha256:696a3e86247cb69e716dc0c30e2828d420eaa121b88b6f8f75e608c6bb7a67d0
*/

--Step 13.1
root@kubnet-cp-01:~# kubeadm init --control-plane-endpoint kubnet-cp-01.unidev.org.np:6443 --kubernetes-version=v1.36.0 --upload-certs
/*
[init] Using Kubernetes version: v1.36.0
[preflight] Running pre-flight checks
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action beforehand using 'kubeadm config images pull'
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local kubnet-cp-01.unidev.org.np] and IPs [10.96.0.1 192.1.6.33]
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "front-proxy-ca" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/ca" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [kubnet-cp-01.unidev.org.np localhost] and IPs [192.1.6.33 127.0.0.1 ::1]
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [kubnet-cp-01.unidev.org.np localhost] and IPs [192.1.6.33 127.0.0.1 ::1]
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
[kubelet-check] The kubelet is healthy after 1.50898098s
[control-plane-check] Waiting for healthy control plane components. This can take up to 4m0s
[control-plane-check] Checking kube-apiserver at https://192.1.6.33:6443/livez
[control-plane-check] Checking kube-controller-manager at https://127.0.0.1:10257/healthz
[control-plane-check] Checking kube-scheduler at https://127.0.0.1:10259/livez
[control-plane-check] kube-controller-manager is healthy after 6.527934276s
[control-plane-check] kube-scheduler is healthy after 12.584850595s
[control-plane-check] kube-apiserver is healthy after 15.503739805s
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config" in namespace kube-system with the configuration for the kubelets in the cluster
[upload-certs] Storing the certificates in Secret "kubeadm-certs" in the "kube-system" Namespace
[upload-certs] Using certificate key:
6a646a025d1776fd18dca41d6a2a68e96e1d95d63fc7fcb2b48f60c91690222d
[mark-control-plane] Marking the node kubnet-cp-01.unidev.org.np as control-plane by adding the labels: [node-role.kubernetes.io/control-plane node.kubernetes.io/exclude-from-external-load-balancers]
[mark-control-plane] Marking the node kubnet-cp-01.unidev.org.np as control-plane by adding the taints [node-role.kubernetes.io/control-plane:NoSchedule]
[bootstrap-token] Using token: 8cotf5.kg2tq15vdf78c2z2
[bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to get nodes
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] Configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] Configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
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

  kubeadm join kubnet-cp-01.unidev.org.np:6443 --token 8cotf5.kg2tq15vdf78c2z2 \
        --discovery-token-ca-cert-hash sha256:41cac6a4c0fa36c7e5df8c73c0845bdb2ce3a055ad921c7dc33951d2286f3ebb \
        --control-plane --certificate-key 6a646a025d1776fd18dca41d6a2a68e96e1d95d63fc7fcb2b48f60c91690222d

Please note that the certificate-key gives access to cluster sensitive data, keep it secret!
As a safeguard, uploaded-certs will be deleted in two hours; If necessary, you can use
"kubeadm init phase upload-certs --upload-certs" to reload certs afterward.

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join kubnet-cp-01.unidev.org.np:6443 --token 8cotf5.kg2tq15vdf78c2z2 \
        --discovery-token-ca-cert-hash sha256:41cac6a4c0fa36c7e5df8c73c0845bdb2ce3a055ad921c7dc33951d2286f3ebb
*/

--Step 13.2
root@kubnet-cp-01:~# mkdir -p $HOME/.kube

--Step 13.3
root@kubnet-cp-01:~# sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

--Step 13.4
root@kubnet-cp-01:~# sudo chown $(id -u):$(id -g) $HOME/.kube/config

--Step 14
root@kubnet-cp-01:~# vi cilium_pkg.sh
/*
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
*/

--Step 14.1
root@kubnet-cp-01:~# chmod -R 775 cilium_pkg.sh

--Step 14.2
root@kubnet-cp-01:~# ll cilium_pkg.sh
/*
-rwxrwxr-x 1 root root 497 May 30 13:03 cilium_pkg.sh*
*/

--Step 14.3
root@kubnet-cp-01:~# bash ./cilium_pkg.sh
/*
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100 67.1M  100 67.1M    0     0  15.6M      0  0:00:04  0:00:04 --:--:-- 21.6M
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100    92  100    92    0     0    126      0 --:--:-- --:--:-- --:--:--   126
cilium-linux-amd64.tar.gz: OK
cilium
*/

--Step 14.4
root@kubnet-cp-01:~# which cilium
/*
/usr/local/bin/cilium
*/

--Step 14.5
root@kubnet-cp-01:~# cilium install --version 1.19.4
/*
ℹ️  Using Cilium version 1.19.4
🔮 Auto-detected cluster name: kubernetes
🔮 Auto-detected kube-proxy has been installed
*/

--Step 14.6
root@kubnet-cp-01:~# cilium status
/*
    /¯¯\
 /¯¯\__/¯¯\    Cilium:             OK
 \__/¯¯\__/    Operator:           OK
 /¯¯\__/¯¯\    Envoy DaemonSet:    OK
 \__/¯¯\__/    Hubble Relay:       disabled
    \__/       ClusterMesh:        disabled

DaemonSet              cilium                   Desired: 2, Ready: 2/2, Available: 2/2
DaemonSet              cilium-envoy             Desired: 2, Ready: 2/2, Available: 2/2
Deployment             cilium-operator          Desired: 1, Ready: 1/1, Available: 1/1
Containers:            cilium                   Running: 2
                       cilium-envoy             Running: 2
                       cilium-operator          Running: 1
                       clustermesh-apiserver
                       hubble-relay
Cluster Pods:          2/2 managed by Cilium
Helm chart version:    1.19.4
Image versions         cilium             quay.io/cilium/cilium:v1.19.4@sha256:2eb67991eaa9368ba199c2fac2c573cb0ffdeb79184533344f42fc9a7ff6af3c: 2
                       cilium-envoy       quay.io/cilium/cilium-envoy:v1.36.6-1778235340-b87d1e32f522b33bd51701c6476d199326f01496@sha256:71d4fa0ec45e8d546dbd5604e169dc77fe92be63b799313bff031d00d89762e3: 2
                       cilium-operator    quay.io/cilium/operator-generic:v1.19.4@sha256:1aa2b62735e7d8ab49ee840ae59c346932024c88901579121395c1271b435f71: 1
*/

--Step 15
root@kubnet-cp-01:~# kubectl get nodes -o wide
/*
NAME                           STATUS     ROLES           AGE     VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION              CONTAINER-RUNTIME
kubnet-lab-1.unidev.org.np   NotReady   control-plane   5m43s   v1.36.0   192.1.6.33   <none>        Ubuntu 24.04.4 LTS   6.8.0-111-generic (amd64)   containerd://2.2.3
*/

-- Few Moment After
--Step 15.1
root@kubnet-cp-01:~# kubectl get nodes -o wide
/*
NAME                           STATUS   ROLES           AGE     VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION              CONTAINER-RUNTIME
kubnet-lab-1.unidev.org.np   Ready    control-plane   7m32s   v1.36.0   192.1.6.33   <none>        Ubuntu 24.04.4 LTS   6.8.0-111-generic (amd64)   containerd://2.2.3
*/

--Step 16
root@kubnet-cp-01:~# kubeadm version -o short
/*
v1.36.0
*/

--Step 16.1
root@kubnet-cp-01:~# kubeadm version
/*
kubeadm version: &version.Info{Major:"1", Minor:"36", EmulationMajor:"", EmulationMinor:"", MinCompatibilityMajor:"", MinCompatibilityMinor:"", GitVersion:"v1.36.0", GitCommit:"ecf6decece6a6de25a57aad9ba90b6ce580f6f78", GitTreeState:"clean", BuildDate:"2026-04-22T13:54:03Z", GoVersion:"go1.26.2", Compiler:"gc", Platform:"linux/amd64"}
*/

--Step 16.2
root@kubnet-cp-01:~# kubelet --version
/*
Kubernetes v1.36.0
*/

--Step 16.3
root@kubnet-cp-01:~# kubectl version
/*
Client Version: v1.36.0
Kustomize Version: v5.8.1
Server Version: v1.36.0
*/

--Step 17
root@kubnet-wr-01:~# kubeadm join kubnet-cp-01.unidev.org.np:6443 --token 8cotf5.kg2tq15vdf78c2z2 \
        --discovery-token-ca-cert-hash sha256:41cac6a4c0fa36c7e5df8c73c0845bdb2ce3a055ad921c7dc33951d2286f3ebb --dry-run
/*
nodeStatusReportFrequency: 0s
nodeStatusUpdateFrequency: 0s
resolvConf: /run/systemd/resolve/resolv.conf
rotateCertificates: true
runtimeRequestTimeout: 0s
shutdownGracePeriod: 0s
shutdownGracePeriodCriticalPods: 0s
staticPodPath: /etc/kubernetes/manifests
streamingConnectionIdleTimeout: 0s
syncFrequency: 0s
volumeStatsAggPeriod: 0s
[dryrun] Would write file "/var/lib/kubelet/kubeadm-flags.env" with content:
KUBELET_KUBEADM_ARGS=""
[kubelet-wait] Would wait for the kubelet to be bootstrapped

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.
*/


--Step 17.1
root@kubnet-wr-01:~# kubeadm join kubnet-cp-01.unidev.org.np:6443 --token 8cotf5.kg2tq15vdf78c2z2 \
        --discovery-token-ca-cert-hash sha256:41cac6a4c0fa36c7e5df8c73c0845bdb2ce3a055ad921c7dc33951d2286f3ebb
/*
[preflight] Running pre-flight checks
[preflight] Reading configuration from the "kubeadm-config" ConfigMap in namespace "kube-system"...
[preflight] Use 'kubeadm init phase upload-config kubeadm --config your-config-file' to re-upload it.
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/instance-config.yaml"
[patches] Applied patch of type "application/strategic-merge-patch+json" to target "kubeletconfiguration"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Starting the kubelet
[kubelet-check] Waiting for a healthy kubelet at http://127.0.0.1:10248/healthz. This can take up to 4m0s
[kubelet-check] The kubelet is healthy after 1.002765866s
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.
*/

--Step 18
root@kubnet-wr-01:~# vi cilium_pkg.sh
/*
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
*/

--Step 18.1
root@kubnet-wr-01:~# chmod -R 775 cilium_pkg.sh

--Step 18.2
root@kubnet-wr-01:~# ll cilium_pkg.sh
/*
-rwxrwxr-x 1 root root 497 May 30 13:11 cilium_pkg.sh*
*/

--Step 18.3
root@kubnet-wr-01:~# bash ./cilium_pkg.sh
/*
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100 67.1M  100 67.1M    0     0  21.6M      0  0:00:03  0:00:03 --:--:-- 30.9M
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100    92  100    92    0     0    210      0 --:--:-- --:--:-- --:--:--   210
cilium-linux-amd64.tar.gz: OK
cilium
*/

--Step 18.4
root@kubnet-wr-01:~# which cilium
/*
/usr/local/bin/cilium
*/

--Step 18.5 (Issue Seen On Worker Node to run the Cilium)
root@kubnet-wr-01:~# cilium status
/*
    /¯¯\
 /¯¯\__/¯¯\    Cilium:             1 errors
 \__/¯¯\__/    Operator:           1 errors
 /¯¯\__/¯¯\    Envoy DaemonSet:    1 errors
 \__/¯¯\__/    Hubble Relay:       1 warnings
    \__/       ClusterMesh:        1 warnings

Cluster Pods:          0/0 managed by Cilium
Helm chart version:
Errors:                cilium                   cilium                   Get "http://localhost:8080/apis/apps/v1/namespaces/kube-system/daemonsets/cilium": dial tcp 127.0.0.1:8080: connect: connection refused
                       cilium-envoy             cilium-envoy             Get "http://localhost:8080/apis/apps/v1/namespaces/kube-system/daemonsets/cilium-envoy": dial tcp 127.0.0.1:8080: connect: connection refused
                       cilium-operator          cilium-operator          Get "http://localhost:8080/apis/apps/v1/namespaces/kube-system/deployments/cilium-operator": dial tcp 127.0.0.1:8080: connect: connection refused
Warnings:              clustermesh-apiserver    clustermesh-apiserver    clustermesh is not deployed
                       hubble-relay             hubble-relay             hubble relay is not deployed
                       hubble-ui                hubble-ui                hubble ui is not deployed
status check failed: [Get "http://localhost:8080/api/v1/namespaces/kube-system/pods?labelSelector=k8s-app%3Dcilium": dial tcp 127.0.0.1:8080: connect: connection refused, Get "http://localhost:8080/api/v1/namespaces/kube-system/pods?labelSelector=io.cilium%2Fapp%3Doperator": dial tcp 127.0.0.1:8080: connect: connection refused, Get "http://localhost:8080/api/v1/namespaces/kube-system/pods?labelSelector=app.kubernetes.io%2Fname%3Dhubble-relay": dial tcp 127.0.0.1:8080: connect: connection refused, Get "http://localhost:8080/api/v1/namespaces/kube-system/pods?labelSelector=k8s-app%3Dclustermesh-apiserver": dial tcp 127.0.0.1:8080: connect: connection refused, Get "http://localhost:8080/apis/apps/v1/namespaces/kube-system/daemonsets/cilium-envoy": dial tcp 127.0.0.1:8080: connect: connection refused, Get "http://localhost:8080/api/v1/namespaces/kube-system/pods?labelSelector=name%3Dcilium-envoy": dial tcp 127.0.0.1:8080: connect: connection refused, Get "http://localhost:8080/apis/apps/v1/namespaces/kube-system/daemonsets/cilium": dial tcp 127.0.0.1:8080: connect: connection refused, Get "http://localhost:8080/apis/apps/v1/namespaces/kube-system/deployments/cilium-operator": dial tcp 127.0.0.1:8080: connect: connection refused, unable to retrieve ConfigMap "cilium-config": Get "http://localhost:8080/api/v1/namespaces/kube-system/configmaps/cilium-config": dial tcp 127.0.0.1:8080: connect: connection refused, Get "http://localhost:8080/api/v1/pods": dial tcp 127.0.0.1:8080: connect: connection refused]
*/

--Step 18.5.1 (Issue Fixed On Worker Node to run the Cilium)
root@kubnet-cp-01:~# ll /etc/kubernetes/admin.conf
/*
-rw------- 1 root root 5656 May 30 12:59 /etc/kubernetes/admin.conf
*/

--Step 18.5.2 (Issue Fixed On Worker Node to run the Cilium)
root@kubnet-cp-01:~# scp /etc/kubernetes/admin.conf lab@kubnet-wr-01:/home/lab/admin.conf
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
lab@kubnet-wr-01's password:
admin.conf                                                 100% 5656     2.4MB/s   00:00
*/

--Step 18.5.3 (Issue Fixed On Worker Node to run the Cilium)
root@kubnet-wr-01:~# sudo mv /home/lab/admin.conf /root/admin.conf

--Step 18.5.4 (Issue Fixed On Worker Node to run the Cilium)
root@kubnet-wr-01:~# ll /root/admin.conf
/*
-rw------- 1 lab lab 5656 May 30 13:55 /root/admin.conf
*/

--Step 18.5.5 (Issue Fixed On Worker Node to run the Cilium)
root@kubnet-wr-01:~# export KUBECONFIG=/root/admin.conf

--Step 18.5.5.1 - Make It Permanent (Issue Fixed On Worker Node to run the Cilium)
root@kubnet-wr-01:~# echo 'export KUBECONFIG=/root/admin.conf' >> ~/.bashrc

--Step 19
root@kubnet-wr-01:~# cilium status
/*
    /¯¯\
 /¯¯\__/¯¯\    Cilium:             OK
 \__/¯¯\__/    Operator:           OK
 /¯¯\__/¯¯\    Envoy DaemonSet:    OK
 \__/¯¯\__/    Hubble Relay:       disabled
    \__/       ClusterMesh:        disabled

DaemonSet              cilium                   Desired: 2, Ready: 2/2, Available: 2/2
DaemonSet              cilium-envoy             Desired: 2, Ready: 2/2, Available: 2/2
Deployment             cilium-operator          Desired: 1, Ready: 1/1, Available: 1/1
Containers:            cilium                   Running: 2
                       cilium-envoy             Running: 2
                       cilium-operator          Running: 1
                       clustermesh-apiserver
                       hubble-relay
Cluster Pods:          2/2 managed by Cilium
Helm chart version:    1.19.4
Image versions         cilium             quay.io/cilium/cilium:v1.19.4@sha256:2eb67991eaa9368ba199c2fac2c573cb0ffdeb79184533344f42fc9a7ff6af3c: 2
                       cilium-envoy       quay.io/cilium/cilium-envoy:v1.36.6-1778235340-b87d1e32f522b33bd51701c6476d199326f01496@sha256:71d4fa0ec45e8d546dbd5604e169dc77fe92be63b799313bff031d00d89762e3: 2
                       cilium-operator    quay.io/cilium/operator-generic:v1.19.4@sha256:1aa2b62735e7d8ab49ee840ae59c346932024c88901579121395c1271b435f71: 1
*/

--Step 19.1
root@kubnet-wr-01:~# kubectl get nodes
/*
NAME                           STATUS   ROLES           AGE   VERSION
kubnet-cp-01.unidev.org.np   Ready    control-plane   61m   v1.36.0
kubnet-wr-01.unidev.org.np   Ready    <none>          52m   v1.36.0
*/

--Step 19.2
root@kubnet-wr-01:~# kubectl get nodes -o wide
/*
NAME                           STATUS   ROLES           AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION              CONTAINER-RUNTIME
kubnet-cp-01.unidev.org.np   Ready    control-plane   61m   v1.36.0   192.1.6.33   <none>        Ubuntu 24.04.4 LTS   6.8.0-111-generic (amd64)   containerd://2.2.4
kubnet-wr-01.unidev.org.np   Ready    <none>          52m   v1.36.0   192.1.6.34   <none>        Ubuntu 24.04.4 LTS   6.8.0-111-generic (amd64)   containerd://2.2.4
*/

--Step 19.3
root@kubnet-wr-01:~# kubectl get pods -A
/*
NAMESPACE     NAME                                                   READY   STATUS    RESTARTS   AGE
kube-system   cilium-7rtdt                                           1/1     Running   0          52m
kube-system   cilium-envoy-gmz9l                                     1/1     Running   0          52m
kube-system   cilium-envoy-k2r8f                                     1/1     Running   0          56m
kube-system   cilium-operator-bbdd9c45f-rd9nv                        1/1     Running   0          56m
kube-system   cilium-trdms                                           1/1     Running   0          56m
kube-system   coredns-589f44dc88-mfp9r                               1/1     Running   0          61m
kube-system   coredns-589f44dc88-pfbpf                               1/1     Running   0          61m
kube-system   etcd-kubnet-cp-01.unidev.org.np                      1/1     Running   0          61m
kube-system   kube-apiserver-kubnet-cp-01.unidev.org.np            1/1     Running   0          61m
kube-system   kube-controller-manager-kubnet-cp-01.unidev.org.np   1/1     Running   0          61m
kube-system   kube-proxy-n96t2                                       1/1     Running   0          61m
kube-system   kube-proxy-v72qq                                       1/1     Running   0          52m
kube-system   kube-scheduler-kubnet-cp-01.unidev.org.np            1/1     Running   0          61m
*/

--Step 20
root@kubnet-wr-01:~# kubeadm version -o short
/*
v1.36.0
*/

--Step 20.1
root@kubnet-wr-01:~# kubeadm version
/*
kubeadm version: &version.Info{Major:"1", Minor:"36", EmulationMajor:"", EmulationMinor:"", MinCompatibilityMajor:"", MinCompatibilityMinor:"", GitVersion:"v1.36.0", GitCommit:"ecf6decece6a6de25a57aad9ba90b6ce580f6f78", GitTreeState:"clean", BuildDate:"2026-04-22T13:54:03Z", GoVersion:"go1.26.2", Compiler:"gc", Platform:"linux/amd64"}
*/

--Step 20.2
root@kubnet-wr-01:~# kubectl version
/*
Client Version: v1.36.0
Kustomize Version: v5.8.1
Server Version: v1.36.0
*/

--Step 20.3
root@kubnet-wr-01:~# kubelet --version
/*
Kubernetes v1.36.0
*/

--Go to https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/
--Now to Upgrade The Kubernets Version 
--Step 21
root@kubnet-cp-01:~# apt update
/*
root@kubnet-cp-01:~# apt update
Hit:1 https://download.docker.com/linux/ubuntu noble InRelease
Get:2 http://security.ubuntu.com/ubuntu noble-security InRelease [126 kB]
Hit:3 http://archive.ubuntu.com/ubuntu noble InRelease
Get:4 http://archive.ubuntu.com/ubuntu noble-updates InRelease [126 kB]
Get:5 http://security.ubuntu.com/ubuntu noble-security/main amd64 Components [42.4 kB]
Get:6 http://security.ubuntu.com/ubuntu noble-security/universe amd64 Components [74.2 kB]
Hit:7 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.36/deb  InRelease
Get:8 http://archive.ubuntu.com/ubuntu noble-backports InRelease [126 kB]
Get:9 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 Components [178 kB]
Get:10 http://archive.ubuntu.com/ubuntu noble-updates/universe amd64 Components [386 kB]
Get:11 http://archive.ubuntu.com/ubuntu noble-updates/multiverse amd64 Components [940 B]
Get:12 http://archive.ubuntu.com/ubuntu noble-backports/main amd64 Components [5,736 B]
Get:13 http://archive.ubuntu.com/ubuntu noble-backports/universe amd64 Components [10.5 kB]
Fetched 1,076 kB in 3s (329 kB/s)
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
21 packages can be upgraded. Run 'apt list --upgradable' to see them.
*/

--Step 21.1
root@kubnet-cp-01:~# apt-cache madison kubeadm
/*
   kubeadm | 1.36.1-1.1 | https://pkgs.k8s.io/core:/stable:/v1.36/deb  Packages
   kubeadm | 1.36.0-1.1 | https://pkgs.k8s.io/core:/stable:/v1.36/deb  Packages
*/

--Step 21.2
root@kubnet-cp-01:~# apt-cache madison kubeadm | head -2
/*
   kubeadm | 1.36.1-1.1 | https://pkgs.k8s.io/core:/stable:/v1.36/deb  Packages
   kubeadm | 1.36.0-1.1 | https://pkgs.k8s.io/core:/stable:/v1.36/deb  Packages
*/

--Step 21.3
root@kubnet-cp-01:~# apt-mark unhold kubeadm
/*
Canceled hold on kubeadm.
*/

--Step 21.4
root@kubnet-cp-01:~# apt-mark unhold kubeadm
/*
kubeadm was already not on hold.
*/


--Step 21.5
root@kubnet-cp-01:~# apt-get update && apt-get install kubeadm=1.36.1-1.1 -y
/*
Hit:1 https://download.docker.com/linux/ubuntu noble InRelease
Hit:2 http://security.ubuntu.com/ubuntu noble-security InRelease
Hit:4 http://archive.ubuntu.com/ubuntu noble InRelease
Hit:5 http://archive.ubuntu.com/ubuntu noble-updates InRelease
Hit:3 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.36/deb                                                                                                  InRelease
Hit:6 http://archive.ubuntu.com/ubuntu noble-backports InRelease
Reading package lists... Done
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following package was automatically installed and is no longer required:
  cri-tools
Use 'apt autoremove' to remove it.
The following packages will be upgraded:
  kubeadm
1 upgraded, 0 newly installed, 0 to remove and 20 not upgraded.
Need to get 12.6 MB of archives.
After this operation, 8,192 B of additional disk space will be used.
Get:1 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.36/deb  kubeadm 1.36.1-1.1 [12.6 MB]
Fetched 12.6 MB in 2s (5,821 kB/s)
(Reading database ... 126483 files and directories currently installed.)
Preparing to unpack .../kubeadm_1.36.1-1.1_amd64.deb ...
Unpacking kubeadm (1.36.1-1.1) over (1.36.0-1.1) ...
Setting up kubeadm (1.36.1-1.1) ...
Scanning processes...
Scanning linux images...

Running kernel seems to be up-to-date.

No services need to be restarted.

No containers need to be restarted.

No user sessions are running outdated binaries.

No VM guests are running outdated hypervisor (qemu) binaries on this host.
*/

--Step 21.6
root@kubnet-cp-01:~# apt-mark hold kubeadm
/*
kubeadm set on hold.
*/

--Step 21.7
root@kubnet-cp-01:~# apt-mark hold kubeadm
/*
kubeadm was already set on hold.
*/

--Step 21.8
root@kubnet-cp-01:~# kubeadm version
/*
kubeadm version: &version.Info{Major:"1", Minor:"36", EmulationMajor:"", EmulationMinor:"", MinCompatibilityMajor:"", MinCompatibilityMinor:"", GitVersion:"v1.36.1", GitCommit:"756939600b9a7180fc2df6550a4585b638875e67", GitTreeState:"clean", BuildDate:"2026-05-12T09:53:52Z", GoVersion:"go1.26.2", Compiler:"gc", Platform:"linux/amd64"}
*/

--Step 21.9
root@kubnet-cp-01:~# kubeadm version -o short
/*
v1.36.1
*/

--Verify the upgrade plan
--Step 21.10
root@kubnet-cp-01:~# kubeadm upgrade plan
/*
[preflight] Running pre-flight checks.
[upgrade/config] Reading configuration from the "kubeadm-config" ConfigMap in namespace "kube-system"...
[upgrade/config] Use 'kubeadm init phase upload-config kubeadm --config your-config-file' to re-upload it.
[upgrade] Running cluster health checks
[upgrade] Fetching available versions to upgrade to
[upgrade/versions] Cluster version: 1.36.0
[upgrade/versions] kubeadm version: v1.36.1
[upgrade/versions] Target version: v1.36.1
[upgrade/versions] Latest version in the v1.36 series: v1.36.1

Components that must be upgraded manually after you have upgraded the control plane with 'kubeadm upgrade apply':
COMPONENT   NODE                           CURRENT   TARGET
kubelet     kubnet-cp-01.unidev.org.np   v1.36.0   v1.36.1
kubelet     kubnet-wr-01.unidev.org.np   v1.36.0   v1.36.1

Upgrade to the latest version in the v1.36 series:

COMPONENT                 NODE                           CURRENT   TARGET
kube-apiserver            kubnet-cp-01.unidev.org.np   v1.36.0   v1.36.1
kube-controller-manager   kubnet-cp-01.unidev.org.np   v1.36.0   v1.36.1
kube-scheduler            kubnet-cp-01.unidev.org.np   v1.36.0   v1.36.1
kube-proxy                                               1.36.0    v1.36.1
CoreDNS                                                  v1.14.2   v1.14.2
etcd                      kubnet-cp-01.unidev.org.np   3.6.8-0   3.6.8-0

You can now apply the upgrade by executing the following command:

        kubeadm upgrade apply v1.36.1

_____________________________________________________________________


The table below shows the current state of component configs as understood by this version of kubeadm.
Configs that have a "yes" mark in the "MANUAL UPGRADE REQUIRED" column require manual config upgrade or
resetting to kubeadm defaults before a successful upgrade can be performed. The version to manually
upgrade to is denoted in the "PREFERRED VERSION" column.

API GROUP                 CURRENT VERSION   PREFERRED VERSION   MANUAL UPGRADE REQUIRED
kubeproxy.config.k8s.io   v1alpha1          v1alpha1            no
kubelet.config.k8s.io     v1beta1           v1beta1             no
_____________________________________________________________________
*/

--Choose a version to upgrade to, and run the appropriate command.
--Step 21.11
root@kubnet-cp-01:~# kubeadm upgrade apply v1.36.1
/*
[upgrade] Reading configuration from the "kubeadm-config" ConfigMap in namespace "kube-system"...
[upgrade] Use 'kubeadm init phase upload-config kubeadm --config your-config-file' to re-upload it.
[upgrade/preflight] Running preflight checks
[upgrade] Running cluster health checks
[upgrade/preflight] You have chosen to upgrade the cluster version to "v1.36.1"
[upgrade/versions] Cluster version: v1.36.0
[upgrade/versions] kubeadm version: v1.36.1
[upgrade] Are you sure you want to proceed? [y/N]: y
[upgrade/preflight] Pulling images required for setting up a Kubernetes cluster
[upgrade/preflight] This might take a minute or two, depending on the speed of your internet connection
[upgrade/preflight] You can also perform this action beforehand using 'kubeadm config images pull'
[upgrade/control-plane] Upgrading your static Pod-hosted control plane to version "v1.36.1" (timeout: 5m0s)...
[upgrade/staticpods] Writing new Static Pod manifests to "/etc/kubernetes/tmp/kubeadm-upgraded-manifests100892442"
[upgrade/staticpods] Preparing for "etcd" upgrade
[upgrade/staticpods] Renewing etcd-server certificate
[upgrade/staticpods] Renewing etcd-peer certificate
[upgrade/staticpods] Renewing etcd-healthcheck-client certificate
[upgrade/staticpods] Restarting the etcd static pod and backing up its manifest to "/etc/kubernetes/tmp/kubeadm-backup-manifests-2026-05-30-14-29-18/etcd.yaml"
[upgrade/staticpods] Waiting for the kubelet to restart the component
[upgrade/staticpods] This can take up to 5m0s
[apiclient] Found 1 Pods for label selector component=etcd
[upgrade/staticpods] Component "etcd" upgraded successfully!
[upgrade/etcd] Waiting for etcd to become available
[upgrade/staticpods] Preparing for "kube-apiserver" upgrade
[upgrade/staticpods] Renewing apiserver certificate
[upgrade/staticpods] Renewing apiserver-kubelet-client certificate
[upgrade/staticpods] Renewing front-proxy-client certificate
[upgrade/staticpods] Renewing apiserver-etcd-client certificate
[upgrade/staticpods] Moving new manifest to "/etc/kubernetes/manifests/kube-apiserver.yaml" and backing up old manifest to "/etc/kubernetes/tmp/kubeadm-backup-manifests-2026-05-30-14-29-18/kube-apiserver.yaml"
[upgrade/staticpods] Waiting for the kubelet to restart the component
[upgrade/staticpods] This can take up to 5m0s
[apiclient] Found 1 Pods for label selector component=kube-apiserver
[upgrade/staticpods] Component "kube-apiserver" upgraded successfully!
[upgrade/staticpods] Preparing for "kube-controller-manager" upgrade
[upgrade/staticpods] Renewing controller-manager.conf certificate
[upgrade/staticpods] Moving new manifest to "/etc/kubernetes/manifests/kube-controller-manager.yaml" and backing up old manifest to "/etc/kubernetes/tmp/kubeadm-backup-manifests-2026-05-30-14-29-18/kube-controller-manager.yaml"
[upgrade/staticpods] Waiting for the kubelet to restart the component
[upgrade/staticpods] This can take up to 5m0s
[apiclient] Found 1 Pods for label selector component=kube-controller-manager
[upgrade/staticpods] Component "kube-controller-manager" upgraded successfully!
[upgrade/staticpods] Preparing for "kube-scheduler" upgrade
[upgrade/staticpods] Renewing scheduler.conf certificate
[upgrade/staticpods] Moving new manifest to "/etc/kubernetes/manifests/kube-scheduler.yaml" and backing up old manifest to "/etc/kubernetes/tmp/kubeadm-backup-manifests-2026-05-30-14-29-18/kube-scheduler.yaml"
[upgrade/staticpods] Waiting for the kubelet to restart the component
[upgrade/staticpods] This can take up to 5m0s
[apiclient] Found 1 Pods for label selector component=kube-scheduler
[upgrade/staticpods] Component "kube-scheduler" upgraded successfully!
[upgrade/control-plane] The control plane instance for this node was successfully upgraded!
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config" in namespace kube-system with the configuration for the kubelets in the cluster
[upgrade/kubeconfig] The kubeconfig files for this node were successfully upgraded!
W0530 14:31:13.396660   11986 postupgrade.go:105] Using temporary directory /etc/kubernetes/tmp/kubeadm-kubelet-config-2026-05-30-14-31-13 for kubelet config. To override it set the environment variable KUBEADM_UPGRADE_DRYRUN_DIR
[upgrade] Backing up kubelet config file to /etc/kubernetes/tmp/kubeadm-kubelet-config-2026-05-30-14-31-13/config.yaml
[patches] Applied patch of type "application/strategic-merge-patch+json" to target "kubeletconfiguration"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[upgrade/kubelet-config] The kubelet configuration for this node was successfully upgraded!
[upgrade/bootstrap-token] Configuring bootstrap token and cluster-info RBAC rules
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to get nodes
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] Configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] Configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstrap-token] Configured RBAC rules to allow the API server kubelet client certificate to access the kubelet API
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

[upgrade] SUCCESS! A control plane node of your cluster was upgraded to "v1.36.1".

[upgrade] Now please proceed with upgrading the rest of the nodes by following the right order.
*/

--Step 21.12
root@kubnet-cp-01:~# kubeadm version -o short
/*
v1.36.1
*/

--Step 21.13
root@kubnet-cp-01:~# kubelet --version
/*
Kubernetes v1.36.0
*/

--Step 21.14
root@kubnet-cp-01:~# kubectl version
/*
Client Version: v1.36.0
Kustomize Version: v5.8.1
Server Version: v1.36.1
*/

--Step 21.15
root@kubnet-cp-01:~# apt-mark unhold kubelet kubectl
/*
Canceled hold on kubelet.
Canceled hold on kubectl.
*/

--Step 21.16
root@kubnet-cp-01:~# apt-mark unhold kubelet kubectl
/*
kubelet was already not on hold.
kubectl was already not on hold.
*/


--Step 21.17
root@kubnet-cp-01:~# apt-get update && apt install kubelet=1.36.1-1.1 kubectl=1.36.1-1.1 -y
/*
Hit:1 https://download.docker.com/linux/ubuntu noble InRelease
Hit:2 http://security.ubuntu.com/ubuntu noble-security InRelease
Hit:4 http://archive.ubuntu.com/ubuntu noble InRelease
Hit:5 http://archive.ubuntu.com/ubuntu noble-updates InRelease
Hit:3 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.36/deb  InRelease
Hit:6 http://archive.ubuntu.com/ubuntu noble-backports InRelease
Reading package lists... Done
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following package was automatically installed and is no longer required:
  cri-tools
Use 'apt autoremove' to remove it.
The following packages will be upgraded:
  kubectl kubelet
2 upgraded, 0 newly installed, 0 to remove and 18 not upgraded.
Need to get 25.1 MB of archives.
After this operation, 16.4 kB of additional disk space will be used.
Get:1 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.36/deb  kubectl 1.36.1-1.1 [11.8 MB]
Get:2 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.36/deb  kubelet 1.36.1-1.1 [13.4 MB]
Fetched 25.1 MB in 4s (6,000 kB/s)
(Reading database ... 126483 files and directories currently installed.)
Preparing to unpack .../kubectl_1.36.1-1.1_amd64.deb ...
Unpacking kubectl (1.36.1-1.1) over (1.36.0-1.1) ...
Preparing to unpack .../kubelet_1.36.1-1.1_amd64.deb ...
Unpacking kubelet (1.36.1-1.1) over (1.36.0-1.1) ...
Setting up kubectl (1.36.1-1.1) ...
Setting up kubelet (1.36.1-1.1) ...
Scanning processes...
Scanning candidates...
Scanning linux images...

Running kernel seems to be up-to-date.

Restarting services...
 systemctl restart kubelet.service

No containers need to be restarted.

No user sessions are running outdated binaries.

No VM guests are running outdated hypervisor (qemu) binaries on this host.
*/

--Step 21.18
root@kubnet-cp-01:~# apt-mark hold kubelet kubectl
/*
kubelet set on hold.
kubectl set on hold.
*/

--Step 21.19
root@kubnet-cp-01:~# apt-mark hold kubelet kubectl
/*
kubelet was already set on hold.
kubectl was already set on hold.
*/

--Step 21.20
root@kubnet-cp-01:~# systemctl daemon-reload

--Step 21.21
root@kubnet-cp-01:~# systemctl restart kubelet

--Step 21.22
root@kubnet-cp-01:~# systemctl status kubelet
/*
● kubelet.service - kubelet: The Kubernetes Node Agent
     Loaded: loaded (/usr/lib/systemd/system/kubelet.service; enabled; preset: enabled)
    Drop-In: /usr/lib/systemd/system/kubelet.service.d
             └─10-kubeadm.conf
     Active: active (running) since Fri 2026-05-15 17:05:38 +0545; 1s ago
       Docs: https://kubernetes.io/docs/
   Main PID: 9075 (kubelet)
      Tasks: 12 (limit: 5746)
     Memory: 25.8M (peak: 26.3M)
        CPU: 1.547s
     CGroup: /system.slice/kubelet.service
             └─9075 /usr/bin/kubelet --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf --config=/var/lib/kubelet/config.yaml

May 15 17:05:39 kubnet-lab-1.unidev.org.np kubelet[9075]: I0515 17:05:39.628290    9075 reconciler_common.go:251] "operationExecutor.VerifyControllerAttachedVolume started for volume \"b>
May 15 17:05:39 kubnet-lab-1.unidev.org.np kubelet[9075]: I0515 17:05:39.628373    9075 reconciler_common.go:251] "operationExecutor.VerifyControllerAttachedVolume started for volume \"e>
May 15 17:05:39 kubnet-lab-1.unidev.org.np kubelet[9075]: I0515 17:05:39.628463    9075 reconciler_common.go:251] "operationExecutor.VerifyControllerAttachedVolume started for volume \"e>
May 15 17:05:39 kubnet-lab-1.unidev.org.np kubelet[9075]: I0515 17:05:39.628602    9075 reconciler_common.go:251] "operationExecutor.VerifyControllerAttachedVolume started for volume \"c>
May 15 17:05:39 kubnet-lab-1.unidev.org.np kubelet[9075]: I0515 17:05:39.630835    9075 reconciler_common.go:251] "operationExecutor.VerifyControllerAttachedVolume started for volume \"u>
May 15 17:05:39 kubnet-lab-1.unidev.org.np kubelet[9075]: I0515 17:05:39.631064    9075 reconciler_common.go:251] "operationExecutor.VerifyControllerAttachedVolume started for volume \"h>
May 15 17:05:39 kubnet-lab-1.unidev.org.np kubelet[9075]: I0515 17:05:39.631147    9075 reconciler_common.go:251] "operationExecutor.VerifyControllerAttachedVolume started for volume \"b>
May 15 17:05:39 kubnet-lab-1.unidev.org.np kubelet[9075]: I0515 17:05:39.633962    9075 reconciler_common.go:251] "operationExecutor.VerifyControllerAttachedVolume started for volume \"x>
May 15 17:05:39 kubnet-lab-1.unidev.org.np kubelet[9075]: I0515 17:05:39.634135    9075 reconciler_common.go:251] "operationExecutor.VerifyControllerAttachedVolume started for volume \"e>
May 15 17:05:39 kubnet-lab-1.unidev.org.np kubelet[9075]: I0515 17:05:39.634276    9075 reconciler_common.go:251] "operationExecutor.VerifyControllerAttachedVolume started for volume \"e>
*/

--Step 21.23
root@kubnet-cp-01:~# kubeadm version -o short
/*
v1.36.1
*/

--Step 21.24
root@kubnet-cp-01:~# kubeadm version
/*
kubeadm version: &version.Info{Major:"1", Minor:"36", EmulationMajor:"", EmulationMinor:"", MinCompatibilityMajor:"", MinCompatibilityMinor:"", GitVersion:"v1.36.1", GitCommit:"756939600b9a7180fc2df6550a4585b638875e67", GitTreeState:"clean", BuildDate:"2026-05-12T09:53:52Z", GoVersion:"go1.26.2", Compiler:"gc", Platform:"linux/amd64"}
*/

--Step 21.25
root@kubnet-cp-01:~# kubelet --version
/*
Kubernetes v1.36.1
*/

--Step 21.26
root@kubnet-cp-01:~# kubectl version
/*
Client Version: v1.36.1
Kustomize Version: v5.8.1
Server Version: v1.36.1
*/

--Step 21.27
root@kubnet-cp-01:~# kubectl get nodes
/*
NAME                           STATUS   ROLES           AGE    VERSION
kubnet-cp-01.unidev.org.np   Ready    control-plane   101m   v1.36.1
kubnet-wr-01.unidev.org.np   Ready    <none>          92m    v1.36.0
*/

--Step 21.28
root@kubnet-cp-01:~# kubectl get nodes -o wide
/*
NAME                           STATUS   ROLES           AGE    VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION              CONTAINER-RUNTIME
kubnet-cp-01.unidev.org.np   Ready    control-plane   101m   v1.36.1   192.1.6.33   <none>        Ubuntu 24.04.4 LTS   6.8.0-111-generic (amd64)   containerd://2.2.4
kubnet-wr-01.unidev.org.np   Ready    <none>          92m    v1.36.0   192.1.6.34   <none>        Ubuntu 24.04.4 LTS   6.8.0-111-generic (amd64)   containerd://2.2.4
*/

--Step 21.29
root@kubnet-cp-01:~# kubectl get pods -A
/*
NAMESPACE     NAME                                                   READY   STATUS    RESTARTS      AGE
kube-system   cilium-7rtdt                                           1/1     Running   0             92m
kube-system   cilium-envoy-gmz9l                                     1/1     Running   0             92m
kube-system   cilium-envoy-k2r8f                                     1/1     Running   0             96m
kube-system   cilium-operator-bbdd9c45f-rd9nv                        1/1     Running   1 (11m ago)   96m
kube-system   cilium-trdms                                           1/1     Running   0             96m
kube-system   coredns-589f44dc88-mfp9r                               1/1     Running   0             101m
kube-system   coredns-589f44dc88-pfbpf                               1/1     Running   0             101m
kube-system   etcd-kubnet-cp-01.unidev.org.np                      1/1     Running   1 (12m ago)   101m
kube-system   kube-apiserver-kubnet-cp-01.unidev.org.np            1/1     Running   0             11m
kube-system   kube-controller-manager-kubnet-cp-01.unidev.org.np   1/1     Running   0             10m
kube-system   kube-proxy-656d6                                       1/1     Running   0             9m59s
kube-system   kube-proxy-clfjh                                       1/1     Running   0             10m
kube-system   kube-scheduler-kubnet-cp-01.unidev.org.np            1/1     Running   0             10m
*/

--Step 21.30
root@kubnet-cp-01:~# crictl ps
/*
CONTAINER           IMAGE               CREATED             STATE               NAME                      ATTEMPT             POD ID              POD                                                    NAMESPACE
19282f2b0e82c       78282b5844742       10 minutes ago      Running             kube-proxy                0                   be0bc499f0ee0       kube-proxy-clfjh                                       kube-system
48bb9fd37dd4f       b665198f31ae0       10 minutes ago      Running             kube-scheduler            0                   78ae9108a6f92       kube-scheduler-kubnet-cp-01.unidev.org.np            kube-system
221afb26d877e       c2616bc3c6956       11 minutes ago      Running             kube-controller-manager   0                   e94cddbdcccfc       kube-controller-manager-kubnet-cp-01.unidev.org.np   kube-system
e3f2b07becc19       315157c5c4d76       11 minutes ago      Running             kube-apiserver            0                   d5f32467320ea       kube-apiserver-kubnet-cp-01.unidev.org.np            kube-system
0ef752e8e2874       0584a39eafc30       12 minutes ago      Running             cilium-operator           1                   44b77b327370e       cilium-operator-bbdd9c45f-rd9nv                        kube-system
72ea551324f57       ee85eb1f0edd2       12 minutes ago      Running             etcd                      1                   f2429ae927938       etcd-kubnet-cp-01.unidev.org.np                      kube-system
113e435192c00       38667dd9be96c       2 hours ago         Running             coredns                   0                   16ba9b2353083       coredns-589f44dc88-mfp9r                               kube-system
8fd5bf09b35a1       38667dd9be96c       2 hours ago         Running             coredns                   0                   3685a64d26a2a       coredns-589f44dc88-pfbpf                               kube-system
05453475b7153       a33c91cd53fd5       2 hours ago         Running             cilium-envoy              0                   24d4556649714       cilium-envoy-k2r8f                                     kube-system
dca5e545823c5       701acb6ea12da       2 hours ago         Running             cilium-agent              0                   f18fd7bc17f12       cilium-trdms                                           kube-system
*/


--Go to https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/upgrading-linux-nodes/
--Step 22
root@kubnet-wr-01:~# kubectl get nodes
/*
NAME                           STATUS   ROLES           AGE    VERSION
kubnet-cp-01.unidev.org.np   Ready    control-plane   108m   v1.36.1
kubnet-wr-01.unidev.org.np   Ready    <none>          99m    v1.36.0
*/

--Step 22.1
root@kubnet-wr-01:~# kubectl get nodes -o wide
/*
NAME                           STATUS   ROLES           AGE    VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION              CONTAINER-RUNTIME
kubnet-cp-01.unidev.org.np   Ready    control-plane   109m   v1.36.1   192.1.6.33   <none>        Ubuntu 24.04.4 LTS   6.8.0-111-generic (amd64)   containerd://2.2.4
kubnet-wr-01.unidev.org.np   Ready    <none>          100m   v1.36.0   192.1.6.34   <none>        Ubuntu 24.04.4 LTS   6.8.0-111-generic (amd64)   containerd://2.2.4
*/

--Step 22.2
root@kubnet-wr-01:~# kubeadm version -o short
/*
v1.36.0
*/

--Step 22.3
root@kubnet-wr-01:~# kubeadm version
/*
kubeadm version: &version.Info{Major:"1", Minor:"36", EmulationMajor:"", EmulationMinor:"", MinCompatibilityMajor:"", MinCompatibilityMinor:"", GitVersion:"v1.36.0", GitCommit:"ecf6decece6a6de25a57aad9ba90b6ce580f6f78", GitTreeState:"clean", BuildDate:"2026-04-22T13:54:03Z", GoVersion:"go1.26.2", Compiler:"gc", Platform:"linux/amd64"}
*/

--Step 22.4
root@kubnet-wr-01:~# kubelet --version
/*
Kubernetes v1.36.0
*/

--Step 22.5
root@kubnet-wr-01:~# kubectl version
/*
Client Version: v1.36.0
Kustomize Version: v5.8.1
Server Version: v1.36.1
*/

--Step 22.6
root@kubnet-wr-01:~# apt-cache madison kubeadm | head -2
/*
   kubeadm | 1.36.1-1.1 | https://pkgs.k8s.io/core:/stable:/v1.36/deb  Packages
   kubeadm | 1.36.0-1.1 | https://pkgs.k8s.io/core:/stable:/v1.36/deb  Packages
*/

--Step 22.7
root@kubnet-wr-01:~# apt update
/*
Hit:1 https://download.docker.com/linux/ubuntu noble InRelease
Get:2 http://security.ubuntu.com/ubuntu noble-security InRelease [126 kB]
Hit:4 http://archive.ubuntu.com/ubuntu noble InRelease
Get:5 http://archive.ubuntu.com/ubuntu noble-updates InRelease [126 kB]
Hit:3 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.36/deb  InRelease
Get:6 http://security.ubuntu.com/ubuntu noble-security/main amd64 Components [42.4 kB]
Get:7 http://security.ubuntu.com/ubuntu noble-security/universe amd64 Components [74.2 kB]
Get:8 http://archive.ubuntu.com/ubuntu noble-backports InRelease [126 kB]
Get:9 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 Components [178 kB]
Get:10 http://archive.ubuntu.com/ubuntu noble-updates/universe amd64 Components [386 kB]
Get:11 http://archive.ubuntu.com/ubuntu noble-updates/multiverse amd64 Components [940 B]
Get:12 http://archive.ubuntu.com/ubuntu noble-backports/main amd64 Components [5,736 B]
Get:13 http://archive.ubuntu.com/ubuntu noble-backports/universe amd64 Components [10.5 kB]
Fetched 1,076 kB in 3s (390 kB/s)
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
21 packages can be upgraded. Run 'apt list --upgradable' to see them.
*/

--Step 22.8
root@kubnet-wr-01:~# apt-mark unhold kubeadm
/*
Canceled hold on kubeadm.
*/

--Step 22.9
root@kubnet-wr-01:~# apt-mark unhold kubeadm
/*
kubeadm was already not on hold.
*/

--Step 22.10
root@kubnet-wr-01:~# apt-get update && sudo apt-get install -y kubeadm=1.36.1-1.1 -y
/*
Hit:1 https://download.docker.com/linux/ubuntu noble InRelease
Hit:2 http://security.ubuntu.com/ubuntu noble-security InRelease
Hit:4 http://archive.ubuntu.com/ubuntu noble InRelease
Hit:3 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.36/deb  InRelease
Hit:5 http://archive.ubuntu.com/ubuntu noble-updates InRelease
Hit:6 http://archive.ubuntu.com/ubuntu noble-backports InRelease
Reading package lists... Done
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following package was automatically installed and is no longer required:
  cri-tools
Use 'sudo apt autoremove' to remove it.
The following packages will be upgraded:
  kubeadm
1 upgraded, 0 newly installed, 0 to remove and 20 not upgraded.
Need to get 12.6 MB of archives.
After this operation, 8,192 B of additional disk space will be used.
Get:1 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.36/deb  kubeadm 1.36.1-1.1 [12.6 MB]
Fetched 12.6 MB in 2s (8,022 kB/s)
(Reading database ... 126483 files and directories currently installed.)
Preparing to unpack .../kubeadm_1.36.1-1.1_amd64.deb ...
Unpacking kubeadm (1.36.1-1.1) over (1.36.0-1.1) ...
Setting up kubeadm (1.36.1-1.1) ...
Scanning processes...
Scanning linux images...

Running kernel seems to be up-to-date.

No services need to be restarted.

No containers need to be restarted.

No user sessions are running outdated binaries.

No VM guests are running outdated hypervisor (qemu) binaries on this host.
*/

--Step 22.11
root@kubnet-wr-01:~# apt-mark hold kubeadm
/*
kubeadm set on hold.
*/

--Step 22.12
root@kubnet-wr-01:~# apt-mark hold kubeadm
/*
kubeadm was already set on hold.
*/

--Step 22.13
root@kubnet-wr-01:~# apt-mark hold kubeadm
/*
kubeadm was already set on hold.
*/

--Step 22.14
root@kubnet-wr-01:~# kubeadm upgrade node
/*
[upgrade] Reading configuration from the "kubeadm-config" ConfigMap in namespace "kube-system"...
[upgrade] Use 'kubeadm init phase upload-config kubeadm --config your-config-file' to re-upload it.
W0530 14:53:11.957815    9550 utils.go:69] The recommended value for "bindAddress" in "KubeProxyConfiguration" is: ::; the provided value is: 0.0.0.0
[upgrade/preflight] Running pre-flight checks
[upgrade/preflight] Skipping prepull. Not a control plane node.
[upgrade/control-plane] Skipping phase. Not a control plane node.
[upgrade/kubeconfig] Skipping phase. Not a control plane node.
W0530 14:53:12.152783    9550 postupgrade.go:105] Using temporary directory /etc/kubernetes/tmp/kubeadm-kubelet-config-2026-05-30-14-53-12 for kubelet config. To override it set the environment variable KUBEADM_UPGRADE_DRYRUN_DIR
[upgrade] Backing up kubelet config file to /etc/kubernetes/tmp/kubeadm-kubelet-config-2026-05-30-14-53-12/config.yaml
[patches] Applied patch of type "application/strategic-merge-patch+json" to target "kubeletconfiguration"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[upgrade/kubelet-config] The kubelet configuration for this node was successfully upgraded!
[upgrade/addon] Skipping the addon/coredns phase. Not a control plane node.
[upgrade/addon] Skipping the addon/kube-proxy phase. Not a control plane node.
*/

--Drain the node
--Prepare the node for maintenance by marking it unschedulable and evicting the workloads:
--# execute this command on a control plane node
--# replace <node-to-drain> with the name of your node you are draining
--Step 22.15
root@kubnet-cp-01:~# kubectl drain kubnet-wr-01.unidev.org.np --ignore-daemonsets
/*
node/kubnet-wr-01.unidev.org.np cordoned
Warning: ignoring DaemonSet-managed Pods: kube-system/cilium-7rtdt, kube-system/cilium-envoy-gmz9l, kube-system/kube-proxy-656d6
node/kubnet-wr-01.unidev.org.np drained
*/

--Step 22.16
root@kubnet-cp-01:~# kubectl get nodes
/*
NAME                           STATUS                     ROLES           AGE    VERSION
kubnet-cp-01.unidev.org.np   Ready                      control-plane   115m   v1.36.1
kubnet-wr-01.unidev.org.np   Ready,SchedulingDisabled   <none>          107m   v1.36.0
*/

--Step 22.17
root@kubnet-cp-01:~# kubectl get nodes -o wide
/*
NAME                           STATUS                     ROLES           AGE    VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION              CONTAINER-RUNTIME
kubnet-cp-01.unidev.org.np   Ready                      control-plane   116m   v1.36.1   192.1.6.33   <none>        Ubuntu 24.04.4 LTS   6.8.0-111-generic (amd64)   containerd://2.2.4
kubnet-wr-01.unidev.org.np   Ready,SchedulingDisabled   <none>          107m   v1.36.0   192.1.6.34   <none>        Ubuntu 24.04.4 LTS   6.8.0-111-generic (amd64)   containerd://2.2.4
*/

--Step 22.18
root@kubnet-wr-01:~# kubectl get nodes
/*
NAME                           STATUS                     ROLES           AGE    VERSION
kubnet-cp-01.unidev.org.np   Ready                      control-plane   116m   v1.36.1
kubnet-wr-01.unidev.org.np   Ready,SchedulingDisabled   <none>          107m   v1.36.0
*/

--Step 22.19
root@kubnet-wr-01:~# apt-mark unhold kubelet kubectl
/*
Canceled hold on kubelet.
Canceled hold on kubectl.
*/

--Step 22.20
root@kubnet-wr-01:~# apt-mark unhold kubelet kubectl
/*
kubelet was already not on hold.
kubectl was already not on hold.
*/

--Step 22.21
root@kubnet-wr-01:~# apt-get update && sudo apt-get install -y kubelet=1.36.1-1.1 kubectl=1.36.1-1.1
/*
Hit:1 https://download.docker.com/linux/ubuntu noble InRelease
Hit:3 http://security.ubuntu.com/ubuntu noble-security InRelease
Hit:4 http://archive.ubuntu.com/ubuntu noble InRelease
Hit:5 http://archive.ubuntu.com/ubuntu noble-updates InRelease
Hit:2 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.36/deb  InRelease
Hit:6 http://archive.ubuntu.com/ubuntu noble-backports InRelease
Reading package lists... Done
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following package was automatically installed and is no longer required:
  cri-tools
Use 'sudo apt autoremove' to remove it.
The following packages will be upgraded:
  kubectl kubelet
2 upgraded, 0 newly installed, 0 to remove and 18 not upgraded.
Need to get 25.1 MB of archives.
After this operation, 16.4 kB of additional disk space will be used.
Get:1 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.36/deb  kubectl 1.36.1-1.1 [11.8 MB]
Get:2 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.36/deb  kubelet 1.36.1-1.1 [13.4 MB]
Fetched 25.1 MB in 2s (14.1 MB/s)
(Reading database ... 126483 files and directories currently installed.)
Preparing to unpack .../kubectl_1.36.1-1.1_amd64.deb ...
Unpacking kubectl (1.36.1-1.1) over (1.36.0-1.1) ...
Preparing to unpack .../kubelet_1.36.1-1.1_amd64.deb ...
Unpacking kubelet (1.36.1-1.1) over (1.36.0-1.1) ...
Setting up kubectl (1.36.1-1.1) ...
Setting up kubelet (1.36.1-1.1) ...
Scanning processes...
Scanning candidates...
Scanning linux images...

Running kernel seems to be up-to-date.

Restarting services...
 systemctl restart kubelet.service

No containers need to be restarted.

No user sessions are running outdated binaries.

No VM guests are running outdated hypervisor (qemu) binaries on this host.
*/

--Step 22.22
root@kubnet-wr-01:~# apt-mark hold kubelet kubectl
/*
kubelet set on hold.
kubectl set on hold.
*/

--Step 22.23
root@kubnet-wr-01:~# apt-mark hold kubelet kubectl
/*
kubelet was already set on hold.
kubectl was already set on hold.
*/

--Step 22.24
root@kubnet-wr-01:~# systemctl daemon-reload

--Step 22.25
root@kubnet-wr-01:~# systemctl restart kubelet

--Step 22.26
root@kubnet-wr-01:~# systemctl status kubelet
/*
● kubelet.service - kubelet: The Kubernetes Node Agent
     Loaded: loaded (/usr/lib/systemd/system/kubelet.service; enabled; preset: enabled)
    Drop-In: /usr/lib/systemd/system/kubelet.service.d
             └─10-kubeadm.conf
     Active: active (running) since Sat 2026-05-30 15:00:20 +0545; 7s ago
       Docs: https://kubernetes.io/docs/
   Main PID: 10286 (kubelet)
      Tasks: 13 (limit: 5746)
     Memory: 23.0M (peak: 23.4M)
        CPU: 1.136s
     CGroup: /system.slice/kubelet.service
             └─10286 /usr/bin/kubelet --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf --config=/var/lib/kubelet/config.yaml

May 30 15:00:21 kubnet-wr-01.unidev.org.np kubelet[10286]: I0530 15:00:21.873548   10286 reconciler_common.go:251] "operationExecutor.VerifyControllerAttachedVolume started for volume \">
May 30 15:00:21 kubnet-wr-01.unidev.org.np kubelet[10286]: I0530 15:00:21.873646   10286 reconciler_common.go:251] "operationExecutor.VerifyControllerAttachedVolume started for volume \">
May 30 15:00:21 kubnet-wr-01.unidev.org.np kubelet[10286]: I0530 15:00:21.876431   10286 reconciler_common.go:251] "operationExecutor.VerifyControllerAttachedVolume started for volume \">
May 30 15:00:21 kubnet-wr-01.unidev.org.np kubelet[10286]: I0530 15:00:21.877224   10286 reconciler_common.go:251] "operationExecutor.VerifyControllerAttachedVolume started for volume \">
May 30 15:00:21 kubnet-wr-01.unidev.org.np kubelet[10286]: I0530 15:00:21.877360   10286 reconciler_common.go:251] "operationExecutor.VerifyControllerAttachedVolume started for volume \">
May 30 15:00:21 kubnet-wr-01.unidev.org.np kubelet[10286]: I0530 15:00:21.877454   10286 reconciler_common.go:251] "operationExecutor.VerifyControllerAttachedVolume started for volume \">
May 30 15:00:21 kubnet-wr-01.unidev.org.np kubelet[10286]: I0530 15:00:21.877548   10286 reconciler_common.go:251] "operationExecutor.VerifyControllerAttachedVolume started for volume \">
May 30 15:00:21 kubnet-wr-01.unidev.org.np kubelet[10286]: I0530 15:00:21.877686   10286 reconciler_common.go:251] "operationExecutor.VerifyControllerAttachedVolume started for volume \">
May 30 15:00:21 kubnet-wr-01.unidev.org.np kubelet[10286]: I0530 15:00:21.890038   10286 reconciler_common.go:251] "operationExecutor.VerifyControllerAttachedVolume started for volume \">
May 30 15:00:21 kubnet-wr-01.unidev.org.np kubelet[10286]: I0530 15:00:21.890199   10286 reconciler_common.go:251] "operationExecutor.VerifyControllerAttachedVolume started for volume \">
*/

--Uncordon the node
--Bring the node back online by marking it schedulable:
--# execute this command on a control plane node
--# replace <node-to-uncordon> with the name of your node
--Step 22.27
root@kubnet-cp-01:~# kubectl uncordon kubnet-wr-01.unidev.org.np
/*
node/kubnet-wr-01.unidev.org.np uncordoned
*/

--Step 22.28
root@kubnet-cp-01:~# kubectl get nodes -o wide
/*
NAME                           STATUS   ROLES           AGE    VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION              CONTAINER-RUNTIME
kubnet-cp-01.unidev.org.np   Ready    control-plane   121m   v1.36.1   192.1.6.33   <none>        Ubuntu 24.04.4 LTS   6.8.0-111-generic (amd64)   containerd://2.2.4
kubnet-wr-01.unidev.org.np   Ready    <none>          112m   v1.36.1   192.1.6.34   <none>        Ubuntu 24.04.4 LTS   6.8.0-111-generic (amd64)   containerd://2.2.4
*/

--Step 22.29
root@kubnet-cp-01:~# kubectl get nodes
/*
NAME                           STATUS   ROLES           AGE    VERSION
kubnet-cp-01.unidev.org.np   Ready    control-plane   121m   v1.36.1
kubnet-wr-01.unidev.org.np   Ready    <none>          112m   v1.36.1
*/

--Step 22.30
root@kubnet-wr-01:~# kubectl get nodes
/*
NAME                           STATUS   ROLES           AGE    VERSION
kubnet-cp-01.unidev.org.np   Ready    control-plane   121m   v1.36.1
kubnet-wr-01.unidev.org.np   Ready    <none>          113m   v1.36.1
*/

--Step 22.31
root@kubnet-wr-01:~# kubectl get nodes -o wide
/*
NAME                           STATUS   ROLES           AGE    VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION              CONTAINER-RUNTIME
kubnet-cp-01.unidev.org.np   Ready    control-plane   122m   v1.36.1   192.1.6.33   <none>        Ubuntu 24.04.4 LTS   6.8.0-111-generic (amd64)   containerd://2.2.4
kubnet-wr-01.unidev.org.np   Ready    <none>          113m   v1.36.1   192.1.6.34   <none>        Ubuntu 24.04.4 LTS   6.8.0-111-generic (amd64)   containerd://2.2.4
*/


--Step 23
root@kubnet-cp-01:~# kubectl get nodes
/*
NAME                           STATUS   ROLES           AGE    VERSION
kubnet-cp-01.unidev.org.np   Ready    control-plane   151m   v1.36.1
kubnet-wr-01.unidev.org.np   Ready    <none>          143m   v1.36.1
*/

--Step 23.1
root@kubnet-cp-01:~# kubectl get nodes -o wide
/*
NAME                           STATUS   ROLES           AGE    VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION              CONTAINER-RUNTIME
kubnet-cp-01.unidev.org.np   Ready    control-plane   151m   v1.36.1   192.1.6.33   <none>        Ubuntu 24.04.4 LTS   6.8.0-111-generic (amd64)   containerd://2.2.4
kubnet-wr-01.unidev.org.np   Ready    <none>          143m   v1.36.1   192.1.6.34   <none>        Ubuntu 24.04.4 LTS   6.8.0-111-generic (amd64)   containerd://2.2.4
*/

--Step 23.2
root@kubnet-cp-01:~# kubectl get pods -A
/*
NAMESPACE     NAME                                                   READY   STATUS    RESTARTS      AGE
kube-system   cilium-7rtdt                                           1/1     Running   0             143m
kube-system   cilium-envoy-gmz9l                                     1/1     Running   0             143m
kube-system   cilium-envoy-k2r8f                                     1/1     Running   0             147m
kube-system   cilium-operator-bbdd9c45f-rd9nv                        1/1     Running   1 (62m ago)   147m
kube-system   cilium-trdms                                           1/1     Running   0             147m
kube-system   coredns-589f44dc88-mfp9r                               1/1     Running   0             151m
kube-system   coredns-589f44dc88-pfbpf                               1/1     Running   0             151m
kube-system   etcd-kubnet-cp-01.unidev.org.np                      1/1     Running   1 (62m ago)   152m
kube-system   kube-apiserver-kubnet-cp-01.unidev.org.np            1/1     Running   0             61m
kube-system   kube-controller-manager-kubnet-cp-01.unidev.org.np   1/1     Running   0             61m
kube-system   kube-proxy-656d6                                       1/1     Running   0             60m
kube-system   kube-proxy-clfjh                                       1/1     Running   0             60m
kube-system   kube-scheduler-kubnet-cp-01.unidev.org.np            1/1     Running   0             60m
*/

--Step 23.3
root@kubnet-cp-01:~# cilium status
/*
    /¯¯\
 /¯¯\__/¯¯\    Cilium:             OK
 \__/¯¯\__/    Operator:           OK
 /¯¯\__/¯¯\    Envoy DaemonSet:    OK
 \__/¯¯\__/    Hubble Relay:       disabled
    \__/       ClusterMesh:        disabled

DaemonSet              cilium                   Desired: 2, Ready: 2/2, Available: 2/2
DaemonSet              cilium-envoy             Desired: 2, Ready: 2/2, Available: 2/2
Deployment             cilium-operator          Desired: 1, Ready: 1/1, Available: 1/1
Containers:            cilium                   Running: 2
                       cilium-envoy             Running: 2
                       cilium-operator          Running: 1
                       clustermesh-apiserver
                       hubble-relay
Cluster Pods:          2/2 managed by Cilium
Helm chart version:    1.19.4
Image versions         cilium             quay.io/cilium/cilium:v1.19.4@sha256:2eb67991eaa9368ba199c2fac2c573cb0ffdeb79184533344f42fc9a7ff6af3c: 2
                       cilium-envoy       quay.io/cilium/cilium-envoy:v1.36.6-1778235340-b87d1e32f522b33bd51701c6476d199326f01496@sha256:71d4fa0ec45e8d546dbd5604e169dc77fe92be63b799313bff031d00d89762e3: 2
                       cilium-operator    quay.io/cilium/operator-generic:v1.19.4@sha256:1aa2b62735e7d8ab49ee840ae59c346932024c88901579121395c1271b435f71: 1
*/


--Step 24
root@kubnet-wr-01:~# kubectl get nodes
/*
NAME                           STATUS   ROLES           AGE    VERSION
kubnet-cp-01.unidev.org.np   Ready    control-plane   150m   v1.36.1
kubnet-wr-01.unidev.org.np   Ready    <none>          142m   v1.36.1
*/

--Step 24.1
root@kubnet-wr-01:~# kubectl get nodes -o wide
/*
NAME                           STATUS   ROLES           AGE    VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION              CONTAINER-RUNTIME
kubnet-cp-01.unidev.org.np   Ready    control-plane   150m   v1.36.1   192.1.6.33   <none>        Ubuntu 24.04.4 LTS   6.8.0-111-generic (amd64)   containerd://2.2.4
kubnet-wr-01.unidev.org.np   Ready    <none>          142m   v1.36.1   192.1.6.34   <none>        Ubuntu 24.04.4 LTS   6.8.0-111-generic (amd64)   containerd://2.2.4
*/

--Step 24.2
root@kubnet-wr-01:~# kubectl get pods -A
/*
NAMESPACE     NAME                                                   READY   STATUS    RESTARTS      AGE
kube-system   cilium-7rtdt                                           1/1     Running   0             140m
kube-system   cilium-envoy-gmz9l                                     1/1     Running   0             140m
kube-system   cilium-envoy-k2r8f                                     1/1     Running   0             144m
kube-system   cilium-operator-bbdd9c45f-rd9nv                        1/1     Running   1 (59m ago)   144m
kube-system   cilium-trdms                                           1/1     Running   0             144m
kube-system   coredns-589f44dc88-mfp9r                               1/1     Running   0             148m
kube-system   coredns-589f44dc88-pfbpf                               1/1     Running   0             148m
kube-system   etcd-kubnet-cp-01.unidev.org.np                      1/1     Running   1 (59m ago)   148m
kube-system   kube-apiserver-kubnet-cp-01.unidev.org.np            1/1     Running   0             58m
kube-system   kube-controller-manager-kubnet-cp-01.unidev.org.np   1/1     Running   0             58m
kube-system   kube-proxy-656d6                                       1/1     Running   0             57m
kube-system   kube-proxy-clfjh                                       1/1     Running   0             57m
kube-system   kube-scheduler-kubnet-cp-01.unidev.org.np            1/1     Running   0             57m
*/

--Step 24.3
root@kubnet-wr-01:~# cilium status
/*
    /¯¯\
 /¯¯\__/¯¯\    Cilium:             OK
 \__/¯¯\__/    Operator:           OK
 /¯¯\__/¯¯\    Envoy DaemonSet:    OK
 \__/¯¯\__/    Hubble Relay:       disabled
    \__/       ClusterMesh:        disabled

DaemonSet              cilium                   Desired: 2, Ready: 2/2, Available: 2/2
DaemonSet              cilium-envoy             Desired: 2, Ready: 2/2, Available: 2/2
Deployment             cilium-operator          Desired: 1, Ready: 1/1, Available: 1/1
Containers:            cilium                   Running: 2
                       cilium-envoy             Running: 2
                       cilium-operator          Running: 1
                       clustermesh-apiserver
                       hubble-relay
Cluster Pods:          2/2 managed by Cilium
Helm chart version:    1.19.4
Image versions         cilium             quay.io/cilium/cilium:v1.19.4@sha256:2eb67991eaa9368ba199c2fac2c573cb0ffdeb79184533344f42fc9a7ff6af3c: 2
                       cilium-envoy       quay.io/cilium/cilium-envoy:v1.36.6-1778235340-b87d1e32f522b33bd51701c6476d199326f01496@sha256:71d4fa0ec45e8d546dbd5604e169dc77fe92be63b799313bff031d00d89762e3: 2
                       cilium-operator    quay.io/cilium/operator-generic:v1.19.4@sha256:1aa2b62735e7d8ab49ee840ae59c346932024c88901579121395c1271b435f71: 1
*/