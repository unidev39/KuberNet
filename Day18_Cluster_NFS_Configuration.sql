--Cluster NFS Configuration
-- 1. Lodbalancer => 1
-- 2. ControlPlan => 3
-- 3. WorkerNode  => 1

-- Configure NFS Server
--Step 1 (Lab) --To Allow Share Storage to Worker Node Only
root@sysadmin:~# vi /etc/exports
/*
/k8s_storage/devesh 192.1.6.32(rw,sync,no_subtree_check,no_root_squash)
*/

--Step 1.1 (Lab) --Apply the changes without restarting the NFS service
root@sysadmin:~# exportfs -ra
/*
/k8s_storage/devesh 192.1.6.32(rw,sync,no_subtree_check,no_root_squash)
*/

--Step 1.2 (Lab) --Apply the changes with restarting the NFS service
root@sysadmin:~# systemctl restart nfs-kernel-server

--Step 1.2.1 (Lab) --Verfy the NFS service
root@sysadmin:~# systemctl status nfs-kernel-server
/*
● nfs-server.service - NFS server and services
     Loaded: loaded (/lib/systemd/system/nfs-server.service; enabled; vendor preset: enabled)
    Drop-In: /run/systemd/generator/nfs-server.service.d
             └─order-with-mounts.conf
     Active: active (exited) since Mon 2026-06-15 09:29:06 UTC; 6s ago
    Process: 8471 ExecStartPre=/usr/sbin/exportfs -r (code=exited, status=0/SUCCESS)
    Process: 8472 ExecStart=/usr/sbin/rpc.nfsd (code=exited, status=0/SUCCESS)
   Main PID: 8472 (code=exited, status=0/SUCCESS)
        CPU: 18ms

Jun 15 09:29:05 sysadmin systemd[1]: Starting NFS server and services...
Jun 15 09:29:06 sysadmin systemd[1]: Finished NFS server and services.
*/

--Step 2 (lab) -- To verify the IP and HostNames
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

--Step 3 (lab) -- Enter Into ControlPlane
root@kubnet-lb:~# ssh lab@kubnet-cp-1.unidev.org.np
/*
lab@kubnet-cp-1.unidev.org.np's password:
Last login: Mon Jun 15 14:28:39 2026 from 10.0.131.3
*/

--Step 3.1 (lab) -- Enter Into ControlPlane
lab@kubnet-cp-1:~$ sudo su -
/*
[sudo] password for lab:
*/

--Step 3.2 (lab) -- Configure the Alias
root@kubnet-cp-1:~# vi ~/.bashrc
/*
alias k=kubectl
*/

--Step 3.3 (lab) -- Configure the Alias
root@kubnet-cp-1:~# . ~/.bashrc

--Step 4 (lab) -- Verfy the Cluster 
root@kubnet-cp-1:~# k get nodes -o wide
/*
NAME                              STATUS   ROLES           AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION              CONTAINER-RUNTIME
kubnet-cp-1.unidev.org.np       Ready    control-plane   17d   v1.36.1   192.1.6.29   <none>        Ubuntu 24.04.4 LTS   6.8.0-111-generic (amd64)   containerd://2.2.4
kubnet-cp-2.unidev.org.np       Ready    control-plane   17d   v1.36.1   192.1.6.30   <none>        Ubuntu 24.04.4 LTS   6.8.0-111-generic (amd64)   containerd://2.2.4
kubnet-cp-3.unidev.org.np       Ready    control-plane   17d   v1.36.1   192.1.6.31   <none>        Ubuntu 24.04.4 LTS   6.8.0-111-generic (amd64)   containerd://2.2.4
kubnet-worker-1.unidev.org.np   Ready    <none>          17d   v1.36.1   192.1.6.32   <none>        Ubuntu 24.04.4 LTS   6.8.0-117-generic (amd64)   containerd://2.2.4
*/

--Step 5 (lab) --Install NFS CSI driver v4.13.2 version on a kubernetes cluster
--> Go to https://kubernetes.io/docs/concepts/storage/storage-classes/#nfs
--> To configure NFS storage, you can use the in-tree driver or the NFS CSI driver for Kubernetes (recommended).
--> https://github.com/kubernetes-csi/csi-driver-nfs/blob/master/docs/install-nfs-csi-driver.md
--> https://github.com/kubernetes-csi/csi-driver-nfs/blob/master/docs/install-csi-driver-v4.13.2.md
--Option#2. local install
root@kubnet-cp-1:~# git clone https://github.com/kubernetes-csi/csi-driver-nfs.git
/*
Cloning into 'csi-driver-nfs'...
remote: Enumerating objects: 48743, done.
remote: Counting objects: 100% (258/258), done.
remote: Compressing objects: 100% (138/138), done.
remote: Total 48743 (delta 175), reused 128 (delta 116), pack-reused 48485 (from 4)
Receiving objects: 100% (48743/48743), 46.08 MiB | 2.16 MiB/s, done.
Resolving deltas: 100% (28715/28715), done.
Updating files: 100% (8787/8787), done.
*/

--Step 5.1 (lab)
root@kubnet-cp-1:~# cd csi-driver-nfs

--Step 5.2 (lab)
root@kubnet-cp-1:~# ./deploy/install-driver.sh v4.13.2 local
/*
use local deploy
Installing NFS CSI driver, version: v4.13.2 ...
serviceaccount/csi-nfs-controller-sa created
serviceaccount/csi-nfs-node-sa created
clusterrole.rbac.authorization.k8s.io/nfs-external-provisioner-role created
clusterrolebinding.rbac.authorization.k8s.io/nfs-csi-provisioner-binding created
clusterrole.rbac.authorization.k8s.io/nfs-external-resizer-role created
clusterrolebinding.rbac.authorization.k8s.io/nfs-csi-resizer-role created
csidriver.storage.k8s.io/nfs.csi.k8s.io created
deployment.apps/csi-nfs-controller created
daemonset.apps/csi-nfs-node created
NFS CSI driver installed successfully.
*/

--Step 5.3 (lab) --Check pods status
root@kubnet-cp-1:~# kubectl -n kube-system get pod -o wide -l app=csi-nfs-controller -w
/*
NAME                                  READY   STATUS              RESTARTS    AGE    IP            NODE                              NOMINATED NODE   READINESS GATES
csi-nfs-controller-5bf9df6ffc-ztkk8   0/5     ContainerCreating   0           57s    192.1.6.32   kubnet-worker-1.unidev.org.np   <none>           <none>
csi-nfs-controller-5bf9df6ffc-ztkk8   5/5     Running             2 (76s ago) 2m48s  192.1.6.32   kubnet-worker-1.unidev.org.np   <none>           <none>
*/

--Step 5.4 (lab) --Check pods status
root@kubnet-cp-1:~# kubectl -n kube-system get pod -o wide -l app=csi-nfs-node -o wide
/*
NAME                 READY   STATUS    RESTARTS        AGE     IP            NODE                              NOMINATED NODE   READINESS GATES
csi-nfs-node-6wfdt   3/3     Running   1 (3m24s ago)   4m16s   192.1.6.29   kubnet-cp-1.unidev.org.np       <none>           <none>
csi-nfs-node-md9v2   3/3     Running   1 (2m35s ago)   4m16s   192.1.6.32   kubnet-worker-1.unidev.org.np   <none>           <none>
csi-nfs-node-spl4p   3/3     Running   0               4m16s   192.1.6.30   kubnet-cp-2.unidev.org.np       <none>           <none>
csi-nfs-node-srcbb   3/3     Running   0               4m16s   192.1.6.31   kubnet-cp-3.unidev.org.np       <none>           <none>
*/

--Step 6 (lab) -- To Configure NFS Client on Worker Node
root@kubnet-lb:~# ssh lab@kubnet-worker-1.unidev.org.np
/*
lab@kubnet-worker-1.unidev.org.np's password:
Last login: Mon Jun 15 14:44:32 2026 from 192.1.6.28
*/

--Step 6.1 (lab)
lab@kubnet-worker-1:~$ sudo su -
/*
[sudo] password for lab:
*/

--Step 6.2 (lab)
root@kubnet-worker-1:~# apt update
/*
Hit:1 https://download.docker.com/linux/ubuntu noble InRelease
Hit:2 http://archive.ubuntu.com/ubuntu noble InRelease
Get:3 http://security.ubuntu.com/ubuntu noble-security InRelease [126 kB]
Get:5 http://archive.ubuntu.com/ubuntu noble-updates InRelease [126 kB]
Hit:4 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.36/deb  InRelease
Get:6 http://security.ubuntu.com/ubuntu noble-security/main amd64 Packages [849 kB]
Hit:7 http://archive.ubuntu.com/ubuntu noble-backports InRelease
Get:8 http://security.ubuntu.com/ubuntu noble-security/main Translation-en [183 kB]
Get:9 http://security.ubuntu.com/ubuntu noble-security/restricted amd64 Packages [1,232 kB]
Get:10 http://security.ubuntu.com/ubuntu noble-security/restricted Translation-en [286 kB]
Get:11 http://security.ubuntu.com/ubuntu noble-security/universe amd64 Packages [1,154 kB]
Get:12 http://security.ubuntu.com/ubuntu noble-security/universe Translation-en [226 kB]
Get:13 http://security.ubuntu.com/ubuntu noble-security/multiverse amd64 Packages [35.0 kB]
Get:14 http://security.ubuntu.com/ubuntu noble-security/multiverse Translation-en [8,368 B]
Get:15 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 Packages [1,112 kB]
Get:16 http://archive.ubuntu.com/ubuntu noble-updates/main Translation-en [267 kB]
Get:17 http://archive.ubuntu.com/ubuntu noble-updates/restricted amd64 Packages [1,318 kB]
Get:18 http://archive.ubuntu.com/ubuntu noble-updates/restricted Translation-en [303 kB]
Get:19 http://archive.ubuntu.com/ubuntu noble-updates/universe amd64 Packages [1,656 kB]
Get:20 http://archive.ubuntu.com/ubuntu noble-updates/universe Translation-en [326 kB]
Get:21 http://archive.ubuntu.com/ubuntu noble-updates/multiverse amd64 Packages [40.4 kB]
Get:22 http://archive.ubuntu.com/ubuntu noble-updates/multiverse Translation-en [10.5 kB]
Fetched 9,257 kB in 6s (1,646 kB/s)
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
11 packages can be upgraded. Run 'apt list --upgradable' to see them.
*/

--Step 6.3 (lab)
root@kubnet-worker-1:~# apt install -y nfs-common
/*
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following additional packages will be installed:
  keyutils libnfsidmap1 rpcbind
Suggested packages:
  watchdog
The following NEW packages will be installed:
  keyutils libnfsidmap1 nfs-common rpcbind
0 upgraded, 4 newly installed, 0 to remove and 11 not upgraded.
Need to get 400 kB of archives.
After this operation, 1,416 kB of additional disk space will be used.
Get:1 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 libnfsidmap1 amd64 1:2.6.4-3ubuntu5.1 [48.3 kB]
Get:2 http://archive.ubuntu.com/ubuntu noble/main amd64 rpcbind amd64 1.2.6-7ubuntu2 [46.5 kB]
Get:3 http://archive.ubuntu.com/ubuntu noble/main amd64 keyutils amd64 1.6.3-3build1 [56.8 kB]
Get:4 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 nfs-common amd64 1:2.6.4-3ubuntu5.1 [248 kB]
Fetched 400 kB in 1s (748 kB/s)
Selecting previously unselected package libnfsidmap1:amd64.
(Reading database ... 126503 files and directories currently installed.)
Preparing to unpack .../libnfsidmap1_1%3a2.6.4-3ubuntu5.1_amd64.deb ...
Unpacking libnfsidmap1:amd64 (1:2.6.4-3ubuntu5.1) ...
Selecting previously unselected package rpcbind.
Preparing to unpack .../rpcbind_1.2.6-7ubuntu2_amd64.deb ...
Unpacking rpcbind (1.2.6-7ubuntu2) ...
Selecting previously unselected package keyutils.
Preparing to unpack .../keyutils_1.6.3-3build1_amd64.deb ...
Unpacking keyutils (1.6.3-3build1) ...
Selecting previously unselected package nfs-common.
Preparing to unpack .../nfs-common_1%3a2.6.4-3ubuntu5.1_amd64.deb ...
Unpacking nfs-common (1:2.6.4-3ubuntu5.1) ...
Setting up libnfsidmap1:amd64 (1:2.6.4-3ubuntu5.1) ...
Setting up rpcbind (1.2.6-7ubuntu2) ...
Created symlink /etc/systemd/system/multi-user.target.wants/rpcbind.service → /usr/lib/systemd/system/rpcbind.service.
Created symlink /etc/systemd/system/sockets.target.wants/rpcbind.socket → /usr/lib/systemd/system/rpcbind.socket.
Setting up keyutils (1.6.3-3build1) ...
Setting up nfs-common (1:2.6.4-3ubuntu5.1) ...

Creating config file /etc/idmapd.conf with new version

Creating config file /etc/nfs.conf with new version
info: Selecting UID from range 100 to 999 ...

info: Adding system user `statd' (UID 111) ...
info: Adding new user `statd' (UID 111) with group `nogroup' ...
info: Not creating home directory `/var/lib/nfs'.
Created symlink /etc/systemd/system/multi-user.target.wants/nfs-client.target → /usr/lib/systemd/system/nfs-client.target.
Created symlink /etc/systemd/system/remote-fs.target.wants/nfs-client.target → /usr/lib/systemd/system/nfs-client.target.
auth-rpcgss-module.service is a disabled or a static unit, not starting it.
nfs-idmapd.service is a disabled or a static unit, not starting it.
nfs-utils.service is a disabled or a static unit, not starting it.
proc-fs-nfsd.mount is a disabled or a static unit, not starting it.
rpc-gssd.service is a disabled or a static unit, not starting it.
rpc-statd-notify.service is a disabled or a static unit, not starting it.
rpc-statd.service is a disabled or a static unit, not starting it.
rpc-svcgssd.service is a disabled or a static unit, not starting it.
Processing triggers for man-db (2.12.0-4build2) ...
Processing triggers for libc-bin (2.39-0ubuntu8.7) ...
Scanning processes...
Scanning candidates...
Scanning linux images...

Pending kernel upgrade!
Running kernel version:
  6.8.0-117-generic
Diagnostics:
  The currently running kernel version is not the expected kernel version 6.8.0-124-generic.

Restarting the system to load the new kernel will not be handled automatically, so you should consider rebooting.

Restarting services...

Service restarts being deferred:
 /etc/needrestart/restart.d/dbus.service
 systemctl restart systemd-logind.service
 systemctl restart unattended-upgrades.service

No containers need to be restarted.

No user sessions are running outdated binaries.

No VM guests are running outdated hypervisor (qemu) binaries on this host.
*/

--Step 6.4 (lab) -- Verify NFS Storage
root@kubnet-worker-1:~# showmount -e 192.1.6.39 | grep -i -E "devesh"
/*
/k8s_storage/devesh   192.1.6.32
*/

--Step 7 (lab) -- Start Persistent Volume over NFS Storage
root@kubnet-worker-1:~# ssh lab@kubnet-cp-1.unidev.org.np
/*
lab@kubnet-cp-1.unidev.org.np's password:
Last login: Mon Jun 15 14:58:49 2026 from 192.1.6.29
*/

--Step 7.1 (lab)
lab@kubnet-cp-1:~$ sudo su -
/*
[sudo] password for lab:
*/

--Step 7.2 (lab)
root@kubnet-cp-1:~# mkdir -p /development

--Step 7.2.1 (lab)
root@kubnet-cp-1:~# cd /development/

--Step 7.3 (lab) -- Create NFS Storage Class
root@kubnet-cp-1:/development# vi nfs-storageclass.yaml
/*
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: nfs
provisioner: kubernetes.io/no-provisioner
parameters:
  server: 192.1.6.39
  path: /k8s_storage/devesh
  readOnly: "false"
*/

--Step 7.4 (lab) --Dry Run
root@kubnet-cp-1:/development# k apply -f nfs-storageclass.yaml --dry-run=client
/*
storageclass.storage.k8s.io/nfs created (dry run)
*/

--Step 7.5 (lab) --Apply
root@kubnet-cp-1:/development# k apply -f nfs-storageclass.yaml
/*
storageclass.storage.k8s.io/nfs created
*/

--Step 7.6 (lab) --Verify
root@kubnet-cp-1:/development# k get sc -o wide
/*
NAME   PROVISIONER                    RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
nfs    kubernetes.io/no-provisioner   Delete          Immediate           false                  10s
*/

--Step 7.7 (lab) -- Create NFS Persistent Volume
root@kubnet-cp-1:/development# vi nfs-pv.yaml
/*
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs-pv
spec:
  capacity:
    storage: 20Gi
  storageClassName: nfs
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  nfs:
    path: /k8s_storage/devesh
    server: 192.1.6.39
*/

--Step 7.8 (lab) --Dry Run
root@kubnet-cp-1:/development# k apply -f nfs-pv.yaml --dry-run=client
/*
persistentvolume/nfs-pv created (dry run)
*/

--Step 7.9 (lab) --Apply
root@kubnet-cp-1:/development# k apply -f nfs-pv.yaml
/*
persistentvolume/nfs-pv created
*/

--Step 7.10 (lab) --Verify
root@kubnet-cp-1:/development# k get pv -o wide
/*
NAME     CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE   VOLUMEMODE
nfs-pv   20Gi       RWO            Retain           Available           nfs            <unset>                          13s   Filesystem
*/

--Step 7.11 (lab) -- Create NFS Persistent Volume Claim
root@kubnet-cp-1:/development# vi nfs-pv-claim.yaml
/*
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nfs-pv-claim
spec:
  volumeMode: Filesystem
  accessModes: [ReadWriteOnce]
  resources:
    requests:
      storage: 10Gi
  storageClassName: nfs
*/

--Step 7.12 (lab) --Dry Run
root@kubnet-cp-1:/development# k apply -f nfs-pv-claim.yaml --dry-run=client
/*
persistentvolumeclaim/nfs-pv-claim created (dry run)
*/

--Step 7.13 (lab) --Apply
root@kubnet-cp-1:/development# k apply -f nfs-pv-claim.yaml
/*
persistentvolumeclaim/nfs-pv-claim created
*/

--Step 7.14 (lab) --Verify
root@kubnet-cp-1:/development# k get pv,pvc -o wide
/*
NAME                      CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                  STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE     VOLUMEMODE
persistentvolume/nfs-pv   20Gi       RWO            Retain           Bound    default/nfs-pv-claim   nfs            <unset>                          2m48s   Filesystem

NAME                                 STATUS   VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE   VOLUMEMODE
persistentvolumeclaim/nfs-pv-claim   Bound    nfs-pv   20Gi       RWO            nfs            <unset>                 26s   Filesystem
*/

--Step 7.14.1 (lab) --Verify
root@kubnet-cp-1:/development# k get pv -o wide && k get pvc -o wide
/*
NAME     CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                  STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE     VOLUMEMODE
nfs-pv   20Gi       RWO            Retain           Bound    default/nfs-pv-claim   nfs            <unset>                          3m21s   Filesystem

NAME           STATUS   VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE   VOLUMEMODE
nfs-pv-claim   Bound    nfs-pv   20Gi       RWO            nfs            <unset>                 59s   Filesystem
*/

--Step 7.15 (lab) -- Create Pod Over NFS Storage
root@kubnet-cp-1:/development# vi nfs-pod.yaml
/*
apiVersion: v1
kind: Pod
metadata:
  name: web
spec:
  containers:
    - name: web
      image: nginx
      volumeMounts:
      - mountPath: /mnt/devesh
        name: devesh-nfs
  volumes:
    - name: devesh-nfs
      persistentVolumeClaim:
        claimName: nfs-pv-claim
*/

--Step 7.16 (lab) --Dry Run
root@kubnet-cp-1:/development# k apply -f nfs-pod.yaml --dry-run=client
/*
pod/web created (dry run)
*/

--Step 7.17 (lab) --Apply
root@kubnet-cp-1:/development# k apply -f nfs-pod.yaml
/*
pod/web created
*/

--Step 7.18 (lab) --Verify -- The Pod Status
root@kubnet-cp-1:/development# k get pods web -w -o wide
/*
NAME   READY   STATUS              RESTARTS   AGE   IP       NODE                              NOMINATED NODE   READINESS GATES
web    0/1     ContainerCreating   0          23s   <none>   kubnet-worker-1.unidev.org.np   <none>           <none>
web    1/1     Running             0          25s   10.0.3.253   kubnet-worker-1.unidev.org.np   <none>           <none>
*/

--Step 7.19 (lab) --Verify -- From Inside the Pod -- Mounted
root@kubnet-cp-1:/development# k exec -it web -- bash
/*
root@web:/# df -Th
Filesystem                        Type     Size  Used Avail Use% Mounted on
overlay                           overlay   24G  9.9G   13G  45% /
tmpfs                             tmpfs     64M     0   64M   0% /dev
192.1.6.39:/k8s_storage/devesh   nfs4      50G  3.8G   47G   8% /mnt/devesh
/dev/mapper/ubuntu--vg-ubuntu--lv ext4      24G  9.9G   13G  45% /etc/hosts
shm                               tmpfs     64M     0   64M   0% /dev/shm
tmpfs                             tmpfs    4.7G   12K  4.7G   1% /run/secrets/kubernetes.io/serviceaccount
tmpfs                             tmpfs    2.4G     0  2.4G   0% /proc/acpi
tmpfs                             tmpfs    2.4G     0  2.4G   0% /proc/scsi
tmpfs                             tmpfs    2.4G     0  2.4G   0% /sys/firmware

--Step 7.19.1 (lab) -- Verify the Mount Point
root@web:/# ls /mnt/devesh/
README  index.html

--Step 7.19.2 (lab) -- Enter Into Mount Point
root@web:/# cd /mnt/devesh/

--Step 7.19.3 (lab) -- Verify nginx service
root@web:/mnt/devesh# curl http://localhost:80
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, nginx is successfully installed and working.
Further configuration is required for the web server, reverse proxy,
API gateway, load balancer, content cache, or other features.</p>

<p>For online documentation and support please refer to
<a href="https://nginx.org/">nginx.org</a>.<br/>
To engage with the community please visit
<a href="https://community.nginx.org/">community.nginx.org</a>.<br/>
For enterprise grade support, professional services, additional
security features and capabilities please refer to
<a href="https://f5.com/nginx">f5.com/nginx</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>

--Step 7.19.4 (lab) -- Out From Pod
root@web:/mnt/devesh# exit
exit
*/

--Step 7.20 (lab) -- Verify NFS Mount Point from Worker Node
root@kubnet-worker-1:~# df -Th | grep -i -E "devesh"
/*
192.1.6.39:/k8s_storage/devesh   nfs4      50G  3.8G   47G   8% /var/lib/kubelet/pods/b8214302-9fc1-4ba9-9bc0-ba29ea22cf57/volumes/kubernetes.io~nfs/nfs-pv
*/

--Step 8 (lab) -- Test the Pod over Persistent NFS Volume
root@kubnet-cp-1:~# k exec -it web -- bash
/*

--Step 8.1.1 (lab)
root@web:/# df -Th
Filesystem                        Type     Size  Used Avail Use% Mounted on
overlay                           overlay   24G   10G   13G  45% /
tmpfs                             tmpfs     64M     0   64M   0% /dev
192.1.6.39:/k8s_storage/devesh   nfs4      50G  3.8G   47G   8% /mnt/devesh
/dev/mapper/ubuntu--vg-ubuntu--lv ext4      24G   10G   13G  45% /etc/hosts
shm                               tmpfs     64M     0   64M   0% /dev/shm
tmpfs                             tmpfs    4.7G   12K  4.7G   1% /run/secrets/kubernetes.io/serviceaccount
tmpfs                             tmpfs    2.4G     0  2.4G   0% /proc/acpi
tmpfs                             tmpfs    2.4G     0  2.4G   0% /proc/scsi
tmpfs                             tmpfs    2.4G     0  2.4G   0% /sys/firmware

--Step 8.1.2 (lab)
root@web:/# cd /mnt/devesh/

--Step 8.1.3 (lab)
root@web:/mnt/devesh# ls
README  index.html

--Step 8.1.4 (lab)
root@web:/mnt/devesh# echo "Hello World" > index.html

--Step 8.1.5 (lab)
root@web:/mnt/devesh# cat index.html
Hello World

--Step 8.1.6 (lab)
root@web:/mnt/devesh# cd

--Step 8.1.7 (lab)
root@web:/# vi /etc/nginx/conf.d/default.conf
root   /mnt/devesh;

--Step 8.1.8 (lab)
root@web:/# cat /etc/nginx/conf.d/default.conf | grep -A2 -B2 -i -E "devesh"
    location / {
            #root   /usr/share/nginx/html;
            root   /mnt/devesh;
        index  index.html index.htm;
    }

--Step 8.1.9 (lab)
root@web:/# nginx -s reload
2026/06/16 11:18:56 [notice] 262#262: signal process started

--Step 8.1.10 (lab)
root@web:/# hostname -I
10.0.3.155

--Step 8.1.11 (lab)
root@web:/# curl http://10.0.3.155:80
Hello World

--Step 8.1.12 (lab)
root@web:/# echo "Test 1 " > /mnt/devesh/Test_1.txt

--Step 8.1.13 (lab)
root@web:/# ls /mnt/devesh/Test_1.txt
/mnt/devesh/Test_1.txt

--Step 8.1.14 (lab)
root@web:/# cat /mnt/devesh/Test_1.txt
Test 1

--Step 8.1.15 (lab)
root@web:/# exit
exit
*/

--Step 8.2 (lab)
root@kubnet-cp-1:~# cd /development/

--Step 8.2.1 (lab)
root@kubnet-cp-1:/development# k get pods -o wide
/*
NAME   READY   STATUS    RESTARTS   AGE   IP           NODE                              NOMINATED NODE   READINESS GATES
web    1/1     Running   0          24h   10.0.3.155   kubnet-worker-1.unidev.org.np   <none>           <none>
*/

--Step 8.2.2 (lab)
root@kubnet-cp-1:/development# k delete -f nfs-pod.yaml
/*
pod "web" deleted from default namespace
*/

--Step 8.2.3 (lab)
root@kubnet-cp-1:/development# k get pods -o wide
/*
No resources found in default namespace.
*/

--Step 8.2.4 (lab)
root@kubnet-cp-1:/development# k apply -f nfs-pod.yaml --dry-run=client
/*
pod/web created (dry run)
*/

--Step 8.2.5 (lab)
root@kubnet-cp-1:/development# k apply -f nfs-pod.yaml
/*
pod/web created
*/

--Step 8.2.6 (lab)
root@kubnet-cp-1:/development# k get pods -o wide -w
/*
NAME   READY   STATUS              RESTARTS   AGE   IP           NODE                              NOMINATED NODE   READINESS GATES
web    0/1     ContainerCreating   0          4s    <none>       kubnet-worker-1.unidev.org.np   <none>           <none>
web    1/1     Running             0          7s    10.0.3.170   kubnet-worker-1.unidev.org.np   <none>           <none>
*/

--Step 8.3 (lab)
root@kubnet-cp-1:~# k exec -it web -- bash
/*
root@web:/# df -Th
Filesystem                        Type     Size  Used Avail Use% Mounted on
overlay                           overlay   24G   10G   13G  45% /
tmpfs                             tmpfs     64M     0   64M   0% /dev
192.1.6.39:/k8s_storage/devesh   nfs4      50G  3.8G   47G   8% /mnt/devesh
/dev/mapper/ubuntu--vg-ubuntu--lv ext4      24G   10G   13G  45% /etc/hosts
shm                               tmpfs     64M     0   64M   0% /dev/shm
tmpfs                             tmpfs    4.7G   12K  4.7G   1% /run/secrets/kubernetes.io/serviceaccount
tmpfs                             tmpfs    2.4G     0  2.4G   0% /proc/acpi
tmpfs                             tmpfs    2.4G     0  2.4G   0% /proc/scsi
tmpfs                             tmpfs    2.4G     0  2.4G   0% /sys/firmware

--Step 8.3.1 (lab)
root@web:/# ls -ltr /mnt/devesh/*
-rw-r--r-- 1 root root 12 Jun 15 04:54 /mnt/devesh/README
-rw-r--r-- 1 root root 12 Jun 16 11:15 /mnt/devesh/index.html
-rw-r--r-- 1 root root  8 Jun 16 11:24 /mnt/devesh/Test_1.txt

--Step 8.3.2 (lab)
root@web:/# cat /mnt/devesh/index.html
Hello World

--Step 8.3.3 (lab)
root@web:/# cat /mnt/devesh/Test_1.txt
Test 1

--Step 8.3.4 (lab)
root@web:/# cat /etc/nginx/conf.d/default.conf | grep -A2 -B2 -i -E "devesh"

--Step 8.3.5 (lab)
root@web:/# vi /etc/nginx/conf.d/default.conf
root   /mnt/devesh;

--Step 8.3.6 (lab)
root@web:/# cat /etc/nginx/conf.d/default.conf | grep -A2 -B2 -i -E "devesh"
    location / {
        #root   /usr/share/nginx/html;
        root   /mnt/devesh;
        index  index.html index.htm;
    }

--Step 8.3.7 (lab)
root@web:/# nginx -s reload
2026/06/16 11:36:11 [notice] 190#190: signal process started

--Step 8.3.8 (lab)
root@web:/# hostname -I
10.0.3.170

--Step 8.3.9 (lab)
root@web:/# curl http://10.0.3.170:80
Hello World

--Step 8.3.10 (lab)
root@web:/# exit
exit
*/
