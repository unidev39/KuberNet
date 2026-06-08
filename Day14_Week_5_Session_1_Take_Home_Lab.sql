--Kubernetes Networking: NodePort & LoadBalancer

--Step 1 (Lab)
--Prerequisites
root@minikube-n1:~# minikube delete --all
/*
* Deleting "minikube" in docker ...
* Removing /root/.minikube/machines/minikube ...
* Removing /root/.minikube/machines/minikube-m02 ...
* Removed all traces of the "minikube" cluster.
* Successfully deleted all profiles
*/

--Step 1.1 (Lab)
--# Start Minikube
root@minikube-n1:~# minikube start --force
/*
* minikube v1.38.1 on Ubuntu 24.04
! minikube skips various validations when --force is supplied; this may lead to unexpected be havior
* Automatically selected the docker driver. Other choices: none, ssh
* The "docker" driver should not be used with root privileges. If you wish to continue as root, use --force.
* If you are running minikube within a VM, consider using --driver=none:
*   https://minikube.sigs.k8s.io/docs/reference/drivers/none/
! Starting v1.39.0, minikube will default to "containerd" container runtime. See #21973 for more info.
* Using Docker driver with root privileges
* Starting "minikube" primary control-plane node in "minikube" cluster
* Pulling base image v0.0.50 ...
* Creating docker container (CPUs=2, Memory=3072MB) ...
* Preparing Kubernetes v1.35.1 on Docker 29.2.1 ...
* Configuring bridge CNI (Container Networking Interface) ...
* Verifying Kubernetes components...
  - Using image gcr.io/k8s-minikube/storage-provisioner:v5
* Enabled addons: storage-provisioner, default-storageclass
* Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
*/

--Step 1.2 (Lab)
--# Enable the addons you'll need
root@minikube-n1:~# minikube addons enable metallb
/*
! metallb is a 3rd party addon and is not maintained or verified by minikube maintainers, enable at your own risk.
! metallb does not currently have an associated maintainer.
  - Using image quay.io/metallb/speaker:v0.9.6
  - Using image quay.io/metallb/controller:v0.9.6
* The 'metallb' addon is enabled
*/

--Step 1.3 (Lab)
--# Verify
root@minikube-n1:~# minikube addons list | grep -E "metallb"
/*
│ metallb                     │ minikube │ enabled ✅ │ 3rd party (MetalLB)    
*/

--Step 1.4 (Lab)
root@minikube-n1:~# alias k=kubectl

--Step 1.5 (Lab)
root@minikube-n1:~# k get ns -o wide
/*
NAME              STATUS   AGE
default           Active   4m2s
kube-node-lease   Active   4m2s
kube-public       Active   4m2s
kube-system       Active   4m2s
metallb-system    Active   2m32s
*/

--Step 1.6 (Lab)
root@minikube-n1:~# k get nodes -o wide
/*
NAME       STATUS   ROLES           AGE     VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE                         KERNEL-VERSION      CONTAINER-RUNTIME
minikube   Ready    control-plane   4m13s   v1.35.1   192.168.49.2   <none>        Debian GNU/Linux 12 (bookworm)   6.8.0-111-generic   docker://29.2.1
*/

--Step 1.7 (Lab)
root@minikube-n1:~# k get pods -A -o wide
/*
NAMESPACE        NAME                               READY   STATUS    RESTARTS        AGE     IP             NODE       NOMINATED NODE   READINESS GATES
kube-system      coredns-7d764666f9-jjrkk           1/1     Running   0               4m18s   10.244.0.3     minikube   <none>           <none>
kube-system      etcd-minikube                      1/1     Running   0               4m27s   192.168.49.2   minikube   <none>           <none>
kube-system      kube-apiserver-minikube            1/1     Running   0               4m23s   192.168.49.2   minikube   <none>           <none>
kube-system      kube-controller-manager-minikube   1/1     Running   0               4m31s   192.168.49.2   minikube   <none>           <none>
kube-system      kube-proxy-sv977                   1/1     Running   0               4m19s   192.168.49.2   minikube   <none>           <none>
kube-system      kube-scheduler-minikube            1/1     Running   0               4m30s   192.168.49.2   minikube   <none>           <none>
kube-system      storage-provisioner                1/1     Running   1 (3m43s ago)   4m17s   192.168.49.2   minikube   <none>           <none>
metallb-system   controller-cff57fcb5-57djh         1/1     Running   0               3m      10.244.0.4     minikube   <none>           <none>
metallb-system   speaker-zfzcl                      1/1     Running   0               3m      192.168.49.2   minikube   <none>           <none>
*/

--Step 2 (Lab)
--Task 1 — "Customers can't reach the store" (LoadBalancer)
--Step 1: Configure MetalLB IP pool
--Get your Minikube IP:
root@minikube-n1:~# minikube ip
/*
192.168.49.2
*/

--Step 2.1 (Lab)
--Create the MetalLB config — pick a small range just above your Minikube IP:
--# metallb-config.yaml
root@minikube-n1:~# vi metallb-config.yaml
/*
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 192.168.49.100-192.168.49.150
*/

--Step 2.2 (Lab)
root@minikube-n1:~# k apply -f metallb-config.yaml --dry-run=client
/*
configmap/config configured (dry run)
*/

--Step 2.3 (Lab)
root@minikube-n1:~# k apply -f metallb-config.yaml
/*
configmap/config configured
*/

--Step 2.4 (Lab)
--Check that MetalLB pods are running:
root@minikube-n1:~# k get pods -n metallb-system
/*
NAME                         READY   STATUS    RESTARTS   AGE
controller-cff57fcb5-57djh   1/1     Running   0          20m
speaker-zfzcl                1/1     Running   0          20m
*/

--Step 2.5 (Lab)
--Check the ConfigMap: Verify the address pool:
root@minikube-n1:~# k get configmap config -n metallb-system -o yaml
/*
apiVersion: v1
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 192.168.49.100-192.168.49.150
kind: ConfigMap
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","data":{"config":"address-pools:\n- name: default\n  protocol: layer2\n  addresses:\n  - 192.168.49.100-192.168.49.150\n"},"kind":"ConfigMap","metadata":{"annotations":{},"name":"config","namespace":"metallb-system"}}
  creationTimestamp: "2026-06-06T09:42:51Z"
  name: config
  namespace: metallb-system
  resourceVersion: "1078"
  uid: 084a4d9b-ec26-47c0-8e09-593c7dc383c6
*/

--Step 3 (Lab)
--Step 2: Deploy the frontend
root@minikube-n1:~# vi store-frontend.yaml
/*
apiVersion: apps/v1
kind: Deployment
metadata:
  name: store-frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: store-frontend
  template:
    metadata:
      labels:
        app: store-frontend
    spec:
      containers:
      - name: frontend
        image: nginx:alpine
        ports:
        - containerPort: 80
        volumeMounts:
        - name: html
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html
        configMap:
          name: frontend-html
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: frontend-html
data:
  index.html: |
    <!DOCTYPE html>
    <html>
      <body style="font-family:sans-serif;text-align:center;padding:50px">
        <h1>🛒 KiranaShop</h1>
        <p>Fresh groceries delivered to your door.</p>
        <p><em>Served by Pod: will show hostname via server-side include</em></p>
      </body>
    </html>
*/

--Step 3.1 (Lab)
root@minikube-n1:~# k apply -f store-frontend.yaml --dry-run=client
/*
deployment.apps/store-frontend created (dry run)
configmap/frontend-html created (dry run)
*/

--Step 3.2 (Lab)
root@minikube-n1:~# k apply -f store-frontend.yaml
/*
deployment.apps/store-frontend created
configmap/frontend-html created
*/

--Step 3.3 (Lab)
--Check deployment:
root@minikube-n1:~# k get deployment store-frontend
/*
NAME             READY   UP-TO-DATE   AVAILABLE   AGE
store-frontend   2/2     2            2           7m35s
*/

--Step 3.4 (Lab)
root@minikube-n1:~# k get deployment store-frontend -o wide
/*
NAME             READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS   IMAGES         SELECTOR
store-frontend   2/2     2            2           8m17s   frontend     nginx:alpine   app=store-frontend
*/

--Step 3.5 (Lab)
--Check pods:
root@minikube-n1:~# k get pods -l app=store-frontend -o wide
/*
NAME                              READY   STATUS    RESTARTS   AGE     IP           NODE       NOMINATED NODE   READINESS GATES
store-frontend-74c9fd8859-276bt   1/1     Running   0          8m47s   10.244.0.5   minikube   <none>           <none>
store-frontend-74c9fd8859-4pbtl   1/1     Running   0          8m47s   10.244.0.6   minikube   <none>           <none>
*/

--Step 3.6 (Lab)
--Step 3: Expose as LoadBalancer service
root@minikube-n1:~# k expose deployment store-frontend \
  --type=LoadBalancer \
  --port=80 \
  --name=store-frontend-svc
/*
service/store-frontend-svc exposed
*/

--Step 3.7 (Lab)
--Step 4: Verify
--# Wait until EXTERNAL-IP is assigned (not <pending>)
root@minikube-n1:~# k get svc store-frontend-svc
/*
NAME                 TYPE           CLUSTER-IP    EXTERNAL-IP      PORT(S)        AGE
store-frontend-svc   LoadBalancer   10.105.50.2   192.168.49.100   80:32055/TCP   86s
*/

--Step 4 (Lab)
--Step 4: Verify
root@minikube-n1:~# k get svc store-frontend-svc -o wide
/*
NAME                 TYPE           CLUSTER-IP    EXTERNAL-IP      PORT(S)        AGE   SELECTOR
store-frontend-svc   LoadBalancer   10.105.50.2   192.168.49.100   80:32055/TCP   91s   app=store-frontend
*/

--Step 4.1 (Lab)
--# Copy the printed URL and open it in your browser or curl it
root@minikube-n1:~# minikube service store-frontend-svc --url
/*
http://192.168.49.2:32055
*/

--Step 4.2 (Lab)
--# Linux with native driver only
root@minikube-n1:~# curl http://192.168.49.2:32055
/*
<!DOCTYPE html>
<html>
  <body style="font-family:sans-serif;text-align:center;padding:50px">
    <h1>🛒 KiranaShop</h1>
    <p>Fresh groceries delivered to your door.</p>
    <p><em>Served by Pod: will show hostname via server-side include</em></p>
  </body>
</html>
*/

--Step 5 (Lab)
--Task 2 — "The API must never be public" (ClusterIP review)
--Background
--store-api is KiranaShop's internal REST API. It handles orders, inventory, and payments. Exposing it to the internet would be a security disaster. A ClusterIP Service ensures it is only reachable from within the cluster.
--Step 1: Deploy the API
root@minikube-n1:~# vi store-api.yaml
/*
apiVersion: apps/v1
kind: Deployment
metadata:
  name: store-api
spec:
  replicas: 2
  selector:
    matchLabels:
      app: store-api
  template:
    metadata:
      labels:
        app: store-api
    spec:
      containers:
      - name: api
        image: hashicorp/http-echo:alpine
        args:
        - "-text=KiranaShop API v1 — internal only"
        - "-listen=:5678"
        ports:
        - containerPort: 5678
*/

--Step 5.1 (Lab)
root@minikube-n1:~# k apply -f store-api.yaml --dry-run=client
/*
deployment.apps/store-api created (dry run)
*/

--Step 5.2 (Lab)
root@minikube-n1:~# k apply -f store-api.yaml
/*
deployment.apps/store-api created
*/

--Step 5.3 (Lab)
root@minikube-n1:~# k get deployment store-api -o wide
/*
NAME        READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES                       SELECTOR
store-api   2/2     2            2           92s   api          hashicorp/http-echo:alpine   app=store-api
*/

--Step 5.4 (Lab)
root@minikube-n1:~# k get pods -l app=store-api -o wide
/*
NAME                         READY   STATUS    RESTARTS   AGE     IP           NODE       NOMINATED NODE   READINESS GATES
store-api-5c5887d5fb-8ddn7   1/1     Running   0          2m23s   10.244.0.7   minikube   <none>           <none>
store-api-5c5887d5fb-ljxjw   1/1     Running   0          2m23s   10.244.0.8   minikube   <none>           <none>
*/

--Step 5.5 (Lab) - Service
root@minikube-n1:~# k expose deployment store-api \
  --type=ClusterIP \
  --port=80 \
  --target-port=5678 \
  --name=store-api-svc
/*
service/store-api-svc exposed
*/

--Step 5.6 (Lab)
--Step 2: Prove it is unreachable from outside
--# EXTERNAL-IP should be <none>
root@minikube-n1:~# k get svc store-api-svc
/*
NAME            TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
store-api-svc   ClusterIP   10.104.45.250   <none>        80/TCP    75s
*/

--Step 5.7 (Lab)
root@minikube-n1:~# k get svc store-api-svc -o wide
/*
NAME            TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE   SELECTOR
store-api-svc   ClusterIP   10.104.45.250   <none>        80/TCP    79s   app=store-api
*/

--Step 5.8 (Lab)
--# This should FAIL (no external IP):
--curl http://<ClusterIP>        # ClusterIP is not routable from your laptop
root@minikube-n1:~# curl http://10.104.45.250:80

--Step 6 (Lab)
--Step 3: Prove it works from inside the cluster - Service created and deleted
root@minikube-n1:~# k run test-pod --rm -it --image=busybox -- sh
/*
All commands and output from this session will be recorded in container logs, including credentials and sensitive information passed through the command prompt.
If you don't see a command prompt, try pressing enter.
/ # wget -qO- http://store-api-svc
KiranaShop API v1 — internal only
/ # exit
Session ended, resume using 'kubectl attach test-pod -c test-pod -n default -i -t' command
pod "test-pod" deleted from default namespace
*/  

--Step 6.1 (Lab)
root@minikube-n1:~# k get svc -o wide
/*
NAME                 TYPE           CLUSTER-IP       EXTERNAL-IP      PORT(S)        AGE     SELECTOR
kubernetes           ClusterIP      10.96.0.1        <none>           443/TCP        30m     <none>
store-api-svc        ClusterIP      10.110.230.247   <none>           80/TCP         7m23s   app=store-api
store-frontend-svc   LoadBalancer   10.97.242.155    192.168.49.100   80:32246/TCP   9m47s   app=store-frontend
*/

--Step 7 (Lab)
--Task 3 — "Ops needs metrics, customers don't" (NodePort)
--Background
--The ops team needs to access KiranaShop's metrics dashboard from their laptops without going through the customer-facing LB. NodePort is a pragmatic choice for internal ops tooling in small clusters — it uses a fixed port on every node, accessible from within the team's network.
--Step 1: Deploy metrics service
root@minikube-n1:~# vi store-metrics.yaml
/*
apiVersion: apps/v1
kind: Deployment
metadata:
  name: store-metrics
spec:
  replicas: 1
  selector:
    matchLabels:
      app: store-metrics
  template:
    metadata:
      labels:
        app: store-metrics
    spec:
      containers:
      - name: metrics
        image: nginx:alpine
        ports:
        - containerPort: 80
        volumeMounts:
        - name: html
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html
        configMap:
          name: metrics-html
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: metrics-html
data:
  index.html: |
    <!DOCTYPE html>
    <html>
      <body style="font-family:monospace;padding:30px;background:#111;color:#0f0">
        <h2>KiranaShop Ops Dashboard</h2>
        <p>CPU: 23% | Memory: 41% | Orders/min: 142</p>
        <p style="color:#ff0">⚠ This page is for internal ops only.</p>
      </body>
    </html>
*/

--Step 7.1 (Lab)
root@minikube-n1:~# k apply -f store-metrics.yaml --dry-run=client
/*
deployment.apps/store-metrics created (dry run)
configmap/metrics-html created (dry run)
*/

--Step 7.2 (Lab)
root@minikube-n1:~# k apply -f store-metrics.yaml
/*
deployment.apps/store-metrics created
configmap/metrics-html created
*/

--Step 7.3 (Lab) - Service
root@minikube-n1:~# k expose deployment store-metrics \
  --type=NodePort \
  --port=80 \
  --name=store-metrics-svc
/*
service/store-metrics-svc exposed
*/

--Step 7.4 (Lab)
--Step 2: Access it
--# Note the NodePort (e.g. 80:31452/TCP)
root@minikube-n1:~# k get svc store-metrics-svc
/*
NAME                TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
store-metrics-svc   NodePort   10.106.43.112   <none>        80:30498/TCP   23s
*/

--Step 7.5 (Lab)
root@minikube-n1:~# k get svc store-metrics-svc -o wide
/*
NAME                TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE   SELECTOR
store-metrics-svc   NodePort   10.106.43.112   <none>        80:30498/TCP   29s   app=store-metrics
*/

--Step 7.6 (Lab)
--# Linux with native driver (kvm2/virtualbox) — node IP is directly routable
--curl http://$(minikube ip):<NodePort>
root@minikube-n1:~# minikube ip
/*
192.168.49.2
*/

--Step 7.7 (Lab)
root@minikube-n1:~# curl http://192.168.49.2:30498
/*
<!DOCTYPE html>
<html>
  <body style="font-family:monospace;padding:30px;background:#111;color:#0f0">
    <h2>KiranaShop Ops Dashboard</h2>
    <p>CPU: 23% | Memory: 41% | Orders/min: 142</p>
    <p style="color:#ff0">⚠ This page is for internal ops only.</p>
  </body>
</html>
*/

--Step 7.8 (Lab)
--# macOS / Windows (Docker driver) — node IP not directly routable, use tunnel
--Open the printed URL in your browser — you should see the ops dashboard.
root@minikube-n1:~# minikube service store-metrics-svc --url
/*
http://192.168.49.2:30498
*/

--Step 7.9 (Lab)
root@minikube-n1:~# curl http://192.168.49.2:30498
/*
<!DOCTYPE html>
<html>
  <body style="font-family:monospace;padding:30px;background:#111;color:#0f0">
    <h2>KiranaShop Ops Dashboard</h2>
    <p>CPU: 23% | Memory: 41% | Orders/min: 142</p>
    <p style="color:#ff0">⚠ This page is for internal ops only.</p>
  </body>
</html>
*/

--Step 8 (Lab)
--Task 4 — "The storefront went down after a hotfix deploy" (Debugging)
--Background
--The KiranaShop dev team pushed a hotfix. Five minutes later, customers report the website is unreachable. 
--You check — the Pod is Running, the Service exists — but something is wrong. This is one of the most common Kubernetes 
--networking bugs in production.

--Step 1: Simulate the broken hotfix deploy
--Real-world note: Kubernetes Deployment selectors are immutable after creation. When a team deploys a new version with 
--changed labels, they delete the old Deployment and create a new one — leaving the Service stranded with a stale selector. 
--That is exactly what we are simulating here.

--# Simulate the team deleting + redeploying with changed labels
root@minikube-n1:~# k delete deployment store-frontend
/*
deployment.apps "store-frontend" deleted from default namespace
*/

--Step 8.1 (Lab)
--Now apply the broken config (selector and Pod labels both changed to app: frontend):
--# store-frontend-broken.yaml
root@minikube-n1:~# vi store-frontend-broken.yaml
/*
apiVersion: apps/v1
kind: Deployment
metadata:
  name: store-frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: frontend            # ← hotfix changed this label
  template:
    metadata:
      labels:
        app: frontend          # ← but Service still selects app: store-frontend
    spec:
      containers:
      - name: frontend
        image: nginx:alpine
        ports:
        - containerPort: 80
        volumeMounts:
        - name: html
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html
        configMap:
          name: frontend-html
*/

--Step 8.2 (Lab)
root@minikube-n1:~# k apply -f store-frontend-broken.yaml --dry-run=client
/*
deployment.apps/store-frontend created (dry run)
*/

--Step 8.3 (Lab)
root@minikube-n1:~# k apply -f store-frontend-broken.yaml
/*
deployment.apps/store-frontend created
*/

--Step 8.4 (Lab)
--Try to reach the frontend — it will fail or return errors.
--Step 2: Diagnose
--Use these commands to find the problem:

--Step 8.5 (Lab)
--# Is the Service there?
root@minikube-n1:~# k get svc store-frontend-svc
/*
NAME                 TYPE           CLUSTER-IP    EXTERNAL-IP      PORT(S)        AGE
store-frontend-svc   LoadBalancer   10.105.50.2   192.168.49.100   80:32055/TCP   47m
*/

--Step 8.5.1 (Lab)
root@minikube-n1:~# k get svc store-frontend-svc -o wide
/*
NAME                 TYPE           CLUSTER-IP    EXTERNAL-IP      PORT(S)        AGE   SELECTOR
store-frontend-svc   LoadBalancer   10.105.50.2   192.168.49.100   80:32055/TCP   47m   app=store-frontend
*/

--Step 8.6 (Lab)
--# Do any Pods match?
root@minikube-n1:~# k get endpoints store-frontend-svc
/*
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME                 ENDPOINTS   AGE
store-frontend-svc   <none>      47m
*/

--Step 8.6.1 (Lab)
root@minikube-n1:~# k get endpoints store-frontend-svc -o wide
/*
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME                 ENDPOINTS   AGE
store-frontend-svc   <none>      48m
*/

--Step 8.7 (Lab)
--# What labels do the Pods actually have?
--# tries old label — returns nothing
root@minikube-n1:~# k get pods -l app=store-frontend
/*
No resources found in default namespace.
*/

--Step 8.8 (Lab)
--# shows all labels on all Pods
root@minikube-n1:~# k get pods --show-labels
/*
NAME                             READY   STATUS             RESTARTS         AGE     LABELS
store-api-5c5887d5fb-8ddn7       1/1     Running            0                40m     app=store-api,pod-template-hash=5c5887d5fb
store-api-5c5887d5fb-ljxjw       1/1     Running            0                40m     app=store-api,pod-template-hash=5c5887d5fb
store-frontend-8d5f48cc9-85wjd   1/1     Running            0                4m29s   app=frontend,pod-template-hash=8d5f48cc9
store-frontend-8d5f48cc9-fb8kx   1/1     Running            0                4m29s   app=frontend,pod-template-hash=8d5f48cc9
store-metrics-67b67f4b7d-rptzb   1/1     Running            0                25m     app=store-metrics,pod-template-hash=67b67f4b7d
*/

--Step 8.9 (Lab)
--# What selector does the Service use?
--You should find: ENDPOINTS: <none> — the Service has no Pods to send traffic to. The Service selector says app=store-frontend but 
--all Pods now have app=frontend.
root@minikube-n1:~# k describe svc store-frontend-svc | grep Selector
/*
Selector:                 app=store-frontend
*/

--Step 8.9.1 (Lab)
root@minikube-n1:~# k describe svc store-frontend-svc
/*
Name:                     store-frontend-svc
Namespace:                default
Labels:                   <none>
Annotations:              <none>
Selector:                 app=store-frontend
Type:                     LoadBalancer
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       10.105.50.2
IPs:                      10.105.50.2
LoadBalancer Ingress:     192.168.49.100 (VIP)
Port:                     <unset>  80/TCP
TargetPort:               80/TCP
NodePort:                 <unset>  32055/TCP
Endpoints:
Session Affinity:         None
External Traffic Policy:  Cluster
Internal Traffic Policy:  Cluster
Events:
  Type    Reason        Age                  From                Message
  ----    ------        ----                 ----                -------
  Normal  IPAllocated   51m                  metallb-controller  Assigned IP "192.168.49.100"
  Normal  nodeAssigned  7m49s (x2 over 51m)  metallb-speaker     announcing from node "minikube"
*/

--Step 9 (Lab)
--Step 3: Fix it
--Two valid approaches — choose one and explain your reasoning
--Fix A — Update the Service selector (no downtime, fastest):
root@minikube-n1:~# k patch svc store-frontend-svc  -p '{"spec":{"selector":{"app":"frontend"}}}'
/*
service/store-frontend-svc patched
*/

--Step 9.1 (Lab)
--# verify IPs appear
root@minikube-n1:~# k get endpoints store-frontend-svc
/*
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME                 ENDPOINTS                       AGE
store-frontend-svc   10.244.0.11:80,10.244.0.12:80   53m
*/

--Step 9.1.1 (Lab)
root@minikube-n1:~# k get endpoints store-frontend-svc -o wide
/*
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME                 ENDPOINTS                       AGE
store-frontend-svc   10.244.0.11:80,10.244.0.12:80   53m
*/

--Step 9.1.2 (Lab)
root@minikube-n1:~# k get svc
/*
NAME                 TYPE           CLUSTER-IP       EXTERNAL-IP      PORT(S)        AGE
kubernetes           ClusterIP      10.96.0.1        <none>           443/TCP        38m
store-api-svc        ClusterIP      10.110.230.247   <none>           80/TCP         15m
store-frontend-svc   LoadBalancer   10.97.242.155    192.168.49.100   80:32246/TCP   17m
store-metrics-svc    NodePort       10.107.148.122   <none>           80:32759/TCP   6m19s
*/

--Step 9.1.3 (Lab)
root@minikube-n1:~# k get deployment -o wide
/*
NAME             READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS   IMAGES                       SELECTOR
store-api        2/2     2            2           17m     api          hashicorp/http-echo:alpine   app=store-api
store-frontend   2/2     2            2           5m16s   frontend     nginx:alpine                 app=frontend
store-metrics    1/1     1            1           8m17s   metrics      nginx:alpine                 app=store-metrics
*/

--Step 9.2 (Lab)
--Fix B — Recreate the Deployment with correct labels (matches original convention):
root@minikube-n1:~# k delete deployment store-frontend
/*
deployment.apps "store-frontend" deleted from default namespace
*/

--Step 9.2.1 (Lab)
root@minikube-n1:~# k get deployment -o wide
/*
NAME            READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS   IMAGES                       SELECTOR
store-api       2/2     2            2           17m     api          hashicorp/http-echo:alpine   app=store-api
store-metrics   1/1     1            1           8m53s   metrics      nginx:alpine                 app=store-metrics
*/

--Step 9.3 (Lab)
--# original file with app: store-frontend
root@minikube-n1:~# cat store-frontend.yaml
/*
apiVersion: apps/v1
kind: Deployment
metadata:
  name: store-frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: store-frontend
  template:
    metadata:
      labels:
        app: store-frontend
    spec:
      containers:
      - name: frontend
        image: nginx:alpine
        ports:
        - containerPort: 80
        volumeMounts:
        - name: html
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html
        configMap:
          name: frontend-html
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: frontend-html
data:
  index.html: |
    <!DOCTYPE html>
    <html>
      <body style="font-family:sans-serif;text-align:center;padding:50px">
        <h1>🛒 KiranaShop</h1>
        <p>Fresh groceries delivered to your door.</p>
        <p><em>Served by Pod: will show hostname via server-side include</em></p>
      </body>
    </html>
*/

--Step 9.3.1 (Lab)
root@minikube-n1:~# k apply -f store-frontend.yaml --dry-run=client
/*
deployment.apps/store-frontend created (dry run)
configmap/frontend-html unchanged (dry run)
*/

--Step 9.3.2 (Lab)
root@minikube-n1:~# k apply -f store-frontend.yaml
/*
deployment.apps/store-frontend created
configmap/frontend-html unchanged
*/

--Step 9.4 (Lab)
root@minikube-n1:~# k get deployment -o wide
/*
NAME             READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES                       SELECTOR
store-api        2/2     2            2           20m   api          hashicorp/http-echo:alpine   app=store-api
store-frontend   2/2     2            2           2m    frontend     nginx:alpine                 app=store-frontend
store-metrics    1/1     1            1           11m   metrics      nginx:alpine                 app=store-metrics
*/

--Step 9.5 (Lab)
--# verify IPs appear
--Which fix is better? Fix A is faster but accepts the new label convention. Fix B restores the original convention — better if 
--your team has label standards. In production, Fix B is preferred: fix the root cause (the Deployment), not the symptom (the Service).
root@minikube-n1:~# k get endpoints store-frontend-svc
/*
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME                 ENDPOINTS   AGE
store-frontend-svc   <none>      57m
*/  

--Step 9.6 (Lab) --Infected selector inside the Service
root@minikube-n1:~# k get svc -o wide
/*
NAME                 TYPE           CLUSTER-IP       EXTERNAL-IP      PORT(S)        AGE   SELECTOR
kubernetes           ClusterIP      10.96.0.1        <none>           443/TCP        44m   <none>
store-api-svc        ClusterIP      10.110.230.247   <none>           80/TCP         21m   app=store-api
store-frontend-svc   LoadBalancer   10.97.242.155    192.168.49.100   80:32246/TCP   23m   app=frontend
store-metrics-svc    NodePort       10.107.148.122   <none>           80:32759/TCP   12m   app=store-metrics
*/

--Step 9.7 (Lab) --Infected selector inside the Service
root@minikube-n1:~# k get svc store-frontend-svc -o yaml | grep -A2 -i -E "selector"
/*
  selector:
    app: frontend
  sessionAffinity: None
*/

--Step 9.8 (Lab) --Infected selector inside the Service
root@minikube-n1:~# k get deployment store-frontend -o yaml  | grep -A2 -i -E "selector:"
/*
  selector:
    matchLabels:
      app: store-frontend
*/

--Step 9.9 (Lab) -- Service Deleted
root@minikube-n1:~# k delete svc store-frontend-svc
/*
service "store-frontend-svc" deleted from default namespace
*/

--Step 9.9 (Lab) -- Service Re-Created
root@minikube-n1:~# k expose deployment store-frontend --type=LoadBalancer --port=80 --name=store-frontend-svc
/*
service/store-frontend-svc exposed
*/

--Step 9.10 (Lab) -- Service Fixed
root@minikube-n1:~# k get svc store-frontend-svc -o yaml | grep -A2 -i -E "selector"
/*
  selector:
    app: store-frontend
  sessionAffinity: None
*/

--Step 9.10.1 (Lab) -- Service Fixed
root@minikube-n1:~# k get svc store-frontend-svc
/*
NAME                 TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)        AGE
store-frontend-svc   LoadBalancer   10.108.88.85   192.168.49.100   80:32397/TCP   111s
*/

--Step 9.10.2 (Lab) -- Service Fixed
root@minikube-n1:~# k get svc store-frontend-svc -o wide
/*
NAME                 TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)        AGE    SELECTOR
store-frontend-svc   LoadBalancer   10.108.88.85   192.168.49.100   80:32397/TCP   116s   app=store-frontend
*/

--Step 9.11 (Lab)
root@minikube-n1:~# k get endpoints store-frontend-svc -o wide
/*
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME                 ENDPOINTS                       AGE
store-frontend-svc   10.244.0.13:80,10.244.0.14:80   19s
*/

--Step 9.12 (Lab)
--Step 4: Verify recovery
--# Should show Pod IPs again, e.g. 10.244.0.5:80,10.244.0.6:80
root@minikube-n1:~# k get endpoints store-frontend-svc
/*
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME                 ENDPOINTS                       AGE
store-frontend-svc   10.244.0.13:80,10.244.0.14:80   8m5s
*/

--Step 9.13 (Lab)
root@minikube-n1:~# k get pods -A -o wide
/*
NAMESPACE        NAME                               READY   STATUS             RESTARTS         AGE     IP             NODE       NOMINATED NODE   READINESS GATES
default          store-api-5c5887d5fb-8ddn7         1/1     Running            0                50m     10.244.0.7     minikube   <none>           <none>
default          store-api-5c5887d5fb-ljxjw         1/1     Running            0                50m     10.244.0.8     minikube   <none>           <none>
default          store-frontend-74c9fd8859-l8zjz    1/1     Running            0                4m25s   10.244.0.14    minikube   <none>           <none>
default          store-frontend-74c9fd8859-prmmb    1/1     Running            0                4m25s   10.244.0.13    minikube   <none>           <none>
default          store-metrics-67b67f4b7d-rptzb     1/1     Running            0                36m     10.244.0.10    minikube   <none>           <none>
default          test-pod                           0/1     CrashLoopBackOff   12 (4m39s ago)   41m     10.244.0.9     minikube   <none>           <none>
kube-system      coredns-7d764666f9-jjrkk           1/1     Running            0                90m     10.244.0.3     minikube   <none>           <none>
kube-system      etcd-minikube                      1/1     Running            0                90m     192.168.49.2   minikube   <none>           <none>
kube-system      kube-apiserver-minikube            1/1     Running            0                90m     192.168.49.2   minikube   <none>           <none>
kube-system      kube-controller-manager-minikube   1/1     Running            0                90m     192.168.49.2   minikube   <none>           <none>
kube-system      kube-proxy-sv977                   1/1     Running            0                90m     192.168.49.2   minikube   <none>           <none>
kube-system      kube-scheduler-minikube            1/1     Running            0                90m     192.168.49.2   minikube   <none>           <none>
kube-system      storage-provisioner                1/1     Running            1 (89m ago)      90m     192.168.49.2   minikube   <none>           <none>
metallb-system   controller-cff57fcb5-57djh         1/1     Running            0                88m     10.244.0.4     minikube   <none>           <none>
metallb-system   speaker-zfzcl                      1/1     Running            0                88m     192.168.49.2   minikube   <none>           <none>
*/

--Step 9.14 (Lab)
root@minikube-n1:~# k get endpoints store-frontend-svc -o wide
/*
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME                 ENDPOINTS                       AGE
store-frontend-svc   10.244.0.13:80,10.244.0.14:80   9m23s
*/

--Step 9.15 (Lab)
--# Any platform
--Reflect
--Why does this happen so often? Labels are the glue between every Kubernetes resource — Deployments, Services, NetworkPolicies, 
--HPA. A typo or inconsistent label convention silently breaks traffic with no error message. Key lesson: Deployment selectors 
--are immutable. If you change them, you must delete and recreate the Deployment — and update the Service selector to match. 
--In production: always check kubectl get endpoints first when a Service stops routing.
root@minikube-n1:~# k get endpoints store-frontend-svc -o wide
/*
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME                 ENDPOINTS                       AGE
store-frontend-svc   10.244.0.13:80,10.244.0.14:80   9m23s
*/

--Step 9.16 (Lab)
root@minikube-n1:~# minikube service store-frontend-svc --url
/*
http://192.168.49.2:32683
*/

--Step 9.16.1 (Lab)
root@minikube-n1:~# curl http://192.168.49.2:32683
/*
<!DOCTYPE html>
<html>
  <body style="font-family:sans-serif;text-align:center;padding:50px">
    <h1>🛒 KiranaShop</h1>
    <p>Fresh groceries delivered to your door.</p>
    <p><em>Served by Pod: will show hostname via server-side include</em></p>
  </body>
</html>
*/
