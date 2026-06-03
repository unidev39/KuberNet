--Step 1 (Lab)
--Clean Up
--When you are done, tear down the minikube cluster to free up resources:
root@minikube-n1:~# minikube delete --all
/*
* Deleting "minikube" in docker ...
* Removing /root/.minikube/machines/minikube ...
* Removing /root/.minikube/machines/minikube-m02 ...
* Removed all traces of the "minikube" cluster.
* Successfully deleted all profiles
*/

--Step 1.0 (Lab)
--Prerequisites
--minikube installed (install guide)
root@minikube-n1:~# minikube version
/*
minikube version: v1.38.1
commit: c93a4cb9311efc66b90d33ea03f75f2c4120e9b0
*/

--Step 1.1 (Lab)
--kubectl installed (install guide)
root@minikube-n1:~# kubectl version
/*
Client Version: v1.36.0
Kustomize Version: v5.8.1
The connection to the server localhost:8080 was refused - did you specify the right host or port?
*/

--Step 1.2 (Lab)
--Docker running on your machine
root@minikube-n1:~# docker version
/*
Client: Docker Engine - Community
 Version:           29.5.2
 API version:       1.54
 Go version:        go1.26.3
 Git commit:        79eb04c
 Built:             Wed May 20 14:42:18 2026
 OS/Arch:           linux/amd64
 Context:           default

Server: Docker Engine - Community
 Engine:
  Version:          29.5.2
  API version:      1.54 (minimum version 1.40)
  Go version:       go1.26.3
  Git commit:       568f755
  Built:            Wed May 20 14:42:18 2026
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          v2.2.4
  GitCommit:        193637f7ee8ae5f5aa5248f49e7baa3e6164966e
 runc:
  Version:          1.3.5
  GitCommit:        v1.3.5-0-g488fc13e
 docker-init:
  Version:          0.19.0
  GitCommit:        de40ad0
*/

--Step 1.3 (Lab)
root@minikube-n1:~# systemctl status docker
/*
● docker.service - Docker Application Container Engine
     Loaded: loaded (/usr/lib/systemd/system/docker.service; enabled; preset: enabled)
     Active: active (running) since Sun 2026-05-31 16:49:08 +0545; 1 day 21h ago
TriggeredBy: ● docker.socket
       Docs: https://docs.docker.com
   Main PID: 8509 (dockerd)
      Tasks: 20
     Memory: 60.2M (peak: 95.1M)
        CPU: 3min 5.826s
     CGroup: /system.slice/docker.service
             └─8509 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock

May 31 17:00:39 minikube-n1.unidev.org.np dockerd[8509]: time="2026-05-31T17:00:39.266547385+05:45" level=info msg="image pulled" digest="sha256:eb4fec00e8ad70adf8e6436f195cc429825ffb85f>
May 31 17:00:42 minikube-n1.unidev.org.np dockerd[8509]: time="2026-05-31T17:00:42.433168462+05:45" level=info msg="No non-localhost DNS nameservers are left in resolv.conf. Using defaul>
May 31 17:00:42 minikube-n1.unidev.org.np dockerd[8509]: time="2026-05-31T17:00:42.438060870+05:45" level=info msg="sbJoin: gwep4 ''->'4e31dd208945', gwep6 ''->''" eid=4e31dd208945 ep=mi>
May 31 17:00:42 minikube-n1.unidev.org.np dockerd[8509]: time="2026-05-31T17:00:42.671227228+05:45" level=info msg="received task-delete event from containerd" container=e2362b49626a8dc5>
May 31 17:00:44 minikube-n1.unidev.org.np dockerd[8509]: time="2026-05-31T17:00:44.351936268+05:45" level=info msg="No non-localhost DNS nameservers are left in resolv.conf. Using defaul>
May 31 17:00:44 minikube-n1.unidev.org.np dockerd[8509]: time="2026-05-31T17:00:44.379414673+05:45" level=info msg="sbJoin: gwep4 ''->'58aad22afddb', gwep6 ''->''" eid=58aad22afddb ep=su>
May 31 17:00:52 minikube-n1.unidev.org.np dockerd[8509]: time="2026-05-31T17:00:52.667427742+05:45" level=info msg="received task-delete event from containerd" container=0f9fa259343020eb>
May 31 17:00:56 minikube-n1.unidev.org.np dockerd[8509]: time="2026-05-31T17:00:56.860942023+05:45" level=info msg="sbJoin: gwep4 ''->'af08dd481e59', gwep6 ''->''" eid=af08dd481e59 ep=mi>
Jun 02 14:35:19 minikube-n1.unidev.org.np dockerd[8509]: time="2026-06-02T14:35:19.034945646+05:45" level=info msg="received task-delete event from containerd" container=2951ec5a1a9df10d>
Jun 02 14:35:33 minikube-n1.unidev.org.np dockerd[8509]: time="2026-06-02T14:35:33.918850386+05:45" level=info msg="received task-delete event from containerd" container=08c176db9bdea571>
lines 1-22/22 (END)
*/

--Step 2 (Lab)
--Environment Setup
--# Start a 2-node minikube cluster
root@minikube-n1:~# minikube start --nodes 2 --driver=docker
/*
* minikube v1.38.1 on Ubuntu 24.04
* Using the docker driver based on user configuration
* The "docker" driver should not be used with root privileges. If you wish to continue as root, use --force.
* If you are running minikube within a VM, consider using --driver=none:
*   https://minikube.sigs.k8s.io/docs/reference/drivers/none/

X Exiting due to DRV_AS_ROOT: The "docker" driver should not be used with root privileges.
*/

--Step 2.1 (Lab)
root@minikube-n1:~# minikube start --nodes 2 --driver=docker --force
/*
* minikube v1.38.1 on Ubuntu 24.04
! minikube skips various validations when --force is supplied; this may lead to unexpected behavior
* Using the docker driver based on user configuration
* The "docker" driver should not be used with root privileges. If you wish to continue as root, use --force.
* If you are running minikube within a VM, consider using --driver=none:
*   https://minikube.sigs.k8s.io/docs/reference/drivers/none/
! Starting v1.39.0, minikube will default to "containerd" container runtime. See #21973 for more info.
* Using Docker driver with root privileges
* Starting "minikube" primary control-plane node in "minikube" cluster
* Pulling base image v0.0.50 ...
* Creating docker container (CPUs=2, Memory=3072MB) ...
* Preparing Kubernetes v1.35.1 on Docker 29.2.1 ...
* Configuring CNI (Container Networking Interface) ...
* Verifying Kubernetes components...
  - Using image gcr.io/k8s-minikube/storage-provisioner:v5
* Enabled addons: default-storageclass, storage-provisioner

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

--Step 2.2 (Lab)
--# Verify both nodes are Ready
root@minikube-n1:~# kubectl get nodes
/*
NAME           STATUS   ROLES           AGE     VERSION
minikube       Ready    control-plane   4m36s   v1.35.1
minikube-m02   Ready    <none>          2m4s    v1.35.1
*/

--Step 2.3 (Lab)
root@minikube-n1:~#  kubectl get nodes -o wide
/*
NAME           STATUS   ROLES           AGE    VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE                         KERNEL-VERSION      CONTAINER-RUNTIME
minikube       Ready    control-plane   151m   v1.35.1   192.168.49.2   <none>        Debian GNU/Linux 12 (bookworm)   6.8.0-111-generic   docker://29.2.1
minikube-m02   Ready    <none>          148m   v1.35.1   192.168.49.3   <none>        Debian GNU/Linux 12 (bookworm)   6.8.0-111-generic   docker://29.2.1
*/

--Step 2.4 (Lab)
root@minikube-n1:~# kubectl get pods -A
/*
NAMESPACE     NAME                               READY   STATUS    RESTARTS   AGE
kube-system   coredns-7d764666f9-pjsv6           1/1     Running   0          151m
kube-system   etcd-minikube                      1/1     Running   0          151m
kube-system   kindnet-7rlvf                      1/1     Running   0          149m
kube-system   kindnet-vfnvt                      1/1     Running   0          151m
kube-system   kube-apiserver-minikube            1/1     Running   0          151m
kube-system   kube-controller-manager-minikube   1/1     Running   0          151m
kube-system   kube-proxy-pjrkg                   1/1     Running   0          149m
kube-system   kube-proxy-wd6h7                   1/1     Running   0          151m
kube-system   kube-scheduler-minikube            1/1     Running   0          151m
kube-system   storage-provisioner                1/1     Running   0          151m
*/

--Step 3 (Lab) - # Enable metrics-server (needed for Task 2)
root@minikube-n1:~# kubectl config current-context
/*
minikube
*/

--Step 3.1 (Lab)
root@minikube-n1:~# minikube addons enable metrics-server -p minikube
/*
* metrics-server is an addon maintained by Kubernetes. For any concerns contact minikube on GitHub.
You can view the list of minikube maintainers at: https://github.com/kubernetes/minikube/blob/master/OWNERS
  - Using image registry.k8s.io/metrics-server/metrics-server:v0.8.1
* The 'metrics-server' addon is enabled
*/

--Step 3.1 (Lab)
--# Wait ~60 seconds, then verify metrics-server works
root@minikube-n1:~# kubectl top nodes
/*
error: Metrics API not available
*/

root@minikube-n1:~# kubectl top nodes
/*
NAME           CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)
minikube       471m         23%      652Mi           13%
minikube-m02   211m         10%      212Mi           4%
*/


--Task 1 — Self-Healing: Add Health Probes
--1 Deploy the app without probes and see the problem
--Task 1a — Deploy without probes, see the problem
root@minikube-n1:~# vi broken-pod.yaml
/*
apiVersion: v1
kind: Pod
metadata:
  name: api-no-probes
  labels:
    app: api-server
spec:
  containers:
  - name: web-app
    image: registry.k8s.io/e2e-test-images/agnhost:2.43
    args:
    - liveness
    ports:
    - containerPort: 8080
*/

root@minikube-n1:~# kubectl apply -f broken-pod.yaml --dry-run=client
/*
pod/api-no-probes created (dry run)
*/

root@minikube-n1:~# kubectl apply -f broken-pod.yaml
/*
pod/api-no-probes created
*/

--Notice that even after 10, 20, or 60 seconds, the Pod status stubbornly reads STATUS: Running and RESTARTS: 0
root@minikube-n1:~# kubectl get pods api-no-probes -w -o wide
/*
NAME            READY   STATUS    RESTARTS   AGE     IP           NODE           NOMINATED NODE   READINESS GATES
api-no-probes   1/1     Running   0          4m50s   10.244.1.3   minikube-m02   <none>           <none>
*/

root@minikube-n1:~# kubectl describe pods api-no-probes
/*
Name:             api-no-probes
Namespace:        default
Priority:         0
Service Account:  default
Node:             minikube-m02/192.168.49.3
Start Time:       Tue, 02 Jun 2026 17:38:34 +0545
Labels:           app=api-server
Annotations:      <none>
Status:           Running
IP:               10.244.1.3
IPs:
  IP:  10.244.1.3
Containers:
  web-app:
    Container ID:  docker://e44eeba10eddb05255cfe52132dd052fc729f3277ab1d7ffa084a557c48fb2de
    Image:         registry.k8s.io/e2e-test-images/agnhost:2.43
    Image ID:      docker-pullable://registry.k8s.io/e2e-test-images/agnhost@sha256:16bbf38c463a4223d8cfe4da12bc61010b082a79b4bb003e2d3ba3ece5dd5f9e
    Port:          8080/TCP
    Host Port:     0/TCP
    Args:
      liveness
    State:          Running
      Started:      Tue, 02 Jun 2026 17:38:53 +0545
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-4zr6c (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True
  Initialized                 True
  Ready                       True
  ContainersReady             True
  PodScheduled                True
Volumes:
  kube-api-access-4zr6c:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    Optional:                false
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  10m    default-scheduler  Successfully assigned default/api-no-probes to minikube-m02
  Normal  Pulling    10m    kubelet            spec.containers{web-app}: Pulling image "registry.k8s.io/e2e-test-images/agnhost:2.43"
  Normal  Pulled     9m54s  kubelet            spec.containers{web-app}: Successfully pulled image "registry.k8s.io/e2e-test-images/agnhost:2.43" in 16.91s (16.91s including waiting). Image size: 128796258 bytes.
  Normal  Created    9m53s  kubelet            spec.containers{web-app}: Container created
  Normal  Started    9m52s  kubelet            spec.containers{web-app}: Container started
*/

--Clean up this Pod before moving on:
root@minikube-n1:~# kubectl delete pod api-no-probes
/*
pod "api-no-probes" deleted from default namespace
*/

--1. Add a liveness probe to trigger automatic restarts
--Task 1b — Add a liveness probe
root@minikube-n1:~# vi api-self-healing.yaml
/*
apiVersion: v1
kind: Pod
metadata:
  name: api-self-healing
  labels:
    app: api-server
spec:
  containers:
  - name: web-app
    image: registry.k8s.io/e2e-test-images/agnhost:2.43
    args:
    - liveness
    ports:
    - containerPort: 8080

    livenessProbe:
      httpGet:
        path: /healthz
        port: 8080
      initialDelaySeconds: 2
      periodSeconds: 2
      failureThreshold: 3
*/

root@minikube-n1:~# kubectl get pods api-self-healing -w -o wide
/*
NAME               READY   STATUS    RESTARTS     AGE   IP           NODE           NOMINATED NODE   READINESS GATES
api-self-healing   1/1     Running   1 (6s ago)   23s   10.244.1.4   minikube-m02   <none>           <none>
api-self-healing   1/1     Running   2 (2s ago)   35s   10.244.1.4   minikube-m02   <none>           <none>
api-self-healing   1/1     Running   3 (2s ago)   51s   10.244.1.4   minikube-m02   <none>           <none>
api-self-healing   0/1     CrashLoopBackOff   3 (0s ago)   65s   10.244.1.4   minikube-m02   <none>           <none>
*/

root@minikube-n1:~# kubectl describe pods api-self-healing
/*
Name:             api-self-healing
Namespace:        default
Priority:         0
Service Account:  default
Node:             minikube-m02/192.168.49.3
Start Time:       Tue, 02 Jun 2026 17:58:32 +0545
Labels:           app=api-server
Annotations:      <none>
Status:           Running
IP:               10.244.1.4
IPs:
  IP:  10.244.1.4
Containers:
  web-app:
    Container ID:  docker://3abbcc98e3ed19f92bc8fff96a60c138932c6591fc3bb6c405fe8d59b201e961
    Image:         registry.k8s.io/e2e-test-images/agnhost:2.43
    Image ID:      docker-pullable://registry.k8s.io/e2e-test-images/agnhost@sha256:16bbf38c463a4223d8cfe4da12bc61010b082a79b4bb003e2d3ba3ece5dd5f9e
    Port:          8080/TCP
    Host Port:     0/TCP
    Args:
      liveness
    State:          Waiting
      Reason:       CrashLoopBackOff
    Last State:     Terminated
      Reason:       Error
      Exit Code:    2
      Started:      Tue, 02 Jun 2026 17:59:58 +0545
      Finished:     Tue, 02 Jun 2026 18:00:13 +0545
    Ready:          False
    Restart Count:  4
    Liveness:       http-get http://:8080/healthz delay=2s timeout=1s period=2s #success=1 #failure=3
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-wbdbc (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True
  Initialized                 True
  Ready                       False
  ContainersReady             False
  PodScheduled                True
Volumes:
  kube-api-access-wbdbc:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    Optional:                false
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason     Age                  From               Message
  ----     ------     ----                 ----               -------
  Normal   Scheduled  2m6s                 default-scheduler  Successfully assigned default/api-self-healing to minikube-m02
  Normal   Pulled     40s (x5 over 2m4s)   kubelet            spec.containers{web-app}: Container image "registry.k8s.io/e2e-test-images/agnhost:2.43" already present on machine and can be accessed by the pod
  Normal   Created    40s (x5 over 2m4s)   kubelet            spec.containers{web-app}: Container created
  Normal   Started    40s (x5 over 2m4s)   kubelet            spec.containers{web-app}: Container started
  Warning  Unhealthy  25s (x15 over 113s)  kubelet            spec.containers{web-app}: Liveness probe failed: HTTP probe failed with statuscode: 500
  Normal   Killing    25s (x5 over 109s)   kubelet            spec.containers{web-app}: Container web-app failed liveness probe, will be restarted
  Warning  BackOff    25s (x4 over 61s)    kubelet            spec.containers{web-app}: Back-off restarting failed container web-app in pod api-self-healing_default(b360cd52-6a1b-463e-b326-2dc8a6d16b59)
*/

root@minikube-n1:~# kubectl delete pod api-self-healing
/*
pod "api-self-healing" deleted from default namespace
*/

--3. Add a readiness probe to stop traffic routing during failures
--Task 1c — Add a readiness probe
root@minikube-n1:~# vi healed-pod.yaml
/*
apiVersion: v1
kind: Pod
metadata:
  name: api-self-healing
  labels:
    app: api-server
spec:
  containers:
  - name: web-app
    image: registry.k8s.io/e2e-test-images/agnhost:2.43
    args:
    - liveness
    ports:
    - containerPort: 8080

    readinessProbe:
      httpGet:
        path: /healthz
        port: 8080
      initialDelaySeconds: 2
      periodSeconds: 2
      failureThreshold: 1

    livenessProbe:
      httpGet:
        path: /healthz
        port: 8080
      initialDelaySeconds: 2
      periodSeconds: 2
      failureThreshold: 3
*/

root@minikube-n1:~# kubectl apply -f healed-pod.yaml --dry-run=client
/*
pod/api-self-healing created (dry run)
*/

root@minikube-n1:~# kubectl apply -f healed-pod.yaml
/*
pod/api-self-healing created
*/


root@minikube-n1:~# kubectl get pods api-self-healing -w -o wide
/*
NAME               READY   STATUS    RESTARTS   AGE   IP           NODE           NOMINATED NODE   READINESS GATES
api-self-healing   1/1     Running   0          11s   10.244.1.5   minikube-m02   <none>           <none>
api-self-healing   0/1     Running   0          13s   10.244.1.5   minikube-m02   <none>           <none>
api-self-healing   0/1     Running   1 (1s ago)   17s   10.244.1.5   minikube-m02   <none>           <none>
api-self-healing   1/1     Running   1 (5s ago)   21s   10.244.1.5   minikube-m02   <none>           <none>
api-self-healing   0/1     Running   1 (13s ago)   29s   10.244.1.5   minikube-m02   <none>           <none>
api-self-healing   1/1     Running   1 (18s ago)   34s   10.244.1.5   minikube-m02   <none>           <none>
api-self-healing   0/1     Running   2 (2s ago)    34s   10.244.1.5   minikube-m02   <none>           <none>
api-self-healing   1/1     Running   2 (3s ago)    35s   10.244.1.5   minikube-m02   <none>           <none>
api-self-healing   0/1     Running   2 (11s ago)   43s   10.244.1.5   minikube-m02   <none>           <none>
api-self-healing   0/1     Running   3 (2s ago)    50s   10.244.1.5   minikube-m02   <none>           <none>
api-self-healing   1/1     Running   3 (2s ago)    50s   10.244.1.5   minikube-m02   <none>           <none>
api-self-healing   0/1     Running   3 (2s ago)    50s   10.244.1.5   minikube-m02   <none>           <none>
api-self-healing   1/1     Running   3 (2s ago)    50s   10.244.1.5   minikube-m02   <none>           <none>
api-self-healing   0/1     Running   3 (12s ago)   60s   10.244.1.5   minikube-m02   <none>           <none>
api-self-healing   0/1     CrashLoopBackOff   3 (2s ago)    66s   10.244.1.5   minikube-m02   <none>           <none>
api-self-healing   0/1     Running            4 (23s ago)   87s   10.244.1.5   minikube-m02   <none>           <none>
api-self-healing   1/1     Running            4 (25s ago)   89s   10.244.1.5   minikube-m02   <none>           <none>
api-self-healing   0/1     Running            4 (33s ago)   97s   10.244.1.5   minikube-m02   <none>           <none>
api-self-healing   0/1     CrashLoopBackOff   4 (1s ago)    101s   10.244.1.5   minikube-m02   <none>           <none>
api-self-healing   0/1     Running            5 (55s ago)   2m35s   10.244.1.5   minikube-m02   <none>           <none>
api-self-healing   1/1     Running            5 (55s ago)   2m35s   10.244.1.5   minikube-m02   <none>           <none>
api-self-healing   0/1     Running            5 (65s ago)   2m45s   10.244.1.5   minikube-m02   <none>           <none>
*/

root@minikube-n1:~# kubectl describe pods api-self-healing
/*
Name:             api-self-healing
Namespace:        default
Priority:         0
Service Account:  default
Node:             minikube-m02/192.168.49.3
Start Time:       Tue, 02 Jun 2026 18:03:46 +0545
Labels:           app=api-server
Annotations:      <none>
Status:           Running
IP:               10.244.1.5
IPs:
  IP:  10.244.1.5
Containers:
  web-app:
    Container ID:  docker://ab564b8bbc541254812c3be69b55f30c1647d5b9068ddf3065555dfcf834d5b4
    Image:         registry.k8s.io/e2e-test-images/agnhost:2.43
    Image ID:      docker-pullable://registry.k8s.io/e2e-test-images/agnhost@sha256:16bbf38c463a4223d8cfe4da12bc61010b082a79b4bb003e2d3ba3ece5dd5f9e
    Port:          8080/TCP
    Host Port:     0/TCP
    Args:
      liveness
    State:          Running
      Started:      Tue, 02 Jun 2026 18:06:19 +0545
    Last State:     Terminated
      Reason:       Error
      Exit Code:    2
      Started:      Tue, 02 Jun 2026 18:05:11 +0545
      Finished:     Tue, 02 Jun 2026 18:05:26 +0545
    Ready:          False
    Restart Count:  5
    Liveness:       http-get http://:8080/healthz delay=2s timeout=1s period=2s #success=1 #failure=3
    Readiness:      http-get http://:8080/healthz delay=2s timeout=1s period=2s #success=1 #failure=1
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-kfp8j (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True
  Initialized                 True
  Ready                       False
  ContainersReady             False
  PodScheduled                True
Volumes:
  kube-api-access-kfp8j:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    Optional:                false
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason     Age                    From               Message
  ----     ------     ----                   ----               -------
  Normal   Scheduled  2m45s                  default-scheduler  Successfully assigned default/api-self-healing to minikube-m02
  Warning  Unhealthy  105s (x10 over 2m33s)  kubelet            spec.containers{web-app}: Liveness probe failed: HTTP probe failed with statuscode: 500
  Warning  Unhealthy  105s (x15 over 2m32s)  kubelet            spec.containers{web-app}: Readiness probe failed: HTTP probe failed with statuscode: 500
  Normal   Killing    65s (x5 over 2m29s)    kubelet            spec.containers{web-app}: Container web-app failed liveness probe, will be restarted
  Normal   Pulled     12s (x6 over 2m44s)    kubelet            spec.containers{web-app}: Container image "registry.k8s.io/e2e-test-images/agnhost:2.43" already present on machine and can be accessed by the pod
  Normal   Created    12s (x6 over 2m44s)    kubelet            spec.containers{web-app}: Container created
  Normal   Started    11s (x6 over 2m44s)    kubelet            spec.containers{web-app}: Container started
*/

root@minikube-n1:~# kubectl describe pods api-self-healing | grep -E "Liveness|Readiness"
/*
    Liveness:       http-get http://:8080/healthz delay=2s timeout=1s period=2s #success=1 #failure=3
    Readiness:      http-get http://:8080/healthz delay=2s timeout=1s period=2s #success=1 #failure=1
  Warning  Unhealthy  38s (x10 over 86s)  kubelet            spec.containers{web-app}: Liveness probe failed: HTTP probe failed with statuscode: 500
  Warning  Unhealthy  37s (x15 over 85s)  kubelet            spec.containers{web-app}: Readiness probe failed: HTTP probe failed with statuscode: 500
*/


--Task 2 — Taming Redis: Resource Requests & Limits
--Task 2a — Deploy Redis without limits
root@minikube-n1:~# vi redis-deploy.yaml
/*
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis
  labels:
    app: redis-cache
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis-cache
  template:
    metadata:
      labels:
        app: redis-cache
    spec:
      containers:
      - name: redis-container
        image: redis:7-alpine
        ports:
        - containerPort: 6379
*/

root@minikube-n1:~# kubectl apply -f redis-deploy.yaml --dry-run=client
/*
deployment.apps/redis unchanged (dry run)
*/

root@minikube-n1:~# kubectl apply -f redis-deploy.yaml
/*
deployment.apps/redis created
*/

root@minikube-n1:~# kubectl get pods -o wide
/*
NAME                     READY   STATUS    RESTARTS   AGE   IP           NODE           NOMINATED NODE   READINESS GATES
redis-789cf764c8-9j9sh   1/1     Running   0          51s   10.244.1.8   minikube-m02   <none>           <none>
*/

root@minikube-n1:~# kubectl top pods
/*
NAME                     CPU(cores)   MEMORY(bytes)
redis-789cf764c8-9j9sh   20m          3Mi
*/

--Task 2b — Add resource requests and limits
root@minikube-n1:~# vi redis-deploy.yaml
/*
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis
  labels:
    app: redis-cache
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis-cache
  template:
    metadata:
      labels:
        app: redis-cache
    spec:
      containers:
      - name: redis-container
        image: redis:7-alpine
        ports:
        - containerPort: 6379

        resources:
          requests:
            cpu: 100m
            memory: 64Mi
          limits:
            cpu: 250m
            memory: 128Mi
*/

root@minikube-n1:~# kubectl apply -f redis-deploy.yaml --dry-run=client
/*
deployment.apps/redis configured (dry run)
*/

root@minikube-n1:~# kubectl apply -f redis-deploy.yaml
/*
deployment.apps/redis configured
*/

root@minikube-n1:~# kubectl rollout status deployment/redis
/*
deployment "redis" successfully rolled out
*/

root@minikube-n1:~# kubectl top pods
/*
NAME                    CPU(cores)   MEMORY(bytes)
redis-d5c68fb8f-hrfkz   24m          3Mi
*/

--Task 2c — Witness an OOM kill (optional but educational)
root@minikube-n1:~# vi mem-hog.yaml
/*
apiVersion: v1
kind: Pod
metadata:
  name: mem-hog
  labels:
    app: stress-test
spec:
  restartPolicy: Never
  containers:
  - name: stress-container
    image: polinux/stress
    args:
    - stress
    - --vm
    - "1"
    - --vm-bytes
    - 200M
    - --vm-keep
    resources:
      limits:
        memory: 50Mi
*/

root@minikube-n1:~# kubectl apply -f mem-hog.yaml --dry-run=client
/*
pod/mem-hog created (dry run)
*/

root@minikube-n1:~# kubectl apply -f mem-hog.yaml
/*
pod/mem-hog created
*/

root@minikube-n1:~# kubectl get pods mem-hog -w -o wide
/*
NAME      READY   STATUS      RESTARTS   AGE   IP            NODE           NOMINATED NODE   READINESS GATES
mem-hog   0/1     OOMKilled   0          38s   10.244.1.10   minikube-m02   <none>           <none>
*/

root@minikube-n1:~# kubectl get pods mem-hog -w -o wide
/*
NAME      READY   STATUS              RESTARTS   AGE   IP       NODE           NOMINATED NODE   READINESS GATES
mem-hog   0/1     ContainerCreating   0          2s    <none>   minikube-m02   <none>           <none>
mem-hog   0/1     OOMKilled           0          6s    10.244.1.11   minikube-m02   <none>           <none>
mem-hog   0/1     OOMKilled           0          8s    10.244.1.11   minikube-m02   <none>           <none>
*/

root@minikube-n1:~# kubectl delete pods mem-hog
/*
pod "mem-hog" deleted from default namespace
*/

--Checkpoint
--You should see your configured limits and requests printed.
root@minikube-n1:~# kubectl describe deployment redis | grep -A 8 "Limits:"
/*
    Limits:
      cpu:     250m
      memory:  128Mi
    Requests:
      cpu:         100m
      memory:      64Mi
    Environment:   <none>
    Mounts:        <none>
  Volumes:         <none>
*/

--Task 3 — Pinning Redis: nodeSelector & Taints
--Task 3a — Label the database node
root@minikube-n1:~# kubectl label node minikube-m02 role=database
/*
node/minikube-m02 labeled
*/

root@minikube-n1:~# kubectl get nodes --show-labels
/*
NAME           STATUS   ROLES           AGE     VERSION   LABELS
minikube       Ready    control-plane   3h54m   v1.35.1   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=minikube,kubernetes.io/os=linux,minikube.k8s.io/commit=c93a4cb9311efc66b90d33ea03f75f2c4120e9b0,minikube.k8s.io/name=minikube,minikube.k8s.io/primary=true,minikube.k8s.io/updated_at=2026_06_02T14_44_17_0700,minikube.k8s.io/version=v1.38.1,node-role.kubernetes.io/control-plane=,node.kubernetes.io/exclude-from-external-load-balancers=
minikube-m02   Ready    <none>          3h51m   v1.35.1   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=minikube-m02,kubernetes.io/os=linux,minikube.k8s.io/commit=c93a4cb9311efc66b90d33ea03f75f2c4120e9b0,minikube.k8s.io/name=minikube,minikube.k8s.io/primary=false,minikube.k8s.io/updated_at=2026_06_02T14_46_43_0700,minikube.k8s.io/version=v1.38.1,role=database
*/

--Task 3b — Pin Redis to the database node
root@minikube-n1:~# vi redis-deploy.yaml
/*
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis
  labels:
    app: redis-cache
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis-cache
  template:
    metadata:
      labels:
        app: redis-cache
    spec:
      # Add the nodeSelector constraint below
      nodeSelector:
        role: database
      containers:
      - name: redis-container
        image: redis:7-alpine
        ports:
        - containerPort: 6379
        resources:
          requests:
            cpu: 100m
            memory: 64Mi
          limits:
            cpu: 250m
            memory: 128Mi
*/

root@minikube-n1:~# kubectl apply -f redis-deploy.yaml --dry-run=client
/*
deployment.apps/redis unchanged (dry run)
*/

root@minikube-n1:~# kubectl apply -f redis-deploy.yaml
/*
deployment.apps/redis configured
*/

root@minikube-n1:~# kubectl rollout status deployment/redis
/*
deployment "redis" successfully rolled out
*/

--The Redis Pod is now running on minikube-m02.
root@minikube-n1:~# kubectl get pods -o wide
/*
NAME                     READY   STATUS    RESTARTS   AGE   IP            NODE           NOMINATED NODE   READINESS GATES
redis-78756c98dc-b6khd   1/1     Running   0          23s   10.244.1.12   minikube-m02   <none>           <none>
*/

--Task 3c — Taint the database node
--Adding a nodeSelector makes Redis prefer that node — but it doesn't stop other Pods from also landing there. A taint does.
--Add a taint to minikube-m02:
root@minikube-n1:~# kubectl taint nodes minikube-m02 dedicated=database:NoSchedule
/*
node/minikube-m02 tainted
*/

root@minikube-n1:~# kubectl run test-nginx --image=nginx
/*
pod/test-nginx created
*/

root@minikube-n1:~# kubectl get pod test-nginx -o wide
/*
NAME         READY   STATUS              RESTARTS   AGE   IP       NODE       NOMINATED NODE   READINESS GATES
test-nginx   0/1     ContainerCreating   0          16s   <none>   minikube   <none>           <none>
*/

root@minikube-n1:~# kubectl describe pod test-nginx | grep -A 5 "Events:"
/*
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  25s   default-scheduler  Successfully assigned default/test-nginx to minikube
  Normal  Pulling    24s   kubelet            spec.containers{test-nginx}: Pulling image "nginx"
*/

root@minikube-n1:~# kubectl describe pod test-nginx | grep -A 5 "Events:"
/*
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  30s   default-scheduler  Successfully assigned default/test-nginx to minikube
  Normal  Pulling    29s   kubelet            spec.containers{test-nginx}: Pulling image "nginx"
  Normal  Pulled     2s    kubelet            spec.containers{test-nginx}: Successfully pulled image "nginx" in 26.522s (26.522s including waiting). Image size: 161294340 bytes.
*/

root@minikube-n1:~# kubectl get pod test-nginx -o wide
/*
NAME         READY   STATUS    RESTARTS   AGE   IP           NODE       NOMINATED NODE   READINESS GATES
test-nginx   1/1     Running   0          54s   10.244.0.3   minikube   <none>           <none>
*/

root@minikube-n1:~# kubectl describe pod test-nginx | grep -A 5 "Events:"
/*
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  57s   default-scheduler  Successfully assigned default/test-nginx to minikube
  Normal  Pulling    56s   kubelet            spec.containers{test-nginx}: Pulling image "nginx"
  Normal  Pulled     29s   kubelet            spec.containers{test-nginx}: Successfully pulled image "nginx" in 26.522s (26.522s including waiting). Image size: 161294340 bytes.
*/

root@minikube-n1:~# kubectl delete pod test-nginx
/*
pod "test-nginx" deleted from default namespace
*/

--Checkpoint
--# Redis should be on minikube-m02 (or Pending — fixed in Task 4)
root@minikube-n1:~# kubectl get pods -o wide
/*
NAME                     READY   STATUS    RESTARTS   AGE     IP            NODE           NOMINATED NODE   READINESS GATES
redis-78756c98dc-b6khd   1/1     Running   0          7m19s   10.244.1.12   minikube-m02   <none>           <none>
*/

--# Should show: dedicated=database:NoSchedule
root@minikube-n1:~# kubectl describe node minikube-m02 | grep Taint
/*
Taints:             dedicated=database:NoSchedule
*/

--Task 4 — Tolerations: Grant Redis Access Back
Task 4a — Add a toleration to Redis
root@minikube-n1:~# vi redis-deploy.yaml
/*
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis
  labels:
    app: redis-cache
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis-cache
  template:
    metadata:
      labels:
        app: redis-cache
    spec:
      nodeSelector:
        role: database
      # Add the toleration configuration below
      tolerations:
      - key: "dedicated"
        operator: "Equal"
        value: "database"
        effect: "NoSchedule"
      containers:
      - name: redis-container
        image: redis:7-alpine
        ports:
        - containerPort: 6379
        resources:
          requests:
            cpu: 100m
            memory: 64Mi
          limits:
            cpu: 250m
            memory: 128Mi
*/

root@minikube-n1:~# kubectl apply -f redis-deploy.yaml --dry-run=client
/*
deployment.apps/redis configured (dry run)
*/

root@minikube-n1:~# kubectl apply -f redis-deploy.yaml
/*
deployment.apps/redis configured
*/

root@minikube-n1:~# kubectl rollout status deployment/redis
/*
deployment "redis" successfully rolled out
*/

--The Redis Pod is running on minikube-m02 again. Other Pods (without the toleration) will remain blocked.
root@minikube-n1:~# kubectl get pods -o wide
/*
NAME                     READY   STATUS    RESTARTS   AGE   IP            NODE           NOMINATED NODE   READINESS GATES
redis-7dc6f5b84d-l75b4   1/1     Running   0          10s   10.244.1.13   minikube-m02   <none>           <none>
*/

--Task 4b — Verify isolation
--Deploy a "batch job" Pod without any toleration to confirm it can't land on the database node:
root@minikube-n1:~# kubectl run batch-job --image=busybox -- sleep 3600
/*
pod/batch-job created
*/

--batch-job lands on minikube (the control-plane node), not minikube-m02. The database node is protected.
root@minikube-n1:~# kubectl get pods -o wide
/*
NAME                     READY   STATUS              RESTARTS   AGE    IP            NODE           NOMINATED NODE   READINESS GATES
batch-job                0/1     ContainerCreating   0          6s     <none>        minikube       <none>           <none>
redis-7dc6f5b84d-l75b4   1/1     Running             0          112s   10.244.1.13   minikube-m02   <none>           <none>
*/

--batch-job lands on minikube (the control-plane node), not minikube-m02. The database node is protected.
root@minikube-n1:~# kubectl get pods -o wide
/*
NAME                     READY   STATUS    RESTARTS   AGE    IP            NODE           NOMINATED NODE   READINESS GATES
batch-job                1/1     Running   0          15s    10.244.0.4    minikube       <none>           <none>
redis-7dc6f5b84d-l75b4   1/1     Running   0          2m1s   10.244.1.13   minikube-m02   <none>           <none>
*/

--Checkpoint
root@minikube-n1:~# kubectl get pods -o wide
/*
NAME                     READY   STATUS    RESTARTS   AGE     IP            NODE           NOMINATED NODE   READINESS GATES
batch-job                1/1     Running   0          86s     10.244.0.4    minikube       <none>           <none>
redis-7dc6f5b84d-l75b4   1/1     Running   0          3m12s   10.244.1.13   minikube-m02   <none>           <none>
*/

root@minikube-n1:~# vi spot-th-bug-fixed.yaml
/*
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-api
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web-api  # Fixed: master selector (Bug1)
  template:
    metadata:
      labels:
        app: web-api  # Fixed: Matches the selector above (Bug 2)
    spec:
      # Fixed: Removed the restrictive production nodeSelector (Bug 3)
      containers:
      - name: web-api
        image: nginx:alpine
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 100m
            memory: 256Mi  # Fixed: Clean binary unit syntax (Bug 4)
          limits:
            cpu: 500m
            memory: 512Mi
        livenessProbe:
          httpGet:
            path: /  # Note: Stock nginx responds with 200 OK at root "/" (Bug 5)
            port: 80  # Fixed: Points to Nginx's active web port (Bug 6)
          initialDelaySeconds: 5
          periodSeconds: 10
*/

root@minikube-n1:~# kubectl apply -f spot-th-bug-fixed.yaml --dry-run=client
/*
deployment.apps/web-api created (dry run)
*/

root@minikube-n1:~# kubectl apply -f spot-th-bug-fixed.yaml
/*
deployment.apps/web-api created
*/

root@minikube-n1:~# kubectl get pods -A
/*
NAMESPACE     NAME                               READY   STATUS    RESTARTS   AGE
default       batch-job                          1/1     Running   0          8m46s
default       redis-7dc6f5b84d-l75b4             1/1     Running   0          10m
default       web-api-7795fb864d-nrfzk           1/1     Running   0          38s
default       web-api-7795fb864d-zs2zz           1/1     Running   0          39s
kube-system   coredns-7d764666f9-pjsv6           1/1     Running   0          4h17m
kube-system   etcd-minikube                      1/1     Running   0          4h17m
kube-system   kindnet-7rlvf                      1/1     Running   0          4h14m
kube-system   kindnet-vfnvt                      1/1     Running   0          4h17m
kube-system   kube-apiserver-minikube            1/1     Running   0          4h17m
kube-system   kube-controller-manager-minikube   1/1     Running   0          4h17m
kube-system   kube-proxy-pjrkg                   1/1     Running   0          4h14m
kube-system   kube-proxy-wd6h7                   1/1     Running   0          4h17m
kube-system   kube-scheduler-minikube            1/1     Running   0          4h17m
kube-system   metrics-server-9d74bb658-jsqh2     1/1     Running   0          105m
kube-system   storage-provisioner                1/1     Running   0          4h17m
*/

root@minikube-n1:~# kubectl get pods -o wide
/*
NAME                       READY   STATUS    RESTARTS   AGE     IP            NODE           NOMINATED NODE   READINESS GATES
batch-job                  1/1     Running   0          10m     10.244.0.4    minikube       <none>           <none>
redis-7dc6f5b84d-l75b4     1/1     Running   0          12m     10.244.1.13   minikube-m02   <none>           <none>
web-api-7795fb864d-nrfzk   1/1     Running   0          2m51s   10.244.0.6    minikube       <none>           <none>
web-api-7795fb864d-zs2zz   1/1     Running   0          2m52s   10.244.0.5    minikube       <none>           <none>
*/

root@minikube-n1:~# minikube delete --all
/*
* Deleting "minikube" in docker ...
* Removing /root/.minikube/machines/minikube ...
* Removing /root/.minikube/machines/minikube-m02 ...
* Removed all traces of the "minikube" cluster.
* Successfully deleted all profiles
*/
