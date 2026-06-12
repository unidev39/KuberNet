--Storage
--Step 1 (Lab)
--Step 0 — Confirm your cluster
root@docker-minikube-n02:~# minikube delete --all
/*
* Deleting "minikube" in docker ...
* Removing /root/.minikube/machines/minikube ...
* Removing /root/.minikube/machines/minikube-m02 ...
* Removed all traces of the "minikube" cluster.
* Successfully deleted all profiles
*/

--Step 1.1 (Lab)
root@docker-minikube-n02:~# minikube start --nodes 3 --cni=cilium --force
/*
* minikube v1.38.1 on Ubuntu 24.04
! minikube skips various validations when --force is supplied; this may lead to unexpected behavior
* Automatically selected the docker driver. Other choices: ssh, none
* The "docker" driver should not be used with root privileges. If you wish to continue as root, use --force.
* If you are running minikube within a VM, consider using --driver=none:
*   https://minikube.sigs.k8s.io/docs/reference/drivers/none/
! Starting v1.39.0, minikube will default to "containerd" container runtime. See #21973 for more info.
* Using Docker driver with root privileges
* Starting "minikube" primary control-plane node in "minikube" cluster
* Pulling base image v0.0.50 ...
* Creating docker container (CPUs=2, Memory=3072MB) ...
* Preparing Kubernetes v1.35.1 on Docker 29.2.1 ...
* Configuring Cilium (Container Networking Interface) ...
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

* Starting "minikube-m03" worker node in "minikube" cluster
* Pulling base image v0.0.50 ...
* Creating docker container (CPUs=2, Memory=3072MB) ...
* Found network options:
  - NO_PROXY=192.168.49.2,192.168.49.3
* Preparing Kubernetes v1.35.1 on Docker 29.2.1 ...
  - env NO_PROXY=192.168.49.2
  - env NO_PROXY=192.168.49.2,192.168.49.3
* Verifying Kubernetes components...
* Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
*/

--Step 1.2 (Lab)
root@docker-minikube-n02:~# k get nodes
/*
NAME           STATUS   ROLES           AGE    VERSION
minikube       Ready    control-plane   3h8m   v1.35.1
minikube-m02   Ready    <none>          3h5m   v1.35.1
minikube-m03   Ready    <none>          3h2m   v1.35.1
*/

--Step 1.3 (Lab)
root@docker-minikube-n02:~# k get storageclass
/*
NAME                 PROVISIONER                RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
standard (default)   k8s.io/minikube-hostpath   Delete          Immediate           false                  3h8m
*/

--Step 1.4 (Lab)
--Create a namespace so cleanup at the end is one command:
root@docker-minikube-n02:~# k create ns kiranashop
/*
namespace/kiranashop created
*/

--Step 2 (Lab)
--Step 1 — emptyDir: watch the ledger vanish
root@docker-minikube-n02:~# mkdir -p /data/ledger

--Step 2.1 (Lab)
root@docker-minikube-n02:~# cat emptydir-pod.yaml
/*
apiVersion: v1
kind: Pod
metadata:
  name: cache-pod
  namespace: kiranashop
spec:
  containers:
  - name: app
    image: nginx:alpine
    volumeMounts:
    - name: cache
      mountPath: /data
  volumes:
  - name: cache
    emptyDir: {}
*/

--Step 2.2 (Lab)
root@docker-minikube-n02:~# k apply -f emptydir-pod.yaml --dry-run=client
/*
pod/cache-pod created (dry run)
*/

--Step 2.3 (Lab)
root@docker-minikube-n02:~# k apply -f emptydir-pod.yaml
/*
pod/cache-pod created
*/

--Step 2.4 (Lab)
root@docker-minikube-n02:~# k wait --for=condition=Ready pod/cache-pod -n kiranashop
/*
pod/cache-pod condition met
*/

--Step 2.5 (Lab)
root@docker-minikube-n02:~# k get pods -n kiranashop -o wide
/*
NAME        READY   STATUS    RESTARTS   AGE   IP            NODE           NOMINATED NODE   READINESS GATES
cache-pod   1/1     Running   0          53s   10.244.2.44   minikube-m03   <none>           <none>
*/

--Step 2.6 (Lab)
root@docker-minikube-n02:~# k exec -n kiranashop cache-pod -- sh -c 'echo "sold 5kg rice" > /data/ledger'

--Step 2.7 (Lab)
root@docker-minikube-n02:~# k exec -n kiranashop cache-pod -- cat /data/ledger
/*
sold 5kg rice
*/

--Step 2.8 (Lab)
--Test 1 — crash the container. nginx runs as PID 1 and handles signals, 
--so killing it makes the container exit; kubelet restarts it in place:
root@docker-minikube-n02:~# k exec -n kiranashop cache-pod -- sh -c 'kill 1'

--Step 2.9 (Lab)
root@docker-minikube-n02:~# sleep 5

--Step 2.10 (Lab) -- Do it from Another Terminal
root@docker-minikube-n02:~#  k get pod cache-pod -n kiranashop --watch
/*
NAME        READY   STATUS             RESTARTS       AGE
cache-pod   1/1     Running            1 (111s ago)   6m58s
cache-pod   0/1     Completed          1 (2m5s ago)   7m12s
cache-pod   0/1     CrashLoopBackOff   1 (14s ago)    7m25s
cache-pod   1/1     Running            2 (16s ago)    7m27s
*/

--Step 2.10.1 (Lab)
root@docker-minikube-n02:~#  k get pod cache-pod -n kiranashop -o wide
/*
NAME        READY   STATUS    RESTARTS      AGE     IP            NODE           NOMINATED NODE   READINESS GATES
cache-pod   1/1     Running   2 (19s ago)   7m30s   10.244.2.44   minikube-m03   <none>           <none>
*/

--Step 2.11 (Lab)
root@docker-minikube-n02:~#  k exec -n kiranashop cache-pod -- cat /data/ledger
/*
sold 5kg rice
*/

--Step 2.12 (Lab) - Open In Another Terminal to Check the Events
--Test 2 — delete the Pod. Recreate it from the same manifest:
root@docker-minikube-n02:~# k get pod cache-pod -n kiranashop --watch -o wide
/*
NAME        READY   STATUS    RESTARTS        AGE   IP            NODE           NOMINATED NODE   READINESS GATES
cache-pod   1/1     Running   2 (4m33s ago)   11m   10.244.2.44   minikube-m03   <none>           <none>
cache-pod   1/1     Terminating   2 (5m15s ago)   12m   10.244.2.44   minikube-m03   <none>           <none>
cache-pod   1/1     Terminating   2 (5m16s ago)   12m   10.244.2.44   minikube-m03   <none>           <none>
cache-pod   0/1     Completed     2               12m   10.244.2.44   minikube-m03   <none>           <none>
cache-pod   0/1     Completed     2               12m   <none>        minikube-m03   <none>           <none>
cache-pod   0/1     Completed     2               12m   <none>        minikube-m03   <none>           <none>
cache-pod   0/1     Completed     2               12m   <none>        minikube-m03   <none>           <none>
cache-pod   0/1     Pending       0               0s    <none>        <none>         <none>           <none>
cache-pod   0/1     Pending       0               0s    <none>        minikube-m02   <none>           <none>
cache-pod   0/1     ContainerCreating   0               1s    <none>        minikube-m02   <none>           <none>
cache-pod   1/1     Running             0               28s   10.244.1.157   minikube-m02   <none>           <none>
*/

--Step 2.13 (Lab) - Now Test
root@docker-minikube-n02:~# k delete pod cache-pod -n kiranashop
/*
pod "cache-pod" deleted from kiranashop namespace
*/

--Step 2.14 (Lab)
root@docker-minikube-n02:~# k apply -f emptydir-pod.yaml
/*
pod/cache-pod created
*/

--Step 2.15 (Lab)
root@docker-minikube-n02:~# k wait --for=condition=Ready pod/cache-pod -n kiranashop
/*
pod/cache-pod condition met
*/

--Step 2.16 (Lab)
root@docker-minikube-n02:~# k exec -n kiranashop cache-pod -- cat /data/ledger
/*
cat: can't open '/data/ledger': No such file or directory
command terminated with exit code 1
*/

--Step 2.17 (Lab)
--✓ Knowledge check — call it out
--Q1. Data in an emptyDir survives a container crash and restart. T/F?                  => A1. True
--Q2. Data in an emptyDir survives deletion of the Pod. T/F?                            => A2. False
--Q3. A hostPath volume keeps its data if the Pod is rescheduled to another node. T/F?  => A3. False
--Q4. A Volume is attached to the Pod, so all its containers can share it. T/F?         => A4. True

--Step 3 (Lab)
--Step 2 — PV + PVC: a ledger that outlives the Pod
root@docker-minikube-n02:~# mkdir -p /mnt/lab-data
root@docker-minikube-n02:~# vi pv.yaml
/*
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-local
spec:
  capacity:
    storage: 5Gi
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  hostPath:
    path: /mnt/lab-data
*/

--Step 3.1 (Lab)
root@docker-minikube-n02:~# vi pvc.yaml
/*
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data
  namespace: kiranashop
spec:
  storageClassName: manual      # must match the PV's label to avoid default storage class hijacking
  accessModes:
  - ReadWriteOnce               # must match what the PV offers (RWO)
  resources:
    requests:
      storage: 5Gi              # must be ≤ what the PV has (5Gi)
*/

--Step 3.2 (Lab)
root@docker-minikube-n02:~# k apply -f pv.yaml -f pvc.yaml --dry-run=client
/*
persistentvolume/pv-local created (dry run)
persistentvolumeclaim/data created (dry run)
*/

--Step 3.3 (Lab)
root@docker-minikube-n02:~# k apply -f pv.yaml -f pvc.yaml
/*
persistentvolume/pv-local created
persistentvolumeclaim/data created
*/

--Step 3.4 (Lab)
root@docker-minikube-n02:~# k get pv,pvc -n kiranashop
/*
NAME                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM             STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
persistentvolume/pv-local   5Gi        RWO            Retain           Bound    kiranashop/data   manual         <unset>                          40s

NAME                         STATUS   VOLUME     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
persistentvolumeclaim/data   Bound    pv-local   5Gi        RWO            manual         <unset>                 39s
*/

--Step 3.5 (Lab)
root@docker-minikube-n02:~# k get pv,pvc -n kiranashop -o wide
/*
NAME                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM             STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE   VOLUMEMODE
persistentvolume/pv-local   5Gi        RWO            Retain           Bound    kiranashop/data   manual         <unset>                          47s   Filesystem

NAME                         STATUS   VOLUME     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE   VOLUMEMODE
persistentvolumeclaim/data   Bound    pv-local   5Gi        RWO            manual         <unset>                 46s   Filesystem
*/

--Step 3.6 (Lab)
--# write through the first Pod
root@docker-minikube-n02:~# vi writer-pod.yaml
/*
apiVersion: v1
kind: Pod
metadata:
  name: writer
  namespace: kiranashop
spec:
  containers:
  - name: alpine-writer
    image: nginx:alpine
    volumeMounts:
    - name: store
      mountPath: /data
  volumes:
  - name: store
    persistentVolumeClaim:
      claimName: data
*/

--Step 3.7 (Lab)
root@docker-minikube-n02:~# k apply -f writer-pod.yaml --dry-run=client
/*
pod/writer created (dry run)
*/

--Step 3.8 (Lab)
root@docker-minikube-n02:~# k apply -f writer-pod.yaml
/*
pod/writer created
*/

--Step 3.9 (Lab)
root@docker-minikube-n02:~# k get pods -n kiranashop -o wide
/*
NAME        READY   STATUS    RESTARTS   AGE   IP             NODE           NOMINATED NODE   READINESS GATES
cache-pod   1/1     Running   0          21m   10.244.1.157   minikube-m02   <none>           <none>
writer      1/1     Running   0          42s   10.244.2.6     minikube-m03   <none>           <none>
*/

--Step 3.10 (Lab)
root@docker-minikube-n02:~# k exec -n kiranashop writer -- sh -c 'echo "sold 5kg rice" > /data/ledger'

--Step 3.11 (Lab)
root@docker-minikube-n02:~# k exec -n kiranashop writer -- cat /data/ledger
/*
sold 5kg rice
*/

--Step 3.12 (Lab)
root@docker-minikube-n02:~# k delete pod writer -n kiranashop
/*
pod "writer" deleted from kiranashop namespace
*/

--Step 3.13 (Lab)
root@docker-minikube-n02:~# k get pod writer -n kiranashop --watch -o wide
/*
NAME     READY   STATUS    RESTARTS   AGE     IP           NODE           NOMINATED NODE   READINESS GATES
writer   1/1     Running   0          2m29s   10.244.2.6   minikube-m03   <none>           <none>
writer   1/1     Terminating   0          2m45s   10.244.2.6   minikube-m03   <none>           <none>
writer   1/1     Terminating   0          2m45s   10.244.2.6   minikube-m03   <none>           <none>
writer   0/1     Completed     0          2m47s   10.244.2.6   minikube-m03   <none>           <none>
writer   0/1     Completed     0          2m47s   <none>       minikube-m03   <none>           <none>
*/

--Step 3.14 (Lab)
--# brand-new Pod, same PVC (copy writer's manifest, rename to reader)
root@docker-minikube-n02:~# vi reader-pod.yaml
/*
apiVersion: v1
kind: Pod
metadata:
  name: reader
  namespace: kiranashop
spec:
  containers:
  - name: alpine-reader
    image: nginx:alpine
    volumeMounts:
    - name: store
      mountPath: /data
  volumes:
  - name: store
    persistentVolumeClaim:
      claimName: data
*/

--Step 3.15 (Lab)
root@docker-minikube-n02:~# k apply -f reader-pod.yaml --dry-run=client
/*
pod/reader created (dry run)
*/

--Step 3.16 (Lab)
root@docker-minikube-n02:~# k apply -f reader-pod.yaml
/*
pod/reader created
*/

--Step 3.17 (Lab)
root@docker-minikube-n02:~# k get pod reader -n kiranashop --watch -o wide
/*
NAME     READY   STATUS    RESTARTS   AGE     IP             NODE           NOMINATED NODE   READINESS GATES
reader   1/1     Running   0          4m30s   10.244.2.133   minikube-m03   <none>           <none>
*/

--Step 3.18 (Lab)
root@docker-minikube-n02:~# k exec -n kiranashop reader -- cat /data/ledger
/*
sold 5kg rice
*/

--Step 4 (Lab)
--Step 3 — Debug detour: the claim that never binds
root@docker-minikube-n02:~# vi broken.yaml
/*
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-debug
spec:
  capacity:
    storage: 5Gi
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: /mnt/debug-data
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: broken
  namespace: kiranashop
spec:
  storageClassName: ""
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 5Gi
*/

--Step 4.1 (Lab)
root@docker-minikube-n02:~# k apply -f broken.yaml --dry-run=client
/*
persistentvolume/pv-debug created (dry run)
persistentvolumeclaim/broken created (dry run)
*/

--Step 4.2 (Lab)
root@docker-minikube-n02:~# k apply -f broken.yaml
/*
persistentvolume/pv-debug created
persistentvolumeclaim/broken created
*/

--Step 4.3 (Lab)
root@docker-minikube-n02:~# k get pv pv-debug && kubectl get pvc broken -n kiranashop
/*
NAME       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
pv-debug   5Gi        RWO            Retain           Available                          <unset>                          10s

NAME     STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
broken   Pending                                                     <unset>                 11s
*/

--Step 4.4 (Lab)
root@docker-minikube-n02:~# k describe pvc broken -n kiranashop
/*
Name:          broken
Namespace:     kiranashop
StorageClass:
Status:        Pending
Volume:
Labels:        <none>
Annotations:   <none>
Finalizers:    [kubernetes.io/pvc-protection]
Capacity:
Access Modes:
VolumeMode:    Filesystem
Used By:       <none>
Events:
  Type    Reason         Age                From                         Message
  ----    ------         ----               ----                         -------
  Normal  FailedBinding  12s (x3 over 37s)  persistentvolume-controller  no persistent volumes available for this claim and no storage class is set
*/

--Step 4.5 (Lab)
root@docker-minikube-n02:~# k patch pvc broken -n kiranashop -p '{"spec":{"accessModes":["ReadWriteOnce"]}}'
/*
The PersistentVolumeClaim "broken" is invalid: spec: Forbidden: spec is immutable after creation except resources.requests and volumeAttributesClassName for bound claims
@@ -1,6 +1,6 @@
 {
  "AccessModes": [
-  "ReadWriteMany"
+  "ReadWriteOnce"
  ],
  "Selector": null,
  "Resources": {
*/

--Step 4.6 (Lab)
root@docker-minikube-n02:~# k delete pvc broken -n kiranashop
/*
persistentvolumeclaim "broken" deleted from kiranashop namespace
*/

--Step 4.7 (Lab) --Applying Fix
root@docker-minikube-n02:~# vi fixed-pvc.yaml
/*
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: broken
  namespace: kiranashop
spec:
  storageClassName: ""
  accessModes:
  - ReadWriteOnce               # FIXED: Changed from ReadWriteMany to ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
*/

--Step 4.8 (Lab)
root@docker-minikube-n02:~# k apply -f fixed-pvc.yaml --dry-run=client
/*
persistentvolumeclaim/broken created (dry run)
*/

--Step 4.9 (Lab)
root@docker-minikube-n02:~# k apply -f fixed-pvc.yaml
/*
persistentvolumeclaim/broken created
*/

--Step 4.10 (Lab)
root@docker-minikube-n02:~# k get pv pv-debug && kubectl get pvc broken -n kiranashop
/*
NAME       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM               STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
pv-debug   5Gi        RWO            Retain           Bound    kiranashop/broken                  <unset>                          5m32s

NAME     STATUS   VOLUME     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
broken   Bound    pv-debug   5Gi        RWO                           <unset>                 11s
*/

--Step 5 (Lab)
--Step 4 — Dynamic provisioning: a PV from nothing
root@docker-minikube-n02:~# vi dynamic-pvc.yaml
root@docker-minikube-n02:~# cat dynamic-pvc.yaml
/*
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: dyn-data
  namespace: kiranashop
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
*/

--Step 5.1 (Lab)
root@docker-minikube-n02:~# k apply -f dynamic-pvc.yaml --dry-run=client
/*
persistentvolumeclaim/dyn-data created (dry run)
*/

--Step 5.2 (Lab)
root@docker-minikube-n02:~# k apply -f dynamic-pvc.yaml
/*
persistentvolumeclaim/dyn-data created
*/

--Step 5.3 (Lab)
root@docker-minikube-n02:~# k get pvc dyn-data -n kiranashop
/*
NAME       STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
dyn-data   Bound    pvc-aae2c404-dfed-4565-aaaa-f1b2ca371d25   2Gi        RWO            standard       <unset>                 8s
*/

--Step 5.4 (Lab)
root@docker-minikube-n02:~# k get pv
/*
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                 STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
pv-debug                                   5Gi        RWO            Retain           Bound    kiranashop/broken                    <unset>                          11m
pv-local                                   5Gi        RWO            Retain           Bound    kiranashop/data       manual         <unset>                          36m
pvc-aae2c404-dfed-4565-aaaa-f1b2ca371d25   2Gi        RWO            Delete           Bound    kiranashop/dyn-data   standard       <unset>                          15s
*/

--Step 5.5 (Lab)
root@docker-minikube-n02:~# k get pv -o wide
/*
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                 STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE   VOLUMEMODE
pv-debug                                   5Gi        RWO            Retain           Bound    kiranashop/broken                    <unset>                          11m   Filesystem
pv-local                                   5Gi        RWO            Retain           Bound    kiranashop/data       manual         <unset>                          36m   Filesystem
pvc-aae2c404-dfed-4565-aaaa-f1b2ca371d25   2Gi        RWO            Delete           Bound    kiranashop/dyn-data   standard       <unset>                          19s   Filesystem
*/

--Step 5.6 (Lab)
-- Live poll — static, dynamic, or which knob?
--Q-A. A dev needs a 20Gi disk right now and there's no admin around.    => Dynamic Provisioning
--Q-B. You want all unspecified claims to land on fast SSD by default.   => storageclass.kubernetes.io/is-default-class: "true"
--Q-C. Compliance says this volume's data must never be auto-deleted.    => persistentVolumeReclaimPolicy: Retain
--Q-D. An admin pre-creates a specific NFS-backed PV for one legacy app. => Static Provisioning

--Step 6 (Lab)
--Step 5 — StatefulSet: one ledger per replica
root@docker-minikube-n02:~# vi statefulset.yaml
/*
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mydb
  namespace: kiranashop
spec:
  serviceName: mydb
  replicas: 3
  selector:
    matchLabels:
      app: mydb
  template:
    metadata:
      labels:
        app: mydb
    spec:
      containers:
      - name: db
        image: nginx:alpine
        volumeMounts:
        - name: data          # ←  match the template name inside volumeClaimTemplates
          mountPath: /var/lib/db
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]   #  single-node read-write for databases
      storageClassName: standard       #  standard is the minikube default class (or omit the line completely)
      resources:
        requests:
          storage: 1Gi
*/

--Step 6.1 (Lab)
root@docker-minikube-n02:~# k apply -f statefulset.yaml --dry-run=client
/*
statefulset.apps/mydb created (dry run)
*/

--Step 6.2 (Lab)
root@docker-minikube-n02:~# k apply -f statefulset.yaml
/*
statefulset.apps/mydb created
*/

--Step 6.3 (Lab)
root@docker-minikube-n02:~# k rollout status statefulset/mydb -n kiranashop
/*
Waiting for 2 pods to be ready...
Waiting for 1 pods to be ready...
Waiting for 1 pods to be ready...
partitioned roll out complete: 3 new pods have been updated...
*/

--Step 6.4 (Lab)
root@docker-minikube-n02:~# k get pvc -n kiranashop
/*
NAME          STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
broken        Bound    pv-debug                                   5Gi        RWO                           <unset>                 16m
data          Bound    pv-local                                   5Gi        RWO            manual         <unset>                 47m
data-mydb-0   Bound    pvc-34abc890-b3e6-45ef-a6b4-9f9a8e9c6375   1Gi        RWO            standard       <unset>                 60s
data-mydb-1   Bound    pvc-8c40b744-2552-49c8-af38-dd0dccdaaf2a   1Gi        RWO            standard       <unset>                 53s
data-mydb-2   Bound    pvc-142456e3-89ea-41cf-99f9-fe4f44b37cf2   1Gi        RWO            standard       <unset>                 47s
dyn-data      Bound    pvc-aae2c404-dfed-4565-aaaa-f1b2ca371d25   2Gi        RWO            standard       <unset>                 10m
*/

--Step 6.5 (Lab)
root@docker-minikube-n02:~# k get pvc -n kiranashop -o wide
/*
NAME          STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE   VOLUMEMODE
broken        Bound    pv-debug                                   5Gi        RWO                           <unset>                 16m   Filesystem
data          Bound    pv-local                                   5Gi        RWO            manual         <unset>                 47m   Filesystem
data-mydb-0   Bound    pvc-34abc890-b3e6-45ef-a6b4-9f9a8e9c6375   1Gi        RWO            standard       <unset>                 65s   Filesystem
data-mydb-1   Bound    pvc-8c40b744-2552-49c8-af38-dd0dccdaaf2a   1Gi        RWO            standard       <unset>                 58s   Filesystem
data-mydb-2   Bound    pvc-142456e3-89ea-41cf-99f9-fe4f44b37cf2   1Gi        RWO            standard       <unset>                 52s   Filesystem
dyn-data      Bound    pvc-aae2c404-dfed-4565-aaaa-f1b2ca371d25   2Gi        RWO            standard       <unset>                 10m   Filesystem
*/

--Step 6.6 (Lab)
root@docker-minikube-n02:~# k exec -n kiranashop mydb-1 -- sh -c 'echo "I am replica 1 data" > /var/lib/db/whoami'

--Step 6.7 (Lab)
root@docker-minikube-n02:~# k exec -n kiranashop mydb-1 -- cat /var/lib/db/whoami
/*
I am replica 1 data
*/

--Step 6.8 (Lab)
root@docker-minikube-n02:~# k delete pod mydb-1 -n kiranashop
/*
pod "mydb-1" deleted from kiranashop namespace
*/

--Step 6.9 (Lab)
root@docker-minikube-n02:~# k wait --for=condition=Ready pod/mydb-1 -n kiranashop
/*
pod/mydb-1 condition met
*/

--Step 6.10 (Lab)
root@docker-minikube-n02:~# k get pod mydb-1 -n kiranashop -o jsonpath='{..claimName}'
/*
data-mydb-1
*/

--Step 6.11 (Lab)
root@docker-minikube-n02:~# k exec -n kiranashop mydb-1 -- cat /var/lib/db/whoami
/*
I am replica 1 data
*/

--Step 6.12 (Lab)
--Spot-the-bug — 2 issues, 60 seconds
--A teammate's StatefulSet: Pods stuck Pending, no storage made. Find both bugs.

/*
kind: StatefulSet
spec:
  template:
    spec:
      containers:
      - name: db
        volumeMounts:
        - name: store
          mountPath: /var/lib/db
  volumeClaimTemplates:
  - metadata: { name: data }
    spec:
      storageClassName: fast
      accessModes: ["ReadWriteOnce"]
      resources:
        requests: { storage: 1Gi }

Bug 1: class fast doesn't exist → no provisioner runs → PVCs stay Pending. Bug 2: the mount references store but the template is named data — even if it provisioned, nothing would mount.
*/

--Step 6.13 (Lab)
root@docker-minikube-n02:~# vi fix_statefulset.yaml
/*
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mydb-fixed
  namespace: kiranashop
spec:
  serviceName: mydb-fixed
  replicas: 3
  selector:
    matchLabels:
      app: mydb
  template:
    metadata:
      labels:
        app: mydb
    spec:
      containers:
      - name: db
        image: nginx:alpine
        volumeMounts:
        - name: data          #  Now matches the volumeClaimTemplate name below
          mountPath: /var/lib/db
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      #  Removed 'storageClassName: fast' so it safely hits the cluster default (e.g., standard)
      resources:
        requests:
          storage: 1Gi
*/

--Step 6.14 (Lab)
root@docker-minikube-n02:~# k apply -f fix_statefulset.yaml --dry-run=client
/*
statefulset.apps/mydb-fixed created (dry run)
*/

--Step 6.15 (Lab)
root@docker-minikube-n02:~# k apply -f fix_statefulset.yaml
/*
statefulset.apps/mydb-fixed created
*/

--Step 6.16 (Lab)
root@docker-minikube-n02:~# k rollout status statefulset/mydb-fixed -n kiranashop
/*
partitioned roll out complete: 3 new pods have been updated...
*/

--Step 6.17 (Lab)
root@docker-minikube-n02:~# k get pvc -n kiranashop
/*
NAME                STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
broken              Bound    pv-debug                                   5Gi        RWO                           <unset>                 28m
data                Bound    pv-local                                   5Gi        RWO            manual         <unset>                 58m
data-mydb-0         Bound    pvc-34abc890-b3e6-45ef-a6b4-9f9a8e9c6375   1Gi        RWO            standard       <unset>                 12m
data-mydb-1         Bound    pvc-8c40b744-2552-49c8-af38-dd0dccdaaf2a   1Gi        RWO            standard       <unset>                 12m
data-mydb-2         Bound    pvc-142456e3-89ea-41cf-99f9-fe4f44b37cf2   1Gi        RWO            standard       <unset>                 12m
data-mydb-fixed-0   Bound    pvc-38509f1c-79d7-4543-b59d-04478d4821d7   1Gi        RWO            standard       <unset>                 63s
data-mydb-fixed-1   Bound    pvc-58d4200c-87d5-45f7-baed-8ab688eda412   1Gi        RWO            standard       <unset>                 59s
data-mydb-fixed-2   Bound    pvc-58925095-1092-4ab5-a1bd-f179c40413e5   1Gi        RWO            standard       <unset>                 54s
dyn-data            Bound    pvc-aae2c404-dfed-4565-aaaa-f1b2ca371d25   2Gi        RWO            standard       <unset>                 22m
*/

--Step 6.18 (Lab)
root@docker-minikube-n02:~# k get pvc -n kiranashop -o wide
/*
NAME                STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE   VOLUMEMODE
broken              Bound    pv-debug                                   5Gi        RWO                           <unset>                 28m   Filesystem
data                Bound    pv-local                                   5Gi        RWO            manual         <unset>                 58m   Filesystem
data-mydb-0         Bound    pvc-34abc890-b3e6-45ef-a6b4-9f9a8e9c6375   1Gi        RWO            standard       <unset>                 12m   Filesystem
data-mydb-1         Bound    pvc-8c40b744-2552-49c8-af38-dd0dccdaaf2a   1Gi        RWO            standard       <unset>                 12m   Filesystem
data-mydb-2         Bound    pvc-142456e3-89ea-41cf-99f9-fe4f44b37cf2   1Gi        RWO            standard       <unset>                 12m   Filesystem
data-mydb-fixed-0   Bound    pvc-38509f1c-79d7-4543-b59d-04478d4821d7   1Gi        RWO            standard       <unset>                 73s   Filesystem
data-mydb-fixed-1   Bound    pvc-58d4200c-87d5-45f7-baed-8ab688eda412   1Gi        RWO            standard       <unset>                 69s   Filesystem
data-mydb-fixed-2   Bound    pvc-58925095-1092-4ab5-a1bd-f179c40413e5   1Gi        RWO            standard       <unset>                 64s   Filesystem
dyn-data            Bound    pvc-aae2c404-dfed-4565-aaaa-f1b2ca371d25   2Gi        RWO            standard       <unset>                 22m   Filesystem
*/

--Step 6.18 (Lab)
root@docker-minikube-n02:~# k exec -n kiranashop mydb-fixed-1 -- sh -c 'echo "I am fixed-replica 1 data" > /var/lib/db/whoami'

--Step 6.19 (Lab)
root@docker-minikube-n02:~# k exec -n kiranashop mydb-fixed-1 -- cat /var/lib/db/whoami
/*
I am fixed-replica 1 data
*/

--Step 6.20 (Lab)
root@docker-minikube-n02:~# k get pv
/*
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                          STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
pv-debug                                   5Gi        RWO            Retain           Bound    kiranashop/broken                             <unset>                          37m
pv-local                                   5Gi        RWO            Retain           Bound    kiranashop/data                manual         <unset>                          62m
pvc-142456e3-89ea-41cf-99f9-fe4f44b37cf2   1Gi        RWO            Delete           Bound    kiranashop/data-mydb-2         standard       <unset>                          16m
pvc-34abc890-b3e6-45ef-a6b4-9f9a8e9c6375   1Gi        RWO            Delete           Bound    kiranashop/data-mydb-0         standard       <unset>                          16m
pvc-38509f1c-79d7-4543-b59d-04478d4821d7   1Gi        RWO            Delete           Bound    kiranashop/data-mydb-fixed-0   standard       <unset>                          4m57s
pvc-58925095-1092-4ab5-a1bd-f179c40413e5   1Gi        RWO            Delete           Bound    kiranashop/data-mydb-fixed-2   standard       <unset>                          4m48s
pvc-58d4200c-87d5-45f7-baed-8ab688eda412   1Gi        RWO            Delete           Bound    kiranashop/data-mydb-fixed-1   standard       <unset>                          4m53s
pvc-8c40b744-2552-49c8-af38-dd0dccdaaf2a   1Gi        RWO            Delete           Bound    kiranashop/data-mydb-1         standard       <unset>                          16m
pvc-aae2c404-dfed-4565-aaaa-f1b2ca371d25   2Gi        RWO            Delete           Bound    kiranashop/dyn-data            standard       <unset>                          26m
*/

--Step 6.21 (Lab)
root@docker-minikube-n02:~# k get pv -o wide
/*
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                          STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE    VOLUMEMODE
pv-debug                                   5Gi        RWO            Retain           Bound    kiranashop/broken                             <unset>                          37m    Filesystem
pv-local                                   5Gi        RWO            Retain           Bound    kiranashop/data                manual         <unset>                          62m    Filesystem
pvc-142456e3-89ea-41cf-99f9-fe4f44b37cf2   1Gi        RWO            Delete           Bound    kiranashop/data-mydb-2         standard       <unset>                          16m    Filesystem
pvc-34abc890-b3e6-45ef-a6b4-9f9a8e9c6375   1Gi        RWO            Delete           Bound    kiranashop/data-mydb-0         standard       <unset>                          16m    Filesystem
pvc-38509f1c-79d7-4543-b59d-04478d4821d7   1Gi        RWO            Delete           Bound    kiranashop/data-mydb-fixed-0   standard       <unset>                          5m9s   Filesystem
pvc-58925095-1092-4ab5-a1bd-f179c40413e5   1Gi        RWO            Delete           Bound    kiranashop/data-mydb-fixed-2   standard       <unset>                          5m     Filesystem
pvc-58d4200c-87d5-45f7-baed-8ab688eda412   1Gi        RWO            Delete           Bound    kiranashop/data-mydb-fixed-1   standard       <unset>                          5m5s   Filesystem
pvc-8c40b744-2552-49c8-af38-dd0dccdaaf2a   1Gi        RWO            Delete           Bound    kiranashop/data-mydb-1         standard       <unset>                          16m    Filesystem
pvc-aae2c404-dfed-4565-aaaa-f1b2ca371d25   2Gi        RWO            Delete           Bound    kiranashop/dyn-data            standard       <unset>                          26m    Filesystem
*/
