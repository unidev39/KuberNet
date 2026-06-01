--Step 1 (Lab) - START A 2-NODE MINIKUBE CLUSTER, ENABLE THE METRICS SERVER ADDON, AND STATUS
root@minikube-n1:~# minikube start --nodes 2 --cpus 2 --memory 2048 --force
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
* Downloading Kubernetes v1.35.1 preload ...
    > preloaded-images-k8s-v18-v1...:  272.45 MiB / 272.45 MiB  100.00% 14.77 M
    > gcr.io/k8s-minikube/kicbase...:  519.58 MiB / 519.58 MiB  100.00% 14.36 M
* Creating docker container (CPUs=2, Memory=2048MB) ...
* Preparing Kubernetes v1.35.1 on Docker 29.2.1 ...
* Configuring CNI (Container Networking Interface) ...
* Verifying Kubernetes components...
  - Using image gcr.io/k8s-minikube/storage-provisioner:v5
* Enabled addons: default-storageclass, storage-provisioner

* Starting "minikube-m02" worker node in "minikube" cluster
* Pulling base image v0.0.50 ...
* Creating docker container (CPUs=2, Memory=2048MB) ...
* Found network options:
  - NO_PROXY=192.168.49.2
* Preparing Kubernetes v1.35.1 on Docker 29.2.1 ...
  - env NO_PROXY=192.168.49.2
* Verifying Kubernetes components...
* Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
*/

--Step 1.1 (Lab)
root@minikube-n1:~# kubectl get nodes
/*
NAME           STATUS   ROLES           AGE     VERSION
minikube       Ready    control-plane   2m35s   v1.35.1
minikube-m02   Ready    <none>          35s     v1.35.1
*/

--Step 1.2 (Lab)
root@minikube-n1:~# kubectl get nodes -o wide
/*
NAME           STATUS   ROLES           AGE     VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE                         KERNEL-VERSION      CONTAINER-RUNTIME
minikube       Ready    control-plane   2m51s   v1.35.1   192.168.49.2   <none>        Debian GNU/Linux 12 (bookworm)   6.8.0-111-generic   docker://29.2.1
minikube-m02   Ready    <none>          51s     v1.35.1   192.168.49.3   <none>        Debian GNU/Linux 12 (bookworm)   6.8.0-111-generic   docker://29.2.1
*/

--Step 1.3 (Lab)
root@minikube-n1:~# kubectl get pods -A
/*
NAMESPACE     NAME                               READY   STATUS    RESTARTS   AGE
kube-system   coredns-7d764666f9-k8j67           1/1     Running   0          3m2s
kube-system   etcd-minikube                      1/1     Running   0          3m7s
kube-system   kindnet-8sczj                      1/1     Running   0          3m2s
kube-system   kindnet-lj64s                      1/1     Running   0          71s
kube-system   kube-apiserver-minikube            1/1     Running   0          3m9s
kube-system   kube-controller-manager-minikube   1/1     Running   0          3m7s
kube-system   kube-proxy-4jp2t                   1/1     Running   0          3m2s
kube-system   kube-proxy-k484z                   1/1     Running   0          71s
kube-system   kube-scheduler-minikube            1/1     Running   0          3m7s
kube-system   storage-provisioner                1/1     Running   0          3m
*/

--Step 2 (Lab)
root@minikube-n1:~# kubectl config current-context
/*
minikube
*/

--Step 2.1 (Lab)
root@minikube-n1:~# minikube addons enable metrics-server -p minikube
/*
* metrics-server is an addon maintained by Kubernetes. For any concerns contact minikube on GitHub.
You can view the list of minikube maintainers at: https://github.com/kubernetes/minikube/blob/master/OWNERS
  - Using image registry.k8s.io/metrics-server/metrics-server:v0.8.1
* The 'metrics-server' addon is enabled
*/

--Step 2.2 (Lab)
root@minikube-n1:~# kubectl get pods -n kube-system
/*
NAME                               READY   STATUS    RESTARTS   AGE
coredns-7d764666f9-k8j67           1/1     Running   0          6m14s
etcd-minikube                      1/1     Running   0          6m19s
kindnet-8sczj                      1/1     Running   0          6m14s
kindnet-lj64s                      1/1     Running   0          4m23s
kube-apiserver-minikube            1/1     Running   0          6m21s
kube-controller-manager-minikube   1/1     Running   0          6m19s
kube-proxy-4jp2t                   1/1     Running   0          6m14s
kube-proxy-k484z                   1/1     Running   0          4m23s
kube-scheduler-minikube            1/1     Running   0          6m19s
metrics-server-9d74bb658-ld5n6     0/1     Running   0          54s
storage-provisioner                1/1     Running   0          6m12s
*/

--Step 2.3 (Lab)
root@minikube-n1:~# kubectl get pods -n kube-system | grep metrics-server
/*
metrics-server-9d74bb658-ld5n6     0/1     Running   0          57s
*/

--Step 3 (Lab) - CREATE A NAMESPACE
root@minikube-n1:~# kubectl create namespace hpa-demo --dry-run=client -o yaml
/*
apiVersion: v1
kind: Namespace
metadata:
  name: hpa-demo
spec: {}
status: {}
*/

--Step 3.1 (Lab) - CREATE A NAMESPACE
root@minikube-n1:~# kubectl create namespace hpa-demo --dry-run=client -o yaml > namespace.yaml

--Step 3.2 (Lab)
root@minikube-n1:~# kubectl apply -f namespace.yaml --dry-run=client
/*
namespace/hpa-demo unchanged (dry run)
*/

--Step 3.2.1 (Lab)
root@minikube-n1:~# kubectl apply -f namespace.yaml
/*
namespace/hpa-demo created
*/

--Step 3.3 (Lab)
root@minikube-n1:~# kubectl get ns
/*
NAME              STATUS   AGE
default           Active   8m49s
hpa-demo          Active   23s
kube-node-lease   Active   8m49s
kube-public       Active   8m49s
kube-system       Active   8m49s
*/

--Step 3.4 (Lab)
root@minikube-n1:~# kubectl get ns hpa-demo
/*
NAME       STATUS   AGE
hpa-demo   Active   36s
*/

--Step 4 (Lab) - DEPLOY THE APPLICATION
root@minikube-n1:~# kubectl create deployment php-apache --image=registry.k8s.io/hpa-example -n hpa-demo --dry-run=client -o yaml
/*
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: php-apache
  name: php-apache
  namespace: hpa-demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: php-apache
  strategy: {}
  template:
    metadata:
      labels:
        app: php-apache
    spec:
      containers:
      - image: registry.k8s.io/hpa-example
        name: hpa-example
        resources: {}
status: {}
*/

--Step 4.1 (Lab) - DEPLOY THE APPLICATION
root@minikube-n1:~# kubectl create deployment php-apache --image=registry.k8s.io/hpa-example -n hpa-demo --dry-run=client -o yaml > deployment.yaml

--Step 4.1 (Lab) - SET RESOURCE REQUESTS AND LIMITS
root@minikube-n1:~# vi deployment.yaml
/*
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: php-apache
  name: php-apache
  namespace: hpa-demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: php-apache
  strategy: {}
  template:
    metadata:
      labels:
        app: php-apache
    spec:
      containers:
      - image: registry.k8s.io/hpa-example
        name: hpa-example
        resources:
          requests:
            cpu: 200m
            memory: 64Mi
          limits:
            cpu: 500m
            memory: 128Mi
status: {}
*/

--Step 4.2 (Lab)
root@minikube-n1:~# kubectl apply -f deployment.yaml --dry-run=client
/*
deployment.apps/php-apache created (dry run)
*/

--Step 4.3 (Lab)
root@minikube-n1:~# kubectl apply -f deployment.yaml
/*
deployment.apps/php-apache created
*/

--Step 4.4 (Lab) - VERIFY METRICS SERVER
root@minikube-n1:~# kubectl get pods -A
/*
NAMESPACE     NAME                               READY   STATUS              RESTARTS   AGE
hpa-demo      php-apache-5b7b8dbb4f-4777j        0/1     ContainerCreating   0          66s
kube-system   coredns-7d764666f9-k8j67           1/1     Running             0          16m
kube-system   etcd-minikube                      1/1     Running             0          16m
kube-system   kindnet-8sczj                      1/1     Running             0          16m
kube-system   kindnet-lj64s                      1/1     Running             0          14m
kube-system   kube-apiserver-minikube            1/1     Running             0          16m
kube-system   kube-controller-manager-minikube   1/1     Running             0          16m
kube-system   kube-proxy-4jp2t                   1/1     Running             0          16m
kube-system   kube-proxy-k484z                   1/1     Running             0          14m
kube-system   kube-scheduler-minikube            1/1     Running             0          16m
kube-system   metrics-server-9d74bb658-ld5n6     1/1     Running             0          11m
kube-system   storage-provisioner                1/1     Running             0          16m
*/

--Step 4.5 (Lab)
root@minikube-n1:~# kubectl get pods -n hpa-demo -o wide
/*
NAME                          READY   STATUS    RESTARTS   AGE   IP           NODE           NOMINATED NODE   READINESS GATES
php-apache-5b7b8dbb4f-4777j   1/1     Running   0          91s   10.244.1.3   minikube-m02   <none>           <none>
*/

--Step 4.8 (Lab)
root@minikube-n1:~# kubectl top pods -n hpa-demo
/*
NAME                          CPU(cores)   MEMORY(bytes)
php-apache-5b7b8dbb4f-4777j   1m           18Mi
*/

--Step 4.9 (Lab)
root@minikube-n1:~# kubectl top nodes
/*
NAME           CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)
minikube       334m         16%      970Mi           19%
minikube-m02   99m          4%       381Mi           7%
*/

--Step 5 (Lab) - CREATE THE HPA
root@minikube-n1:~# kubectl autoscale deployment php-apache --cpu=50% --min=1 --max=10 -n hpa-demo --dry-run=client -o yaml
/*
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: php-apache
  namespace: hpa-demo
spec:
  maxReplicas: 10
  metrics:
  - resource:
      name: cpu
      target:
        averageUtilization: 50
        type: Utilization
    type: Resource
  minReplicas: 1
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: php-apache
status:
  currentMetrics: null
  desiredReplicas: 0
*/

--Step 5.0 (Lab)
root@minikube-n1:~# kubectl autoscale deployment php-apache --cpu=50% --min=1 --max=10 -n hpa-demo --dry-run=client -o yaml > hpa.yaml

--Step 5.1 (Lab)
root@minikube-n1:~# kubectl apply -f hpa.yaml --dry-run=client
/*
horizontalpodautoscaler.autoscaling/php-apache created (dry run)
*/

--Step 5.2 (Lab)
root@minikube-n1:~# kubectl apply -f hpa.yaml
/*
horizontalpodautoscaler.autoscaling/php-apache created
*/

--Step 5.3 (Lab)
root@minikube-n1:~# kubectl get hpa -n hpa-demo
/*
NAME         REFERENCE               TARGETS       MINPODS   MAXPODS   REPLICAS   AGE
php-apache   Deployment/php-apache   cpu: 0%/50%   1         10        1          27s
*/

--Step 5.4 (Lab)
root@minikube-n1:~# kubectl get pods -n hpa-demo -o wide
/*
NAME                          READY   STATUS    RESTARTS   AGE   IP            NODE           NOMINATED NODE   READINESS GATES
php-apache-5b7b8dbb4f-82thc   1/1     Running   0          10m   10.244.1.20   minikube-m02   <none>           <none>
*/

--Step 6 (Lab)
root@minikube-n1:~# kubectl run load-generator -n hpa-demo --image=busybox \
   --restart=Never --dry-run=client -o yaml \
   -- /bin/sh -c "while true; do wget -q -O- http://10.244.1.20; done"
/*
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: load-generator
  name: load-generator
  namespace: hpa-demo
spec:
  containers:
  - args:
    - /bin/sh
    - -c
    - while true; do wget -q -O- http://10.244.1.20; done
    image: busybox
    name: load-generator
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}
*/

--Step 6.1 (Lab) - GENERATE LOAD
root@minikube-n1:~# kubectl run load-generator -n hpa-demo --image=busybox \
   --restart=Never --dry-run=client -o yaml \
   -- /bin/sh -c "while true; do wget -q -O- http://10.244.1.20; done" \
   > load-generator.yaml

--Step 6.2 (Lab)
root@minikube-n1:~# kubectl apply -f load-generator.yaml --dry-run=client
/*
pod/load-generator created (dry run)
*/

--Step 6.3 (Lab)
root@minikube-n1:~# kubectl apply -f load-generator.yaml
/*
pod/load-generator created
*/

--Step 6.4 (Lab)
root@minikube-n1:~# kubectl get pod -n hpa-demo load-generator
/*
NAME             READY   STATUS    RESTARTS   AGE
load-generator   1/1     Running   0          52s
*/

--Step 6.5 (Lab) - Scaling
root@minikube-n1:~# kubectl get hpa php-apache -n hpa-demo -w
/*
NAME         REFERENCE               TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
php-apache   Deployment/php-apache   cpu: 242%/50%   1         10        5          6m51s
php-apache   Deployment/php-apache   cpu: 226%/50%   1         10        5          7m19s
php-apache   Deployment/php-apache   cpu: 80%/50%    1         10        5          8m19s
php-apache   Deployment/php-apache   cpu: 49%/50%    1         10        5          9m19s
php-apache   Deployment/php-apache   cpu: 50%/50%    1         10        5          11m
php-apache   Deployment/php-apache   cpu: 49%/50%    1         10        5          12m
php-apache   Deployment/php-apache   cpu: 50%/50%    1         10        5          13m
php-apache   Deployment/php-apache   cpu: 49%/50%    1         10        5          14m
php-apache   Deployment/php-apache   cpu: 50%/50%    1         10        5          18m
php-apache   Deployment/php-apache   cpu: 49%/50%    1         10        5          20m
php-apache   Deployment/php-apache   cpu: 49%/50%    1         10        5          23m
php-apache   Deployment/php-apache   cpu: 49%/50%    1         10        5          24m
php-apache   Deployment/php-apache   cpu: 50%/50%    1         10        5          25m
php-apache   Deployment/php-apache   cpu: 49%/50%    1         10        5          26m
php-apache   Deployment/php-apache   cpu: 12%/50%    1         10        5          28m
php-apache   Deployment/php-apache   cpu: 0%/50%     1         10        5          29m
php-apache   Deployment/php-apache   cpu: 0%/50%     1         10        5          32m
php-apache   Deployment/php-apache   cpu: 0%/50%     1         10        2          33m
php-apache   Deployment/php-apache   cpu: 0%/50%     1         10        2          33m
php-apache   Deployment/php-apache   cpu: 0%/50%     1         10        1          34m
*/

--Step 6.6 (Lab)--From other Terminal
root@minikube-n1:~#  kubectl get pods -n hpa-demo -o wide -w
/*
NAME                          READY   STATUS    RESTARTS   AGE     IP            NODE           NOMINATED NODE   READINESS GATES
load-generator                1/1     Running   0          5m28s   10.244.1.21   minikube-m02   <none>           <none>
php-apache-5b7b8dbb4f-6rg82   1/1     Running   0          4m45s   10.244.0.9    minikube       <none>           <none>
php-apache-5b7b8dbb4f-82thc   1/1     Running   0          19m     10.244.1.20   minikube-m02   <none>           <none>
php-apache-5b7b8dbb4f-b4xmn   1/1     Running   0          3m44s   10.244.0.10   minikube       <none>           <none>
php-apache-5b7b8dbb4f-tcqpb   1/1     Running   0          3m29s   10.244.1.23   minikube-m02   <none>           <none>
php-apache-5b7b8dbb4f-z8pg8   1/1     Running   0          3m44s   10.244.1.22   minikube-m02   <none>           <none>
load-generator                1/1     Terminating   0          22m     10.244.1.21   minikube-m02   <none>           <none>
load-generator                1/1     Terminating   0          22m     10.244.1.21   minikube-m02   <none>           <none>
load-generator                0/1     Error         0          22m     10.244.1.21   minikube-m02   <none>           <none>
load-generator                0/1     Error         0          22m     10.244.1.21   minikube-m02   <none>           <none>
load-generator                0/1     Error         0          22m     10.244.1.21   minikube-m02   <none>           <none>
php-apache-5b7b8dbb4f-z8pg8   1/1     Terminating   0          26m     10.244.1.22   minikube-m02   <none>           <none>
php-apache-5b7b8dbb4f-tcqpb   1/1     Terminating   0          26m     10.244.1.23   minikube-m02   <none>           <none>
php-apache-5b7b8dbb4f-82thc   1/1     Terminating   0          42m     10.244.1.20   minikube-m02   <none>           <none>
php-apache-5b7b8dbb4f-z8pg8   1/1     Terminating   0          26m     10.244.1.22   minikube-m02   <none>           <none>
php-apache-5b7b8dbb4f-82thc   1/1     Terminating   0          42m     10.244.1.20   minikube-m02   <none>           <none>
php-apache-5b7b8dbb4f-tcqpb   1/1     Terminating   0          26m     10.244.1.23   minikube-m02   <none>           <none>
php-apache-5b7b8dbb4f-tcqpb   0/1     Completed     0          26m     10.244.1.23   minikube-m02   <none>           <none>
php-apache-5b7b8dbb4f-tcqpb   0/1     Completed     0          26m     10.244.1.23   minikube-m02   <none>           <none>
php-apache-5b7b8dbb4f-tcqpb   0/1     Completed     0          26m     10.244.1.23   minikube-m02   <none>           <none>
php-apache-5b7b8dbb4f-z8pg8   0/1     Completed     0          26m     10.244.1.22   minikube-m02   <none>           <none>
php-apache-5b7b8dbb4f-82thc   0/1     Completed     0          42m     10.244.1.20   minikube-m02   <none>           <none>
php-apache-5b7b8dbb4f-z8pg8   0/1     Completed     0          26m     10.244.1.22   minikube-m02   <none>           <none>
php-apache-5b7b8dbb4f-z8pg8   0/1     Completed     0          26m     10.244.1.22   minikube-m02   <none>           <none>
php-apache-5b7b8dbb4f-82thc   0/1     Completed     0          42m     10.244.1.20   minikube-m02   <none>           <none>
php-apache-5b7b8dbb4f-82thc   0/1     Completed     0          42m     10.244.1.20   minikube-m02   <none>           <none>
php-apache-5b7b8dbb4f-6rg82   1/1     Terminating   0          28m     10.244.0.9    minikube       <none>           <none>
php-apache-5b7b8dbb4f-6rg82   1/1     Terminating   0          28m     10.244.0.9    minikube       <none>           <none>
php-apache-5b7b8dbb4f-6rg82   0/1     Completed     0          28m     10.244.0.9    minikube       <none>           <none>
php-apache-5b7b8dbb4f-6rg82   0/1     Completed     0          28m     10.244.0.9    minikube       <none>           <none>
php-apache-5b7b8dbb4f-6rg82   0/1     Completed     0          28m     10.244.0.9    minikube       <none>           <none>
*/

--Q1. How long did it take for the first new pod to appear after load started?
--Answer: Approximately 1 minute after the load started.

--Q2. What CPU % did the HPA report before it triggered a scale-up?
--Answer: 242% CPU utilization.
 
--Q3. Which node did the new pods get scheduled on — the same node as the first pod, or the second node?
--Answer: Pods were distributed across both nodes.

--Step 6.6.1 (Lab)--From other Terminal
root@minikube-n1:~# kubectl describe hpa php-apache -n hpa-demo
/*
Name:                                                  php-apache
Namespace:                                             hpa-demo
Labels:                                                <none>
Annotations:                                           <none>
CreationTimestamp:                                     Mon, 01 Jun 2026 16:14:35 +0545
Reference:                                             Deployment/php-apache
Metrics:                                               ( current / target )
  resource cpu on pods  (as a percentage of request):  49% (99m) / 50%
Min replicas:                                          1
Max replicas:                                          10
Deployment pods:                                       5 current / 5 desired
Conditions:
  Type            Status  Reason              Message
  ----            ------  ------              -------
  AbleToScale     True    ReadyForNewScale    recommended size matches current size
  ScalingActive   True    ValidMetricFound    the HPA was able to successfully calculate a replica count from cpu resource utilization (percentage of request)
  ScalingLimited  False   DesiredWithinRange  the desired count is within the acceptable range
Events:
  Type    Reason             Age   From                       Message
  ----    ------             ----  ----                       -------
  Normal  SuccessfulRescale  15m   horizontal-pod-autoscaler  New size: 2; reason: cpu resource utilization (percentage of request) above target
  Normal  SuccessfulRescale  14m   horizontal-pod-autoscaler  New size: 4; reason: cpu resource utilization (percentage of request) above target
  Normal  SuccessfulRescale  13m   horizontal-pod-autoscaler  New size: 5; reason: cpu resource utilization (percentage of request) above target
*/

--Step 6.7 (Lab)--From other Terminal - STOP THE LOAD
root@minikube-n1:~# kubectl delete -f load-generator.yaml
/*
pod "load-generator" deleted from hpa-demo namespace
*/

--Step 6.7.1 (Lab)--From other Terminal - STOP THE LOAD
root@minikube-n1:~# kubectl delete -f load-generator.yaml
/*
Error from server (NotFound): error when deleting "load-generator.yaml": pods "load-generator" not found
*/

--Step 6.8 (Lab)
root@minikube-n1:~# kubectl describe hpa php-apache -n hpa-demo
/*
Name:                                                  php-apache
Namespace:                                             hpa-demo
Labels:                                                <none>
Annotations:                                           <none>
CreationTimestamp:                                     Mon, 01 Jun 2026 16:14:35 +0545
Reference:                                             Deployment/php-apache
Metrics:                                               ( current / target )
  resource cpu on pods  (as a percentage of request):  0% (1m) / 50%
Min replicas:                                          1
Max replicas:                                          10
Deployment pods:                                       2 current / 2 desired
Conditions:
  Type            Status  Reason               Message
  ----            ------  ------               -------
  AbleToScale     True    ScaleDownStabilized  recent recommendations were higher than current one, applying the highest recent recommendation
  ScalingActive   True    ValidMetricFound     the HPA was able to successfully calculate a replica count from cpu resource utilization (percentage of request)
  ScalingLimited  False   DesiredWithinRange   the desired count is within the acceptable range
Events:
  Type    Reason             Age   From                       Message
  ----    ------             ----  ----                       -------
  Normal  SuccessfulRescale  28m   horizontal-pod-autoscaler  New size: 2; reason: cpu resource utilization (percentage of request) above target
  Normal  SuccessfulRescale  27m   horizontal-pod-autoscaler  New size: 4; reason: cpu resource utilization (percentage of request) above target
  Normal  SuccessfulRescale  27m   horizontal-pod-autoscaler  New size: 5; reason: cpu resource utilization (percentage of request) above target
  Normal  SuccessfulRescale  36s   horizontal-pod-autoscaler  New size: 2; reason: All metrics below target
*/

--Step 6.8.1 (Lab)
root@minikube-n1:~# kubectl describe hpa php-apache -n hpa-demo
/*
Name:                                                  php-apache
Namespace:                                             hpa-demo
Labels:                                                <none>
Annotations:                                           <none>
CreationTimestamp:                                     Mon, 01 Jun 2026 16:14:35 +0545
Reference:                                             Deployment/php-apache
Metrics:                                               ( current / target )
  resource cpu on pods  (as a percentage of request):  0% (1m) / 50%
Min replicas:                                          1
Max replicas:                                          10
Deployment pods:                                       1 current / 1 desired
Conditions:
  Type            Status  Reason            Message
  ----            ------  ------            -------
  AbleToScale     True    ReadyForNewScale  recommended size matches current size
  ScalingActive   True    ValidMetricFound  the HPA was able to successfully calculate a replica count from cpu resource utilization (percentage of request)
  ScalingLimited  True    TooFewReplicas    the desired replica count is less than the minimum replica count
Events:
  Type    Reason             Age   From                       Message
  ----    ------             ----  ----                       -------
  Normal  SuccessfulRescale  29m   horizontal-pod-autoscaler  New size: 2; reason: cpu resource utilization (percentage of request) above target
  Normal  SuccessfulRescale  28m   horizontal-pod-autoscaler  New size: 4; reason: cpu resource utilization (percentage of request) above target
  Normal  SuccessfulRescale  27m   horizontal-pod-autoscaler  New size: 5; reason: cpu resource utilization (percentage of request) above target
  Normal  SuccessfulRescale  86s   horizontal-pod-autoscaler  New size: 2; reason: All metrics below target
  Normal  SuccessfulRescale  25s   horizontal-pod-autoscaler  New size: 1; reason: All metrics below target
*/

--Q4: How long did scale-down take?
--Answer: It took approximately 5 minutes after the load was removed. 

--Q5:What replica count did it settle back to?
--Answer: It returned to the default replica count of 1 and Deployment pods are 1 current / 1 desired 

--Q6: What event messages do you see? What do they tell you?
--Answer: HPA increased replicas on high CPU usage and reduced them back to 1 when CPU usage fell below the target. 

--Q7: What is the difference between minReplicas and currentReplicas in the output?
--Answer:  minReplicas = allowed minimum, and currentReplicas = current running pods.


--Step 7 (Lab) - BONUS - SCALE FLOOR (Change minReplicas: 1 to 2)
root@minikube-n1:~# kubectl edit hpa php-apache -n hpa-demo
/*
# Please edit the object below. Lines beginning with a '#' will be ignored,
# and an empty file will abort the edit. If an error occurs while saving this file will be
# reopened with the relevant failures.
#
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"autoscaling/v2","kind":"HorizontalPodAutoscaler","metadata":{"annotations":{},"name":"php-apache","namespace":"hpa-demo"},"spec":{"maxReplicas":10,"metrics":[{"resource":{"name":"cpu","target":{"averageValue":"50m","type":"AverageValue"}},"type":"Resource"}],"minReplicas":1,"scaleTargetRef":{"apiVersion":"apps/v1","kind":"Deployment","name":"php-apache"}},"status":{"currentMetrics":null,"desiredReplicas":0}}
  creationTimestamp: "2026-05-31T11:41:32Z"
  name: php-apache
  namespace: hpa-demo
  resourceVersion: "2017"
  uid: a1e3653d-a810-4804-9352-4c62f514afcd
spec:
  maxReplicas: 10
  metrics:
  - resource:
      name: cpu
      target:
        averageValue: 50m
        type: AverageValue
    type: Resource
  minReplicas: 2
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: php-apache
status:
  conditions:
  - lastTransitionTime: "2026-05-31T11:41:48Z"
    message: recommended size matches current size
    reason: ReadyForNewScale
    status: "True"
    type: AbleToScale
  - lastTransitionTime: "2026-05-31T11:41:48Z"
    message: the HPA was able to successfully calculate a replica count from cpu resource
    reason: ValidMetricFound
    status: "True"
    type: ScalingActive
  - lastTransitionTime: "2026-05-31T11:41:48Z"
    message: the desired count is within the acceptable range
    reason: DesiredWithinRange
    status: "False"
    type: ScalingLimited
  currentMetrics:
  - resource:
      current:
        averageValue: 1m
      name: cpu
    type: Resource
  currentReplicas: 1
  desiredReplicas: 1
*/

/*
horizontalpodautoscaler.autoscaling/php-apache edited
*/                                                                                                                                                                         1,1           Top

--Step 7.0 (Lab)
root@minikube-n1:~# kubectl get hpa -n hpa-demo
/*
NAME         REFERENCE               TARGETS       MINPODS   MAXPODS   REPLICAS   AGE
php-apache   Deployment/php-apache   cpu: 0%/50%   2         10        2          43m
*/

--Step 7.1 (Lab)
root@minikube-n1:~# kubectl get pods -n hpa-demo -o wide -w
/*
NAME                          READY   STATUS    RESTARTS   AGE     IP            NODE           NOMINATED NODE   READINESS GATES
php-apache-5b7b8dbb4f-b4xmn   1/1     Running   0          38m     10.244.0.10   minikube       <none>           <none>
php-apache-5b7b8dbb4f-q96r7   1/1     Running   0          2m22s   10.244.1.24   minikube-m02   <none>           <none>
*/

--Step 7.1.1 (Lab)
root@minikube-n1:~# kubectl get pods -n hpa-demo
/*
NAME                          READY   STATUS    RESTARTS   AGE
php-apache-5b7b8dbb4f-b4xmn   1/1     Running   0          37m
php-apache-5b7b8dbb4f-q96r7   1/1     Running   0          87s
*/

--Q8: What happens to the running pods immediately after you change it?
--Answer: Another pod is created asap the change is made to the current HPA.

--Step 8 (Lab) - CUSTOM MIN=2
root@minikube-n1:~# kubectl autoscale deployment php-apache --cpu=50% --min=2 --max=10 -n hpa-demo --dry-run=client -o yaml
/*
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: php-apache
  namespace: hpa-demo
spec:
  maxReplicas: 10
  metrics:
  - resource:
      name: cpu
      target:
        averageUtilization: 50
        type: Utilization
    type: Resource
  minReplicas: 2
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: php-apache
status:
  currentMetrics: null
  desiredReplicas: 0
*/

--Step 8.1 (Lab)
root@minikube-n1:~# kubectl autoscale deployment php-apache --cpu=50% --min=2 --max=10 -n hpa-demo --dry-run=client -o yaml > hpa-2.yaml

--Step 8.1.1 (Lab) CUSTOM STABILISATION WINDOW
root@minikube-n1:~# vi hpa-2.yaml
/*
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: php-apache
  namespace: hpa-demo
spec:
  maxReplicas: 10
  metrics:
  - resource:
      name: cpu
      target:
        averageUtilization: 50
        type: Utilization
    type: Resource
  minReplicas: 2
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: php-apache
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 60
status:
  currentMetrics: null
  desiredReplicas: 0
*/

--Step 8.2 (Lab)
root@minikube-n1:~# kubectl apply -f hpa-2.yaml --dry-run=client
/*
horizontalpodautoscaler.autoscaling/php-apache configured (dry run)
*/

--Step 8.3 (Lab)
root@minikube-n1:~# kubectl apply -f hpa-2.yaml
/*
horizontalpodautoscaler.autoscaling/php-apache configured
*/

--Step 8.4 (Lab) - GENRATE LOAD AGAIN
root@minikube-n1:~# kubectl apply -f load-generator.yaml --dry-run=client
/*
pod/load-generator unchanged (dry run)
*/

--Step 8.5 (Lab)
root@minikube-n1:~# kubectl apply -f load-generator.yaml
/*
pod/load-generator created
*/

--Step 8.6 (Lab)
root@minikube-n1:~# kubectl get pod -n hpa-demo load-generator
/*
NAME             READY   STATUS    RESTARTS   AGE
load-generator   1/1     Running   0          52s
*/

--Step 8.7 (Lab) - Scaling
root@minikube-n1:~# kubectl get hpa php-apache -n hpa-demo -w
/*
NAME         REFERENCE               TARGETS       MINPODS   MAXPODS   REPLICAS   AGE
php-apache   Deployment/php-apache   cpu: 0%/50%   2         10        2          65m
*/

--Step 8.8 (Lab)--From other Terminal
root@minikube-n1:~#  kubectl get pods -n hpa-demo -o wide -w
/*
NAME                          READY   STATUS    RESTARTS   AGE   IP            NODE           NOMINATED NODE   READINESS GATES
load-generator                1/1     Running   0          60s   10.244.1.25   minikube-m02   <none>           <none>
php-apache-5b7b8dbb4f-b4xmn   1/1     Running   0          58m   10.244.0.10   minikube       <none>           <none>
php-apache-5b7b8dbb4f-q96r7   1/1     Running   0          22m   10.244.1.24   minikube-m02   <none>           <none>
load-generator                1/1     Terminating   0          6m6s   10.244.1.25   minikube-m02   <none>           <none>
load-generator                1/1     Terminating   0          6m7s   10.244.1.25   minikube-m02   <none>           <none>
load-generator                0/1     Error         0          6m37s   10.244.1.25   minikube-m02   <none>           <none>
load-generator                0/1     Error         0          6m38s   10.244.1.25   minikube-m02   <none>           <none>
load-generator                0/1     Error         0          6m38s   10.244.1.25   minikube-m02   <none>           <none>
exi*/

--Step 8.9 (Lab)--From other Terminal
root@minikube-n1:~# kubectl describe hpa php-apache -n hpa-demo
/*
Name:                                                  php-apache
Namespace:                                             hpa-demo
Labels:                                                <none>
Annotations:                                           <none>
CreationTimestamp:                                     Mon, 01 Jun 2026 16:14:35 +0545
Reference:                                             Deployment/php-apache
Metrics:                                               ( current / target )
  resource cpu on pods  (as a percentage of request):  0% (1m) / 50%
Min replicas:                                          2
Max replicas:                                          10
Behavior:
  Scale Up:
    Stabilization Window: 0 seconds
    Select Policy: Max
    Policies:
      - Type: Pods     Value: 4    Period: 15 seconds
      - Type: Percent  Value: 100  Period: 15 seconds
  Scale Down:
    Stabilization Window: 60 seconds
    Select Policy: Max
    Policies:
      - Type: Percent  Value: 100  Period: 15 seconds
Deployment pods:       2 current / 2 desired
Conditions:
  Type            Status  Reason            Message
  ----            ------  ------            -------
  AbleToScale     True    ReadyForNewScale  recommended size matches current size
  ScalingActive   True    ValidMetricFound  the HPA was able to successfully calculate a replica count from cpu resource utilization (percentage of request)
  ScalingLimited  True    TooFewReplicas    the desired replica count is less than the minimum replica count
Events:
  Type    Reason             Age   From                       Message
  ----    ------             ----  ----                       -------
  Normal  SuccessfulRescale  39m   horizontal-pod-autoscaler  New size: 2; reason: All metrics below target
  Normal  SuccessfulRescale  38m   horizontal-pod-autoscaler  New size: 1; reason: All metrics below target
  Normal  SuccessfulRescale  30m   horizontal-pod-autoscaler  New size: 2; reason: Current number of replicas below Spec.MinReplicas
*/

--Step 8.10 (Lab)--From other Terminal - STOP THE LOAD
root@minikube-n1:~# kubectl delete -f load-generator.yaml
/*
pod "load-generator" deleted from hpa-demo namespace
*/

--Step 8.10.1 (Lab)--From other Terminal - STOP THE LOAD
root@minikube-n1:~# kubectl delete -f load-generator.yaml
/*
Error from server (NotFound): error when deleting "load-generator.yaml": pods "load-generator" not found
*/

--Step 8.11 (Lab)
root@minikube-n1:~# kubectl describe hpa php-apache -n hpa-demo
/*
Name:                                                  php-apache
Namespace:                                             hpa-demo
Labels:                                                <none>
Annotations:                                           <none>
CreationTimestamp:                                     Mon, 01 Jun 2026 16:14:35 +0545
Reference:                                             Deployment/php-apache
Metrics:                                               ( current / target )
  resource cpu on pods  (as a percentage of request):  0% (1m) / 50%
Min replicas:                                          2
Max replicas:                                          10
Behavior:
  Scale Up:
    Stabilization Window: 0 seconds
    Select Policy: Max
    Policies:
      - Type: Pods     Value: 4    Period: 15 seconds
      - Type: Percent  Value: 100  Period: 15 seconds
  Scale Down:
    Stabilization Window: 60 seconds
    Select Policy: Max
    Policies:
      - Type: Percent  Value: 100  Period: 15 seconds
Deployment pods:       2 current / 2 desired
Conditions:
  Type            Status  Reason            Message
  ----            ------  ------            -------
  AbleToScale     True    ReadyForNewScale  recommended size matches current size
  ScalingActive   True    ValidMetricFound  the HPA was able to successfully calculate a replica count from cpu resource utilization (percentage of request)
  ScalingLimited  True    TooFewReplicas    the desired replica count is less than the minimum replica count
Events:
  Type    Reason             Age   From                       Message
  ----    ------             ----  ----                       -------
  Normal  SuccessfulRescale  38m   horizontal-pod-autoscaler  New size: 2; reason: All metrics below target
  Normal  SuccessfulRescale  37m   horizontal-pod-autoscaler  New size: 1; reason: All metrics below target
  Normal  SuccessfulRescale  29m   horizontal-pod-autoscaler  New size: 2; reason: Current number of replicas below Spec.MinReplicas
*/
