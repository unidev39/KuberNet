--Step 1
root@docker-minikube-n02:~# df -Th
/*
Filesystem                        Type   Size  Used Avail Use% Mounted on
tmpfs                             tmpfs  488M  1.5M  486M   1% /run
/dev/mapper/ubuntu--vg-ubuntu--lv ext4    24G  7.4G   15G  34% /
tmpfs                             tmpfs  2.4G     0  2.4G   0% /dev/shm
tmpfs                             tmpfs  5.0M     0  5.0M   0% /run/lock
/dev/sda2                         ext4   2.0G  200M  1.6G  11% /boot
tmpfs                             tmpfs  488M   12K  487M   1% /run/user/1000
*/

--Step 1.0
root@docker-minikube-n02:~# hostnamectl
/*
 Static hostname: docker-minikube-n02.unidev.org.np
       Icon name: computer-vm
         Chassis: vm 🖴
      Machine ID: 50708e19b677484c92840925bff7e721
         Boot ID: f01fac98f9034e8182f2d5f3fb97d4d8
  Virtualization: vmware
Operating System: Ubuntu 24.04.4 LTS
          Kernel: Linux 6.8.0-124-generic
    Architecture: x86-64
 Hardware Vendor: VMware, Inc.
  Hardware Model: VMware Virtual Platform
Firmware Version: 6.00
   Firmware Date: Wed 2018-12-12
    Firmware Age: 7y 5month 2w 4d
*/

--Step 2 (OS Configuration and KubeNet Installation)
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

--Step 2.1 (OS Configuration and KubeNet Installation)
root@docker-minikube-n02:~# chmod -R 775 prepare-node.sh

--Step 2.2 (OS Configuration and KubeNet Installation)
root@docker-minikube-n02:~# ll prepare-node.sh
/*
-rwxrwxr-x 1 root root 3221 May 31 08:57 prepare-node.sh*
*/

--Step 2.3 (OS Configuration and KubeNet Installation)
root@docker-minikube-n02:~# bash ./prepare-node.sh
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
0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
File '/etc/apt/keyrings/docker.gpg' exists. Overwrite? (y/N) y
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
containerd.io is already the newest version (2.2.4-1~ubuntu.24.04~noble).
0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
==> Configuring containerd (SystemdCgroup=true)
==> Installing kubeadm, kubelet, kubectl (v1.36)
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
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
Fetched 93.0 MB in 5s (18.7 MB/s)
Selecting previously unselected package cri-tools.
(Reading database ... 126676 files and directories currently installed.)
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
--Step 3 (MiniKube Installation)
root@docker-minikube-n02:~# curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
/*
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100  128M  100  128M    0     0  14.4M      0  0:00:08  0:00:08 --:--:-- 17.2M
*/

--Step 3.1 (MiniKube Installation)
root@docker-minikube-n02:~# sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64

--Step 3.2 (Configuration of ContorlPlane and WorkerNode Using MiniKube)
root@docker-minikube-n02:~# minikube start --nodes 2 --force
/*
* minikube v1.38.1 on Ubuntu 24.04
! minikube skips various validations when --force is supplied; this may lead to unexpected be                                                                                                havior
* Automatically selected the docker driver. Other choices: none, ssh
* The "docker" driver should not be used with root privileges. If you wish to continue as roo                                                                                                t, use --force.
* If you are running minikube within a VM, consider using --driver=none:
*   https://minikube.sigs.k8s.io/docs/reference/drivers/none/
! Starting v1.39.0, minikube will default to "containerd" container runtime. See #21973 for m                                                                                                ore info.
* Using Docker driver with root privileges
* Starting "minikube" primary control-plane node in "minikube" cluster
* Pulling base image v0.0.50 ...
* Downloading Kubernetes v1.35.1 preload ...
    > preloaded-images-k8s-v18-v1...:  272.45 MiB / 272.45 MiB  100.00% 14.72 M
    > gcr.io/k8s-minikube/kicbase...:  519.58 MiB / 519.58 MiB  100.00% 14.48 M
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

--Step 3.3 (Verfication of ContorlPlane and WorkerNode Using MiniKube)
root@docker-minikube-n02:~# kubectl get nodes
/*
NAME           STATUS   ROLES           AGE     VERSION
minikube       Ready    control-plane   4m25s   v1.35.1
minikube-m02   Ready    <none>          2m27s   v1.35.1
*/

--Step 3.4 (Verfication of ContorlPlane and WorkerNode Using MiniKube)
root@docker-minikube-n02:~# kubectl get nodes -o wide
/*
NAME           STATUS   ROLES           AGE     VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE                         KERNEL-VERSION      CONTAINER-RUNTIME
minikube       Ready    control-plane   4m34s   v1.35.1   192.168.49.2   <none>        Debian GNU/Linux 12 (bookworm)   6.8.0-124-generic   docker://29.2.1
minikube-m02   Ready    <none>          2m36s   v1.35.1   192.168.49.3   <none>        Debian GNU/Linux 12 (bookworm)   6.8.0-124-generic   docker://29.2.1
*/

--Step 3.5 (Verfication of ContorlPlane and WorkerNode Using MiniKube)
root@docker-minikube-n02:~# kubectl get pods -A
/*
NAMESPACE     NAME                               READY   STATUS    RESTARTS   AGE
kube-system   coredns-7d764666f9-skh86           1/1     Running   0          4m33s
kube-system   etcd-minikube                      1/1     Running   0          4m38s
kube-system   kindnet-7c6qs                      1/1     Running   0          4m34s
kube-system   kindnet-glhz7                      1/1     Running   0          2m46s
kube-system   kube-apiserver-minikube            1/1     Running   0          4m38s
kube-system   kube-controller-manager-minikube   1/1     Running   0          4m42s
kube-system   kube-proxy-8z2gb                   1/1     Running   0          4m34s
kube-system   kube-proxy-xhhbs                   1/1     Running   0          2m46s
kube-system   kube-scheduler-minikube            1/1     Running   0          4m40s
kube-system   storage-provisioner                1/1     Running   0          4m31s
*/

--Step 3.6 (Verfication of ContorlPlane and WorkerNode Using MiniKube)
root@docker-minikube-n02:~# kubectl get ns
/*
NAME              STATUS   AGE
default           Active   6m24s
kube-node-lease   Active   6m24s
kube-public       Active   6m24s
kube-system       Active   6m24s
*/


--Step 4 (lab)
root@docker-minikube-n02:~# kubectl create namespace production --dry-run=client -o yaml && echo "---" &&  kubectl create deployment web-app --image=nginx:alpine --replicas=3 --port=80 --namespace=production --dry-run=client -o yaml
/*
apiVersion: v1
kind: Namespace
metadata:
  name: production
spec: {}
status: {}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: web-app
  name: web-app
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-app
  strategy: {}
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - image: nginx:alpine
        name: nginx
        ports:
        - containerPort: 80
        resources: {}
status: {}
*/

--Step 4.1 (lab)
root@docker-minikube-n02:~# kubectl create namespace production --dry-run=client -o yaml > setup.yaml
root@docker-minikube-n02:~# echo "---" >> setup.yaml
root@docker-minikube-n02:~# kubectl create deployment web-app --image=nginx:alpine --replicas=3 --port=80 --namespace=production --dry-run=client -o yaml >> setup.yaml
root@docker-minikube-n02:~# cat setup.yaml
/*
apiVersion: v1
kind: Namespace
metadata:
  name: production
spec: {}
status: {}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: web-app
  name: web-app
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-app
  strategy: {}
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - image: nginx:alpine
        name: nginx
        ports:
        - containerPort: 80
        resources: {}
status: {}
*/

--Step 4.2 (lab)
root@docker-minikube-n02:~# kubectl apply -f setup.yaml --dry-run=client
/*
namespace/production created (dry run)
deployment.apps/web-app created (dry run)
*/

--Step 4.3 (lab)
root@docker-minikube-n02:~# kubectl apply -f setup.yaml
/*
namespace/production created
deployment.apps/web-app created
*/

--Step 4.4 (lab)
root@docker-minikube-n02:~# kubectl get pods -A
/*
NAMESPACE     NAME                               READY   STATUS    RESTARTS   AGE
kube-system   coredns-7d764666f9-skh86           1/1     Running   0          41m
kube-system   etcd-minikube                      1/1     Running   0          41m
kube-system   kindnet-7c6qs                      1/1     Running   0          41m
kube-system   kindnet-glhz7                      1/1     Running   0          39m
kube-system   kube-apiserver-minikube            1/1     Running   0          41m
kube-system   kube-controller-manager-minikube   1/1     Running   0          41m
kube-system   kube-proxy-8z2gb                   1/1     Running   0          41m
kube-system   kube-proxy-xhhbs                   1/1     Running   0          39m
kube-system   kube-scheduler-minikube            1/1     Running   0          41m
kube-system   storage-provisioner                1/1     Running   0          41m
production    web-app-7bbff855cc-hr7t8           1/1     Running   0          119s
production    web-app-7bbff855cc-nk5j6           1/1     Running   0          119s
production    web-app-7bbff855cc-pzp4s           1/1     Running   0          119s
*/

--Step 4.5 (lab)
root@docker-minikube-n02:~# kubectl get pods -n production
/*
NAME                       READY   STATUS    RESTARTS   AGE
web-app-7bbff855cc-hr7t8   1/1     Running   0          24s
web-app-7bbff855cc-nk5j6   1/1     Running   0          24s
web-app-7bbff855cc-pzp4s   1/1     Running   0          24s
*/

--Step 4.6 (lab)
root@docker-minikube-n02:~# cp setup.yaml setup.yaml.bk

--Step 4.7 (lab)
root@docker-minikube-n02:~# vi setup.yaml
/*
apiVersion: v1
kind: Namespace
metadata:
  name: production
spec: {}
status: {}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: web-app
  name: web-app
  namespace: production
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: web-app
        image: httpd:trixie
        ports:
          - containerPort: 80
status: {}
*/

--Step 4.8 (lab)
root@docker-minikube-n02:~# kubectl apply -f setup.yaml --dry-run=client
/*
namespace/production unchanged (dry run)
deployment.apps/web-app configured (dry run)
*/

--Step 4.9 (lab)
root@docker-minikube-n02:~# kubectl apply -f setup.yaml
/*
namespace/production unchanged
deployment.apps/web-app configured
*/

--Step 4.10 (lab)
root@docker-minikube-n02:~# kubectl rollout status deployment/web-app -n production
/*
deployment "web-app" successfully rolled out
*/

--Step 4.11 (lab)
root@docker-minikube-n02:~# kubectl get deployment -o wide -n production
/*
NAME      READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES         SELECTOR
web-app   3/3     3            3           20m   web-app      httpd:trixie   app=web-app
*/

--Step 4.12 (lab)
root@docker-minikube-n02:~# kubectl get deployment web-app -n production -o yaml | grep -i -A3 strategy
/*
      {"apiVersion":"apps/v1","kind":"Deployment","metadata":{"annotations":{},"labels":{"app":"web-app"},"name":"web-app","namespace":"production"},"spec":{"replicas":3,"selector":{"matchLabels":{"app":"web-app"}},"strategy":{"rollingUpdate":{"maxSurge":1,"maxUnavailable":1},"type":"RollingUpdate"},"template":{"metadata":{"labels":{"app":"web-app"}},"spec":{"containers":[{"image":"httpd:trixie","name":"web-app","ports":[{"containerPort":80}]}]}}},"status":{}}
  creationTimestamp: "2026-05-31T03:59:17Z"
  generation: 2
  labels:
--
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
*/

--Step 4.13 (lab)
root@docker-minikube-n02:~# kubectl rollout undo deployment/web-app -n production
/*
Warning: resource deployments/web-app was previously managed with 'kubectl apply'. Rolling back will not update the kubectl.kubernetes.io/last-applied-configuration annotation, which may cause unexpected behavior on future 'kubectl apply' operations. Consider using 'kubectl apply' with your previous configuration file instead.
deployment.apps/web-app rolled back
*/

--Step 4.14 (lab)
root@docker-minikube-n02:~# kubectl rollout status deployment/web-app -n production
/*
deployment "web-app" successfully rolled out
*/

--Step 4.15 (lab) - Issue Seen
root@docker-minikube-n02:~# kubectl get deployment -o wide -n production
/*
NAME      READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES         SELECTOR
web-app   3/3     3            3           31m   web-app      httpd:trixie   app=web-app
*/

--Step 4.16 (lab) - Issue Seen
root@docker-minikube-n02:~# kubectl rollout history deployment/web-app -n production
/*
deployment.apps/web-app
REVISION  CHANGE-CAUSE
3         <none>
4         <none>
*/

--Step 4.17 (lab) - Issue Fixed by adding (--to-revision=3)
root@docker-minikube-n02:~# kubectl rollout undo deployment/web-app -n production --to-revision=3
/*
Warning: resource deployments/web-app was previously managed with 'kubectl apply'. Rolling back will not update the kubectl.kubernetes.io/last-applied-configuration annotation, which may cause unexpected behavior on future 'kubectl apply' operations. Consider using 'kubectl apply' with your previous configuration file instead.
deployment.apps/web-app rolled back
*/

--Step 4.18 (lab)
root@docker-minikube-n02:~# kubectl rollout status deployment/web-app -n production
/*
deployment "web-app" successfully rolled out
*/

--Step 4.19 (lab)
root@docker-minikube-n02:~# kubectl rollout history deployment/web-app -n production
/*
deployment.apps/web-app
REVISION  CHANGE-CAUSE
4         <none>
5         <none>
*/

--Step 4.20 (lab)
root@docker-minikube-n02:~# kubectl get deployment -o wide -n production                     
/*
NAME      READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES         SELECTOR
web-app   3/3     3            3           34m   nginx        nginx:alpine   app=web-app
*/

--Step 4.21 (lab)
root@docker-minikube-n02:~# kubectl rollout history deployment/web-app -n production --revision=4
/*
deployment.apps/web-app with revision #4
Pod Template:
  Labels:       app=web-app
        pod-template-hash=5c4548fd5f
  Containers:
   web-app:
    Image:      httpd:trixie
    Port:       80/TCP
    Host Port:  0/TCP
    Environment:        <none>
    Mounts:     <none>
  Volumes:      <none>
  Node-Selectors:       <none>
  Tolerations:  <none>
*/

--Step 4.22 (lab)
root@docker-minikube-n02:~# kubectl rollout history deployment/web-app -n production --revision=5
/*
deployment.apps/web-app with revision #5
Pod Template:
  Labels:       app=web-app
        pod-template-hash=7bbff855cc
  Containers:
   nginx:
    Image:      nginx:alpine
    Port:       80/TCP
    Host Port:  0/TCP
    Environment:        <none>
    Mounts:     <none>
  Volumes:      <none>
  Node-Selectors:       <none>
  Tolerations:  <none>
*/