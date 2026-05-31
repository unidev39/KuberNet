--Step 1 (Lab)
root@minikube-n1:~# minikube start --nodes 2 --cpus 2 --memory 2048 --force
/*
* minikube v1.38.1 on Ubuntu 24.04
! minikube skips various validations when --force is supplied; this may lead to unexpected be                                                                                                havior
* Automatically selected the docker driver. Other choices: ssh, none
* The "docker" driver should not be used with root privileges. If you wish to continue as roo                                                                                                t, use --force.
* If you are running minikube within a VM, consider using --driver=none:
*   https://minikube.sigs.k8s.io/docs/reference/drivers/none/
! Starting v1.39.0, minikube will default to "containerd" container runtime. See #21973 for m                                                                                                ore info.
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

--Step 3 (Lab)
root@minikube-n1:~# kubectl create namespace hpa-demo --dry-run=client -o yaml > namespace.yaml

--Step 3.1 (Lab)
root@minikube-n1:~# cat namespace.yaml
/*
apiVersion: v1
kind: Namespace
metadata:
  name: hpa-demo
spec: {}
status: {}
*/

--Step 3.2 (Lab)
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

--Step 4 (Lab)
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

--Step 4.1 (Lab)
root@minikube-n1:~# kubectl create deployment php-apache --image=registry.k8s.io/hpa-example -n hpa-demo --dry-run=client -o yaml > deployment.yaml

--Step 4.1 (Lab)
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

--Step 4.4 (Lab)
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

--Step 4.6 (Lab)
root@minikube-n1:~# kubectl get pods -A
/*
NAMESPACE     NAME                               READY   STATUS    RESTARTS   AGE
hpa-demo      php-apache-5b7b8dbb4f-4777j        1/1     Running   0          100s
kube-system   coredns-7d764666f9-k8j67           1/1     Running   0          17m
kube-system   etcd-minikube                      1/1     Running   0          17m
kube-system   kindnet-8sczj                      1/1     Running   0          17m
kube-system   kindnet-lj64s                      1/1     Running   0          15m
kube-system   kube-apiserver-minikube            1/1     Running   0          17m
kube-system   kube-controller-manager-minikube   1/1     Running   0          17m
kube-system   kube-proxy-4jp2t                   1/1     Running   0          17m
kube-system   kube-proxy-k484z                   1/1     Running   0          15m
kube-system   kube-scheduler-minikube            1/1     Running   0          17m
kube-system   metrics-server-9d74bb658-ld5n6     1/1     Running   0          11m
kube-system   storage-provisioner                1/1     Running   0          17m
*/

--Step 4.7 (Lab)
root@minikube-n1:~# kubectl get pods -n hpa-demo -o wide
/*
NAME                          READY   STATUS    RESTARTS   AGE    IP           NODE           NOMINATED NODE   READINESS GATES
php-apache-5b7b8dbb4f-4777j   1/1     Running   0          104s   10.244.1.3   minikube-m02   <none>           <none>
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

--Step 5 (Lab)
root@minikube-n1:~# kubectl autoscale deployment php-apache --cpu=50 --min=1 --max=10 -n hpa-demo --dry-run=client -o yaml
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
        averageValue: 50m
        type: AverageValue
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
php-apache   Deployment/php-apache   cpu: 1m/50m   1         10        1          22s
*/

--Step 5.4 (Lab)
root@minikube-n1:~# kubectl get pods -n hpa-demo -o wide
/*
NAME                          READY   STATUS    RESTARTS   AGE   IP           NODE           NOMINATED NODE   READINESS GATES
php-apache-5b7b8dbb4f-4777j   1/1     Running   0          12m   10.244.1.3   minikube-m02   <none>           <none>
*/

--Step 6 (Lab)
root@minikube-n1:~# kubectl run load-generator -n hpa-demo --image=busybox \
   --restart=Never --dry-run=client -o yaml \
   -- /bin/sh -c "while true; do wget -q -O- http://192.1.6.37; done" \
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
  - name: load-generator
    image: busybox
    args:
      - "sh"
      - "-c"
      - "while true; do echo load; sleep 0.5; done"
    resources: {}

  dnsPolicy: ClusterFirst
  restartPolicy: Never
*/

--Step 6.1 (Lab)
root@minikube-n1:~# kubectl run load-generator -n hpa-demo --image=busybox \
   --restart=Never --dry-run=client -o yaml \
   -- /bin/sh -c "while true; do wget -q -O- http://192.1.6.37; done" \
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
root@minikube-n1:~# kubectl get pod load-generator -n hpa-demo
/*
NAME             READY   STATUS    RESTARTS   AGE
load-generator   1/1     Running   0          46s
*/

--Step 6.5 (Lab)
root@minikube-n1:~# kubectl get hpa php-apache -n hpa-demo -w
/*
NAME         REFERENCE               TARGETS       MINPODS   MAXPODS   REPLICAS   AGE
php-apache   Deployment/php-apache   cpu: 1m/50m   1         10        1          17m
*/

--Step 6.6 (Lab)--From other Terminal
root@minikube-n1:~# kubectl get pods -n hpa-demo -w
/*
NAME                          READY   STATUS    RESTARTS   AGE
load-generator                1/1     Running   0          2m
php-apache-5b7b8dbb4f-4777j   1/1     Running   0          29m
*/

--Step 6.7 (Lab)--From other Terminal
root@minikube-n1:~# kubectl delete -f load-generator.yaml
/*
pod "load-generator" deleted from hpa-demo namespace
*/

--Step 6.8 (Lab)
root@minikube-n1:~# kubectl describe hpa php-apache -n hpa-demo
/*
Name:                    php-apache
Namespace:               hpa-demo
Labels:                  <none>
Annotations:             <none>
CreationTimestamp:       Sun, 31 May 2026 17:26:32 +0545
Reference:               Deployment/php-apache
Metrics:                 ( current / target )
  resource cpu on pods:  1m / 50m
Min replicas:            1
Max replicas:            10
Deployment pods:         1 current / 1 desired
Conditions:
  Type            Status  Reason              Message
  ----            ------  ------              -------
  AbleToScale     True    ReadyForNewScale    recommended size matches current size
  ScalingActive   True    ValidMetricFound    the HPA was able to successfully calculate a replica count from cpu resource
  ScalingLimited  False   DesiredWithinRange  the desired count is within the acceptable range
Events:           <none>
*/

--Step 7 (Lab)
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

--Step 7.1 (Lab)
root@minikube-n1:~# kubectl get pods -n hpa-demo -o wide -w
/*
NAME                          READY   STATUS    RESTARTS   AGE    IP           NODE           NOMINATED NODE   READINESS GATES
php-apache-5b7b8dbb4f-4777j   1/1     Running   0          39m    10.244.1.3   minikube-m02   <none>           <none>
php-apache-5b7b8dbb4f-vqvsp   1/1     Running   0          2m4s   10.244.0.3   minikube       <none>           <none>
*/

--Step 8 (Lab)
root@minikube-n1:~# kubectl autoscale deployment php-apache --cpu=50 --min=2 --max=10 -n hpa-demo --dry-run=client -o yaml
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
        averageValue: 50m
        type: AverageValue
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
root@minikube-n1:~# kubectl autoscale deployment php-apache --cpu=50 --min=2 --max=10 -n hpa-demo --dry-run=client -o yaml > hpa-2.yaml

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

--Step 8.4 (Lab)
root@minikube-n1:~# kubectl get hpa php-apache -n hpa-demo -w
/*
NAME         REFERENCE               TARGETS       MINPODS   MAXPODS   REPLICAS   AGE
php-apache   Deployment/php-apache   cpu: 1m/50m   2         10        2          33m
*/