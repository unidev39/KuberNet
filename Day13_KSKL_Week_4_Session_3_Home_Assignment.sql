--Step 1 (Lab) Prerequisites
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

--Step 1.1 (Lab)
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

--Step 1.2 (Lab)
root@minikube-n1:~# kubectl get ns
/*
NAME              STATUS   AGE
default           Active   3m31s
kube-node-lease   Active   3m31s
kube-public       Active   3m31s
kube-system       Active   3m31s
*/

--Step 1.3 (Lab)
root@minikube-n1:~# kubectl get nodes
/*
NAME           STATUS   ROLES           AGE     VERSION
minikube       Ready    control-plane   3m47s   v1.35.1
minikube-m02   Ready    <none>          93s     v1.35.1
root@minikube-n1:~# kubectl get nodes -o wide
NAME           STATUS   ROLES           AGE     VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE                         KERNEL-VERSION      CONTAINER-RUNTIME
minikube       Ready    control-plane   3m53s   v1.35.1   192.168.49.2   <none>        Debian GNU/Linux 12 (bookworm)   6.8.0-111-generic   docker://29.2.1
minikube-m02   Ready    <none>          99s     v1.35.1   192.168.49.3   <none>        Debian GNU/Linux 12 (bookworm)   6.8.0-111-generic   docker://29.2.1
*/

--Step 1.4 (Lab)
root@minikube-n1:~# kubectl get pods -A
/*
NAMESPACE     NAME                               READY   STATUS    RESTARTS   AGE
kube-system   coredns-7d764666f9-zqg2h           1/1     Running   0          4m28s
kube-system   etcd-minikube                      1/1     Running   0          4m33s
kube-system   kindnet-hbrnl                      1/1     Running   0          4m29s
kube-system   kindnet-j22m5                      1/1     Running   0          2m25s
kube-system   kube-apiserver-minikube            1/1     Running   0          4m33s
kube-system   kube-controller-manager-minikube   1/1     Running   0          4m40s
kube-system   kube-proxy-8pgtw                   1/1     Running   0          4m29s
kube-system   kube-proxy-w4zns                   1/1     Running   0          2m25s
kube-system   kube-scheduler-minikube            1/1     Running   0          4m39s
kube-system   storage-provisioner                1/1     Running   0          4m25s
*/

--Step 1.5 (Lab)
root@minikube-n1:~# kubectl get pods -A -o wide
/*
NAMESPACE     NAME                               READY   STATUS    RESTARTS   AGE     IP             NODE           NOMINATED NODE   READINESS GATES
kube-system   coredns-7d764666f9-zqg2h           1/1     Running   0          4m39s   10.244.0.2     minikube       <none>           <none>
kube-system   etcd-minikube                      1/1     Running   0          4m44s   192.168.49.2   minikube       <none>           <none>
kube-system   kindnet-hbrnl                      1/1     Running   0          4m40s   192.168.49.2   minikube       <none>           <none>
kube-system   kindnet-j22m5                      1/1     Running   0          2m36s   192.168.49.3   minikube-m02   <none>           <none>
kube-system   kube-apiserver-minikube            1/1     Running   0          4m44s   192.168.49.2   minikube       <none>           <none>
kube-system   kube-controller-manager-minikube   1/1     Running   0          4m51s   192.168.49.2   minikube       <none>           <none>
kube-system   kube-proxy-8pgtw                   1/1     Running   0          4m40s   192.168.49.2   minikube       <none>           <none>
kube-system   kube-proxy-w4zns                   1/1     Running   0          2m36s   192.168.49.3   minikube-m02   <none>           <none>
kube-system   kube-scheduler-minikube            1/1     Running   0          4m50s   192.168.49.2   minikube       <none>           <none>
kube-system   storage-provisioner                1/1     Running   0          4m36s   192.168.49.2   minikube       <none>           <none>
*/

--Step 2 (Lab)
--6. Task 1: Create a namespace
--Create a namespace for this assignment.
root@minikube-n1:~# kubectl create ns week4-session3
/*
namespace/week4-session3 created
*/

--Step 2.1 (Lab)
root@minikube-n1:~# vi 01-backend-deployment.yaml
/*
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: week4-session3
spec:
  replicas: 3
  selector:
    matchLabels:
      app: backend
      tier: api
  template:
    metadata:
      labels:
        app: backend
        tier: api
    spec:
      containers:
        - name: backend
          image: nginxdemos/hello:plain-text
          ports:
            - containerPort: 80
*/

--Step 2.2 (Lab)
root@minikube-n1:~# kubectl get pods -n week4-session3
/*
NAME                       READY   STATUS    RESTARTS   AGE
backend-65959585f7-6cfnz   1/1     Running   0          63s
backend-65959585f7-tdvv8   1/1     Running   0          63s
backend-65959585f7-xgnct   1/1     Running   0          63s
*/

--Step 2.3 (Lab)
root@minikube-n1:~# kubectl get pods -n week4-session3 -o wide
/*
NAME                       READY   STATUS    RESTARTS   AGE   IP           NODE           NOMINATED NODE   READINESS GATES
backend-65959585f7-6cfnz   1/1     Running   0          67s   10.244.1.2   minikube-m02   <none>           <none>
backend-65959585f7-tdvv8   1/1     Running   0          67s   10.244.1.3   minikube-m02   <none>           <none>
backend-65959585f7-xgnct   1/1     Running   0          67s   10.244.0.3   minikube       <none>           <none>
*/

--Step 2.4 (Lab)
--Write down the following in your notes:
/*
Backend Pod 1 IP: 10.244.1.2 => minikube-m02
Backend Pod 2 IP: 10.244.1.3 => minikube-m02
Backend Pod 3 IP: 10.244.0.3 => minikube
Node name: minikube-m02,minikube-m02, minikube
*/

--Step 2.5 (Lab)
--Prediction checkpoint
--Before moving to the next task, answer this:
--If a backend Pod is deleted and recreated, do you think it will always receive the same IP address?
--Yes or No? Why?

--No => When a Pod is deleted, Kubernetes creates a new Pod object as a replacement.
--      The new Pod is assigned an IP address from the available IP pool, and there is no guarantee 
--      that it will receive the same IP address as the deleted Pod. In most cases, the replacement 
--      Pod is assigned a different IP address.

--Step 3 (Lab)
--8. Task 3: Create a temporary client Pod
--Create a client Pod that you will use for testing communication.
root@minikube-n1:~# kubectl run client \
  -n week4-session3 \
  --image=curlimages/curl:8.10.1 \
  --command -- sleep 3600
/*
pod/client created
*/

--Step 3.1 (Lab)
root@minikube-n1:~# kubectl get pods -n week4-session3 -o wide
/*
NAME                       READY   STATUS    RESTARTS   AGE   IP           NODE           NOMINATED NODE   READINESS GATES
backend-65959585f7-6cfnz   1/1     Running   0          11m   10.244.1.2   minikube-m02   <none>           <none>
backend-65959585f7-tdvv8   1/1     Running   0          11m   10.244.1.3   minikube-m02   <none>           <none>
backend-65959585f7-xgnct   1/1     Running   0          11m   10.244.0.3   minikube       <none>           <none>
client                     1/1     Running   0          12s   10.244.1.4   minikube-m02   <none>           <none>
*/

--Step 3.2 (Lab)
root@minikube-n1:~# kubectl get pods -n week4-session3
/*
NAME                       READY   STATUS    RESTARTS   AGE
backend-65959585f7-6cfnz   1/1     Running   0          11m
backend-65959585f7-tdvv8   1/1     Running   0          11m
backend-65959585f7-xgnct   1/1     Running   0          11m
client                     1/1     Running   0          38s
*/

--Step 3.3 (Lab)
root@minikube-n1:~# kubectl get pods -n week4-session3 -o wide
/*
NAME                       READY   STATUS    RESTARTS   AGE   IP           NODE           NOMINATED NODE   READINESS GATES
backend-65959585f7-6cfnz   1/1     Running   0          12m   10.244.1.2   minikube-m02   <none>           <none>
backend-65959585f7-tdvv8   1/1     Running   0          12m   10.244.1.3   minikube-m02   <none>           <none>
backend-65959585f7-xgnct   1/1     Running   0          12m   10.244.0.3   minikube       <none>           <none>
client                     1/1     Running   0          99s   10.244.1.4   minikube-m02   <none>           <none>
*/

--Step 4 (Lab)
--9. Task 4: Test direct Pod-to-Pod communication
--Pick one backend Pod IP from this command:
root@minikube-n1:~# kubectl get pods -n week4-session3 -o wide
/*
NAME                       READY   STATUS    RESTARTS   AGE     IP           NODE           NOMINATED NODE   READINESS GATES
backend-65959585f7-6cfnz   1/1     Running   0          14m     10.244.1.2   minikube-m02   <none>           <none>
backend-65959585f7-tdvv8   1/1     Running   0          14m     10.244.1.3   minikube-m02   <none>           <none>
backend-65959585f7-xgnct   1/1     Running   0          14m     10.244.0.3   minikube       <none>           <none>
client                     1/1     Running   0          3m24s   10.244.1.4   minikube-m02   <none>           <none>
*/

--Step 4.1 (Lab)
root@minikube-n1:~# kubectl exec -n week4-session3 client -- curl -s http://10.244.1.2
/*
Server address: 10.244.1.2:80
Server name: backend-65959585f7-6cfnz
Date: 04/Jun/2026:07:29:56 +0000
URI: /
Request ID: 6d9203a375adda3a6cb5e62c090cb7a8
*/

--Step 4.2 (Lab)
root@minikube-n1:~# kubectl exec -n week4-session3 client -- curl -s http://10.244.1.3
/*
Server address: 10.244.1.3:80
Server name: backend-65959585f7-tdvv8
Date: 04/Jun/2026:07:30:12 +0000
URI: /
Request ID: 76556810c7ec9ca36a72fb60accc65c7
*/

--Step 4.3 (Lab)
root@minikube-n1:~# kubectl exec -n week4-session3 client -- curl -s http://10.244.0.3
/*
Server address: 10.244.0.3:80
Server name: backend-65959585f7-xgnct
Date: 04/Jun/2026:07:30:21 +0000
URI: /
Request ID: aa5dac01e441b0b1b217338dc1d17159
*/

--Step 4.4 (Lab)
root@minikube-n1:~# kubectl exec -n week4-session3 client -- curl -s http://10.244.1.4
/*
command terminated with exit code 7
*/

--Kubernetes requires that every Pod can reach every other Pod using its IP address 
--directly — no proxies, no NAT. This is guaranteed by the CNI plugin (Flannel, Calico, Cilium, etc.).
--Answer this in your notes:
--Q1.Can one Pod communicate with another Pod using the Pod IP?
--Expected understanding:
--A1.Yes. Pods can communicate with each other inside the cluster using Pod IPs.
--Important lesson:
--Notes:Direct Pod IP communication works, but it is not safe for application configuration because 
--Pod IPs can change.

--Step 5 (Lab)
--10. Task 5: Delete one backend Pod and observe the new IP
--List the backend Pods:
root@minikube-n1:~# kubectl get pods -n week4-session3 -l app=backend -o wide
/*
NAME                       READY   STATUS    RESTARTS   AGE   IP           NODE           NOMINATED NODE   READINESS GATES
backend-65959585f7-6cfnz   1/1     Running   0          19m   10.244.1.2   minikube-m02   <none>           <none>
backend-65959585f7-tdvv8   1/1     Running   0          19m   10.244.1.3   minikube-m02   <none>           <none>
backend-65959585f7-xgnct   1/1     Running   0          19m   10.244.0.3   minikube       <none>           <none>
*/

--Step 5.1 (Lab)
--Store the name of one backend Pod:
root@minikube-n1:~# BACKEND_POD=$(kubectl get pod \
  -n week4-session3 \
  -l app=backend \
  -o jsonpath='{.items[0].metadata.name}')

--Step 5.2 (Lab)
root@minikube-n1:~# kubectl delete pod -n week4-session3 "$BACKEND_POD"
/*
pod "backend-65959585f7-6cfnz" deleted from week4-session3 namespace
*/

--Step 5.3 (Lab) -- Now compare the old Pod IP with the new Pod IP.
root@minikube-n1:~# kubectl get pods -n week4-session3 -l app=backend -o wide
/*
NAME                       READY   STATUS    RESTARTS   AGE   IP           NODE           NOMINATED NODE   READINESS GATES
backend-65959585f7-g8s8l   1/1     Running   0          11s   10.244.1.5   minikube-m02   <none>           <none>
backend-65959585f7-tdvv8   1/1     Running   0          21m   10.244.1.3   minikube-m02   <none>           <none>
backend-65959585f7-xgnct   1/1     Running   0          21m   10.244.0.3   minikube       <none>           <none>
*/

--Step 5.4 (Lab)
--Answer this in your notes:
--Q.Did the new backend Pod get the same IP or a different IP?
--A.Yes it Chnaged from 10.244.1.2 to 10.244.1.5
--Q.Why is depending on Pod IP risky?
--A.We have to Keep domain name every were.

--Step 6 (Lab)
--11. Task 6: Create a ClusterIP Service for the backend
root@minikube-n1:~# vi 02-backend-service.yaml
/*
apiVersion: v1
kind: Service
metadata:
  name: backend
  namespace: week4-session3
spec:
  type: ClusterIP
  selector:
    app: backend
    tier: api
  ports:
    - port: 80
      targetPort: 80
*/

--Step 6.1 (Lab)
root@minikube-n1:~# kubectl apply -f 02-backend-service.yaml --dry-run=client
/*
service/backend created (dry run)
*/

--Step 6.2 (Lab)
root@minikube-n1:~# kubectl apply -f 02-backend-service.yaml
/*
service/backend created
*/

--Step 6.3 (Lab)
root@minikube-n1:~# kubectl get svc -n week4-session3
/*
NAME      TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
backend   ClusterIP   10.101.190.92   <none>        80/TCP    27s
*/

--Step 6.4 (Lab)
root@minikube-n1:~# kubectl get svc -n week4-session3 -o wide
/*
NAME      TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE   SELECTOR
backend   ClusterIP   10.101.190.92   <none>        80/TCP    35s   app=backend,tier=api
*/

--Step 6.5 (Lab)
--Write down the Service IP:
--Backend Service ClusterIP: 10.101.190.92

--Step 6.6 (Lab)
--Prediction checkpoint
--Before deleting any backend Pod again, answer this:
--Q.If a backend Pod is deleted, will the Service IP change?
--Yes or No? Why?
--A. No. The Service IP will not change.

--Step 7 (Lab)
--12. Task 7: Check which Pods are behind the Service 
root@minikube-n1:~# kubectl get endpoints backend -n week4-session3 -o wide
/*
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME      ENDPOINTS                                   AGE
backend   10.244.0.3:80,10.244.1.3:80,10.244.1.5:80   6m37s
*/

--Step 7.1 (Lab)
root@minikube-n1:~# kubectl describe svc backend -n week4-session3
/*
Name:                     backend
Namespace:                week4-session3
Labels:                   <none>
Annotations:              <none>
Selector:                 app=backend,tier=api
Type:                     ClusterIP
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       10.101.190.92
IPs:                      10.101.190.92
Port:                     <unset>  80/TCP
TargetPort:               80/TCP
Endpoints:                10.244.1.5:80,10.244.0.3:80,10.244.1.3:80
Session Affinity:         None
Internal Traffic Policy:  Cluster
Events:                   <none>
*/

--Step 7.2 (Lab)
--Q. How does the Service know which Pods to send traffic to?
--A. A Kubernetes Service does not route traffic to Pods by their names or IP addresses. 
--   Instead, it uses a label selector (for example, app=backend, tier=api) to identify matching Pods.

--Step 8 (Lab)
--13. Task 8: Test communication using the ClusterIP Service
--Get the ClusterIP of the Service:
root@minikube-n1:~# kubectl get svc backend -n week4-session3
/*
NAME      TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
backend   ClusterIP   10.101.190.92   <none>        80/TCP    11m
*/

--Step 8.1 (Lab)
--You can also store the Service IP in a variable:
root@minikube-n1:~# BACKEND_SERVICE_IP=$(kubectl get svc backend \
  -n week4-session3 \
  -o jsonpath='{.spec.clusterIP}')

--Step 8.2 (Lab)
--From the client Pod, call the Service IP:
--TO get a response from the backend application.
root@minikube-n1:~# kubectl exec -n week4-session3 client -- curl -s http://$BACKEND_SERVICE_IP
/*
Server address: 10.244.0.3:80
Server name: backend-65959585f7-xgnct
Date: 04/Jun/2026:10:20:51 +0000
URI: /
Request ID: 1361f90f4c604300f79eb0e4c6ac244d
*/

--Step 8.2.1 (Lab)
--To get a response from the backend application.
root@minikube-n1:~# kubectl exec -n week4-session3 client -- curl -s http://$BACKEND_SERVICE_IP
/*
Server address: 10.244.1.5:80
Server name: backend-65959585f7-g8s8l
Date: 04/Jun/2026:10:20:54 +0000
URI: /
Request ID: ec925cb20eb08385593f92c08c8e2e8e
*/

--Step 8.3 (Lab)
--Now run it multiple times:
root@minikube-n1:~# kubectl exec -n week4-session3 client -- sh -c \
  "for i in 1 2 3 4 5; do curl -s http://$BACKEND_SERVICE_IP | head -n 1; echo '---'; done"
/*
Server address: 10.244.1.5:80
---
Server address: 10.244.0.3:80
---
Server address: 10.244.1.3:80
---
Server address: 10.244.1.3:80
---
Server address: 10.244.0.3:80
---
*/

--Step 8.3.1 (Lab)
root@minikube-n1:~# kubectl exec -n week4-session3 client -- sh -c \
  "for i in 1 2 3 4 5; do curl -s http://$BACKEND_SERVICE_IP | head -n 1; echo '---'; done"
/*
Server address: 10.244.0.3:80
---
Server address: 10.244.1.5:80
---
Server address: 10.244.1.5:80
---
Server address: 10.244.1.3:80
---
Server address: 10.244.1.5:80
---
*/

--Step 8.4 (Lab)
--Notice that different backend Pod names appear in the responses — the Service is load balancing 
--across all three Pods.
--Answer this in your notes:
--Q. Are we calling a Pod IP directly or a Service IP?
--A. Calling the service ip
--Q. Why is the Service IP better than a Pod IP?
--A. It does not changes

--Step 9 (Lab)
--14. Task 9: Prove that the Service survives Pod changes
--First, check the Service IP:
root@minikube-n1:~# kubectl get svc backend -n week4-session3
/*
NAME      TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
backend   ClusterIP   10.101.190.92   <none>        80/TCP    19m
*/

--Step 9.1 (Lab)
--Store the name of one backend Pod:
root@minikube-n1:~# BACKEND_POD=$(kubectl get pod \
  -n week4-session3 \
  -l app=backend \
  -o jsonpath='{.items[0].metadata.name}')

--Step 9.2 (Lab)
--Delete that backend Pod:
root@minikube-n1:~# kubectl delete pod -n week4-session3 "$BACKEND_POD"
/*
pod "backend-65959585f7-g8s8l" deleted from week4-session3 namespace
*/

--Step 9.3 (Lab)
--Wait for the new Pod:
root@minikube-n1:~# kubectl get pods -n week4-session3 -l app=backend -o wide
/*
NAME                       READY   STATUS    RESTARTS   AGE     IP           NODE           NOMINATED NODE   READINESS GATES
backend-65959585f7-tdvv8   1/1     Running   0          3h15m   10.244.1.3   minikube-m02   <none>           <none>
backend-65959585f7-v5j56   1/1     Running   0          19s     10.244.1.6   minikube-m02   <none>           <none>
backend-65959585f7-xgnct   1/1     Running   0          3h15m   10.244.0.3   minikube       <none>           <none>
*/

--Step 9.4 (Lab)
--Check the Service again:
root@minikube-n1:~# kubectl get svc backend -n week4-session3
/*
NAME      TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
backend   ClusterIP   10.101.190.92   <none>        80/TCP    22m
*/

--Step 9.5 (Lab)
--Check the endpoints again:
root@minikube-n1:~# kubectl get endpoints backend -n week4-session3
/*
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME      ENDPOINTS                                   AGE
backend   10.244.0.3:80,10.244.1.3:80,10.244.1.6:80   23m
*/

--Step 9.6 (Lab)
--Test the Service again from the client Pod:
root@minikube-n1:~# kubectl exec -n week4-session3 client -- curl -s http://$BACKEND_SERVICE_IP
/*
Server address: 10.244.1.6:80
Server name: backend-65959585f7-v5j56
Date: 04/Jun/2026:10:31:07 +0000
URI: /
Request ID: caaf15f1277ea22f00dedde4e206748e
*/

--Step 9.7 (Lab)
--Answer this in your notes:
--Q. Did the Service IP change?
--A. No. the service IP did not change.
--Q. Did the backend Pod IP change?
--A. Yes. the backend pod IP changed from 10.244.1.5 to 10.244.1.6
--Q. Did the Service continue working?
--A. Yes. the service continued working

--Step 10 (Lab)
--15. Task 10: Debug a broken Service selector
root@minikube-n1:~# vi 03-broken-service.yaml
/*
apiVersion: v1
kind: Service
metadata:
  name: broken-backend
  namespace: week4-session3
spec:
  type: ClusterIP
  selector:
    app: wrong-backend
    tier: api
  ports:
    - port: 80
      targetPort: 80
*/

--Step 10.1 (Lab)
root@minikube-n1:~# kubectl apply -f 03-broken-service.yaml --dry-run=client
/*
service/broken-backend configured (dry run)
*/

--Step 10.2 (Lab)
root@minikube-n1:~# kubectl apply -f 03-broken-service.yaml
/*
service/broken-backend configured
*/

--Step 10.3 (Lab)
root@minikube-n1:~# kubectl get svc broken-backend -n week4-session3
/*
NAME             TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
broken-backend   ClusterIP   10.105.191.44   <none>        80/TCP    9m47s
*/

--Step 10.4 (Lab)
root@minikube-n1:~# kubectl get svc broken-backend -n week4-session3 -o wide
/*
NAME             TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE     SELECTOR
broken-backend   ClusterIP   10.105.191.44   <none>        80/TCP    9m53s   app=wrong-backend,tier=api
*/

--Step 10.5 (Lab)
root@minikube-n1:~# kubectl get endpoints broken-backend -n week4-session3
/*
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME             ENDPOINTS   AGE
broken-backend   <none>      9m59s
*/

--Step 10.6 (Lab)
--Answer this in your notes:
--Q. Why does broken-backend have no endpoints?
--A. The selector:app does not exists as app=wrong-backend

--Step 10.7 (Lab)
--Now fix the selector in 03-broken-service.yaml
root@minikube-n1:~# vi 03-broken-service.yaml
/*
apiVersion: v1
kind: Service
metadata:
  name: broken-backend
  namespace: week4-session3
spec:
  type: ClusterIP
  selector:
    app: backend
    tier: api
  ports:
    - port: 80
      targetPort: 80
*/

--Step 10.8 (Lab)
root@minikube-n1:~# kubectl apply -f 03-broken-service.yaml --dry-run=client
/*
service/broken-backend created (dry run)
*/

--Step 10.9 (Lab)
root@minikube-n1:~# kubectl apply -f 03-broken-service.yaml
/*
service/broken-backend created
*/

--Step 10.10 (Lab)
root@minikube-n1:~# kubectl get svc broken-backend -n week4-session3
/*
NAME             TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
broken-backend   ClusterIP   10.105.191.44   <none>        80/TCP    40s
*/

--Step 10.11 (Lab)
root@minikube-n1:~# kubectl get svc broken-backend -n week4-session3 -o wide
/*
NAME             TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE   SELECTOR
broken-backend   ClusterIP   10.105.191.44   <none>        80/TCP    34s   app=backend,tier=api
*/

--Step 10.12 (Lab)
root@minikube-n1:~# kubectl get endpoints broken-backend -n week4-session3
/*
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME             ENDPOINTS                                   AGE
broken-backend   10.244.0.3:80,10.244.1.3:80,10.244.1.6:80   14m
*/

--Step 11 (Lab)
--16. Task 11: Add a worker Deployment with basic Pod affinity
root@minikube-n1:~# vi 04-worker-affinity.yaml
/*
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-worker
  namespace: week4-session3
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backend-worker
  template:
    metadata:
      labels:
        app: backend-worker
    spec:
      affinity:
        podAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                matchExpressions:
                  - key: app
                    operator: In
                    values:
                      - backend
              topologyKey: kubernetes.io/hostname
      containers:
        - name: worker
          image: busybox:1.36
          command: ["sh", "-c", "while true; do echo worker running near backend; sleep 30; done"]
*/

--Step 11.1 (Lab)
root@minikube-n1:~# kubectl apply -f 04-worker-affinity.yaml --dry-run=client
/*
deployment.apps/backend-worker created (dry run)
*/

--Step 11.2 (Lab)
root@minikube-n1:~# kubectl apply -f 04-worker-affinity.yaml
/*
deployment.apps/backend-worker created
*/

--Step 11.3 (Lab)
root@minikube-n1:~# kubectl get pods -n week4-session3 -o wide
/*
NAME                              READY   STATUS              RESTARTS      AGE     IP           NODE           NOMINATED NODE   READINESS GATES
backend-65959585f7-tdvv8          1/1     Running             0             3h39m   10.244.1.3   minikube-m02   <none>           <none>
backend-65959585f7-v5j56          1/1     Running             0             24m     10.244.1.6   minikube-m02   <none>           <none>
backend-65959585f7-xgnct          1/1     Running             0             3h39m   10.244.0.3   minikube       <none>           <none>
backend-worker-6f56468684-jv8tj   0/1     ContainerCreating   0             8s      <none>       minikube-m02   <none>           <none>
client                            1/1     Running             3 (27m ago)   3h27m   10.244.1.4   minikube-m02   <none>           <none>
*/

--Step 11.4 (Lab)
root@minikube-n1:~# kubectl get pods -n week4-session3 -o wide
/*
NAME                              READY   STATUS    RESTARTS      AGE     IP           NODE           NOMINATED NODE   READINESS GATES
backend-65959585f7-tdvv8          1/1     Running   0             3h39m   10.244.1.3   minikube-m02   <none>           <none>
backend-65959585f7-v5j56          1/1     Running   0             24m     10.244.1.6   minikube-m02   <none>           <none>
backend-65959585f7-xgnct          1/1     Running   0             3h39m   10.244.0.3   minikube       <none>           <none>
backend-worker-6f56468684-jv8tj   1/1     Running   0             13s     10.244.1.7   minikube-m02   <none>           <none>
*/

--Step 11.5 (Lab)
--Answer this in your notes:
--Q. Which node is the backend-worker Pod running on?
--A. Node minikube-m02 IP 10.244.1.7
--Q. Is it on the same node as at least one backend Pod?
--A. Yes

--Step 12 (Lab)
--17. Task 12: Understand the Pod affinity rule
--Look at this part of the worker YAML:
/*
podAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
    - labelSelector:
        matchExpressions:
          - key: app
            operator: In
            values:
              - backend
      topologyKey: kubernetes.io/hostname
*/

--Step 12.1 (Lab)
--Q. What topologyKey means
  -- topologyKey: kubernetes.io/hostname
/*
  This label exists on every node and its value is the node's hostname.

  Node A                         Node B
  ┌──────────────────────┐       ┌──────────────────────┐
  │ kubernetes.io/       │       │ kubernetes.io/        │
  │ hostname=node-a      │       │ hostname=node-b       │
  └──────────────────────┘       └──────────────────────┘

  topologyKey: kubernetes.io/hostname means:
  "same node" — the worker must land on a node
  where the label value (hostname) is the same
  as a node running a matching backend Pod.

  Other topology keys you may encounter:
  topology.kubernetes.io/zone     → same availability zone
  topology.kubernetes.io/region   → same region
*/

--Step 12.2 (Lab)
--Answer these questions:
--Q. What label is the worker Pod looking for?
--A. It is looking for Pods with the label app=backend
--Q. What does topologyKey: kubernetes.io/hostname mean?
--A. It means "the exact same node." The worker Pod must be scheduled onto 
--   a node that has the same hostname as a node already running a matching backend Pod.
--Q. What happens if there is no Pod with app=backend in the cluster?
--A. The worker Pod will get stuck in a Pending state because the affinity rule is a 
--   hard requirement (requiredDuringScheduling), and the scheduler cannot find a node 
--   that satisfies it.

--Step 13 (Lab)
--18. Task 13: Test what happens when backend Pods are removed
--Scale the backend Deployment to zero:
root@minikube-n1:~# kubectl scale deployment backend -n week4-session3 --replicas=0
/*
deployment.apps/backend scaled
*/

--Step 13.1 (Lab)
--Wait until all backend Pods are fully gone before continuing:
--Important: wait until this command returns no Pods. If you delete the worker Pod while backend 
--Pods are still in Terminating state, the scheduler may still see them and schedule the worker 
--successfully. You need the list to be completely empty.
root@minikube-n1:~# kubectl get pods -n week4-session3 -l app=backend
/*
No resources found in week4-session3 namespace.
*/

--Step 13.2 (Lab)
--Now delete the worker Pod so Kubernetes tries to recreate it:
root@minikube-n1:~# kubectl delete pod -n week4-session3 -l app=backend-worker
/*
pod "backend-worker-6f56468684-jv8tj" deleted from week4-session3 namespace
*/

--Step 13.3 (Lab) 
--Check the worker Pod:
root@minikube-n1:~# kubectl get pods -n week4-session3 -o wide
/*
NAME                              READY   STATUS    RESTARTS      AGE     IP           NODE           NOMINATED NODE   READINESS GATES
backend-worker-6f56468684-z8qs8   0/1     Pending   0             68s     <none>       <none>         <none>           <none>
client                            1/1     Running   3 (46m ago)   3h46m   10.244.1.4   minikube-m02   <none>           <none>
*/

--Step 13.4 (Lab) 
--Describe the worker Pod:
root@minikube-n1:~# kubectl get pods -n week4-session3 -o wide -o wide
/*
NAME                              READY   STATUS    RESTARTS      AGE     IP           NODE           NOMINATED NODE   READINESS GATES
backend-worker-6f56468684-z8qs8   0/1     Pending   0             3m3s    <none>       <none>         <none>           <none>
client                            1/1     Running   3 (48m ago)   3h48m   10.244.1.4   minikube-m02   <none>           <none>
root@minikube-n1:~# kubectl describe pod -n week4-session3 -l app=backend-worker
Name:             backend-worker-6f56468684-z8qs8
Namespace:        week4-session3
Priority:         0
Service Account:  default
Node:             <none>
Labels:           app=backend-worker
                  pod-template-hash=6f56468684
Annotations:      <none>
Status:           Pending
IP:
IPs:              <none>
Controlled By:    ReplicaSet/backend-worker-6f56468684
Containers:
  worker:
    Image:      busybox:1.36
    Port:       <none>
    Host Port:  <none>
    Command:
      sh
      -c
      while true; do echo worker running near backend; sleep 30; done
    Environment:  <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-jcvr8 (ro)
Conditions:
  Type           Status
  PodScheduled   False
Volumes:
  kube-api-access-jcvr8:
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
  Type     Reason            Age    From               Message
  ----     ------            ----   ----               -------
  Warning  FailedScheduling  3m42s  default-scheduler  0/2 nodes are available: 2 node(s) didn't match pod affinity rules. no new claims to deallocate, preemption: 0/2 nodes are available: 2 Preemption is not helpful for scheduling.
*/

--Step 13.5 (Lab) 
--Q. What happened to the worker Pod after backend Pods were removed?
--A. The worker Pod transitioned into a Pending state and could not be scheduled onto any node.

--Q. Why?
--A. Because the worker Pod configuration uses a strict scheduling constraint 
--   (requiredDuringScheduling). It tells the Kubernetes scheduler that it is mandatory 
--    to find a node already running a Pod with the label app=backend.

--Step 13.6 (Lab) 
--Now restore the backend Deployment:
root@minikube-n1:~# kubectl scale deployment backend -n week4-session3 --replicas=3
/*
deployment.apps/backend scaled
*/

--Step 13.7 (Lab) 
root@minikube-n1:~# kubectl get pods -n week4-session3 -o wide
/*
NAME                              READY   STATUS    RESTARTS      AGE     IP            NODE           NOMINATED NODE   READINESS GATES
backend-65959585f7-h9jb7          1/1     Running   0             8s      10.244.1.10   minikube-m02   <none>           <none>
backend-65959585f7-jgqbm          1/1     Running   0             8s      10.244.1.9    minikube-m02   <none>           <none>
backend-65959585f7-ldl54          1/1     Running   0             8s      10.244.1.8    minikube-m02   <none>           <none>
backend-worker-6f56468684-z8qs8   1/1     Running   0             7m23s   10.244.1.11   minikube-m02   <none>           <none>
client                            1/1     Running   3 (52m ago)   3h53m   10.244.1.4    minikube-m02   <none>           <none>
*/

--Step 14 (Lab)
--19. Optional challenge: Change labels and fix the Service
--This challenge is optional, but recommended.
--Change the backend Pod label from: app=backend to app=api-backend
root@minikube-n1:~# vi 01-backend-deployment.yaml
/*
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: week4-session3
spec:
  replicas: 3
  selector:
    matchLabels:
      app: api-backend
      tier: api
  template:
    metadata:
      labels:
        app: api-backend
        tier: api
    spec:
      containers:
        - name: backend
          image: nginxdemos/hello:plain-text
          ports:
            - containerPort: 80
*/

--Step 14.1 (Lab)
root@minikube-n1:~# kubectl apply -f 01-backend-deployment.yaml --dry-run=client
/*
deployment.apps/backend configured (dry run)
*/

--Step 14.2 (Lab)
root@minikube-n1:~# kubectl apply -f 01-backend-deployment.yaml
/*
The Deployment "backend" is invalid: spec.selector: Invalid value: {"matchLabels":{"app":"api-backend","tier":"api"}}: field is immutable
*/

--Step 14.2.1 (Lab)
root@minikube-n1:~# kubectl delete deployment backend -n week4-session3
/*
deployment.apps "backend" deleted from week4-session3 namespace
*/

--Step 14.3 (Lab)
root@minikube-n1:~# kubectl apply -f 01-backend-deployment.yaml
/*
deployment.apps/backend created
*/

--Step 14.4 (Lab)
root@minikube-n1:~# kubectl get pods -n week4-session3 --show-labels
/*
NAME                              READY   STATUS    RESTARTS      AGE     LABELS
backend-66fd998c4-5npt8           1/1     Running   0             26s     app=api-backend,pod-template-hash=66fd998c4,tier=api
backend-66fd998c4-cp9z9           1/1     Running   0             26s     app=api-backend,pod-template-hash=66fd998c4,tier=api
backend-66fd998c4-dww9c           1/1     Running   0             26s     app=api-backend,pod-template-hash=66fd998c4,tier=api
backend-worker-6f56468684-z8qs8   1/1     Running   0             13m     app=backend-worker,pod-template-hash=6f56468684
client                            1/1     Running   3 (58m ago)   3h58m   run=client
*/

--Step 14.5 (Lab-Issue)
root@minikube-n1:~# kubectl get endpoints backend -n week4-session3
/*
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME      ENDPOINTS   AGE
backend   <none>      79m
*/

--Step 14.6 (Lab-Fixing)
root@minikube-n1:~# vi 02-backend-service.yaml
/*
apiVersion: v1
kind: Service
metadata:
  name: backend
  namespace: week4-session3
spec:
  type: ClusterIP
  selector:
    app: api-backend
    tier: api
  ports:
    - port: 80
      targetPort: 80
*/

--Step 14.7 (Lab-Fixing)
root@minikube-n1:~# kubectl apply -f 02-backend-service.yaml --dry-run=client
/*
service/backend configured (dry run)
*/

--Step 14.8 (Lab-Fixing)
root@minikube-n1:~# kubectl apply -f 02-backend-service.yaml
/*
service/backend configured
*/

--Step 14.9 (Lab-Fixing)
root@minikube-n1:~# kubectl get pods -n week4-session3 --show-labels
/*
NAME                              READY   STATUS    RESTARTS       AGE     LABELS
backend-66fd998c4-5npt8           1/1     Running   0              5m46s   app=api-backend,pod-template-hash=66fd998c4,tier=api
backend-66fd998c4-cp9z9           1/1     Running   0              5m46s   app=api-backend,pod-template-hash=66fd998c4,tier=api
backend-66fd998c4-dww9c           1/1     Running   0              5m46s   app=api-backend,pod-template-hash=66fd998c4,tier=api
backend-worker-6f56468684-z8qs8   1/1     Running   0              18m     app=backend-worker,pod-template-hash=6f56468684
client                            1/1     Running   4 (4m6s ago)   4h4m    run=client
*/

--Step 14.10 (Lab-Fixed)
root@minikube-n1:~# kubectl get endpoints backend -n week4-session3
/*
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME      ENDPOINTS                                     AGE
backend   10.244.0.4:80,10.244.1.12:80,10.244.1.13:80   82m
*/

--Step 15 (Lab)
--20. Common mistakes to debug
root@minikube-n1:~# kubectl get pods -n week4-session3 --show-labels
/*
NAME                              READY   STATUS    RESTARTS        AGE     LABELS
backend-66fd998c4-5npt8           1/1     Running   0               9m25s   app=api-backend,pod-template-hash=66fd998c4,tier=api
backend-66fd998c4-cp9z9           1/1     Running   0               9m25s   app=api-backend,pod-template-hash=66fd998c4,tier=api
backend-66fd998c4-dww9c           1/1     Running   0               9m25s   app=api-backend,pod-template-hash=66fd998c4,tier=api
backend-worker-6f56468684-z8qs8   1/1     Running   0               22m     app=backend-worker,pod-template-hash=6f56468684
client                            1/1     Running   4 (7m45s ago)   4h7m    run=client
*/

--Step 15.1 (Lab)
root@minikube-n1:~# kubectl describe svc backend -n week4-session3
/*
Name:                     backend
Namespace:                week4-session3
Labels:                   <none>
Annotations:              <none>
Selector:                 app=api-backend,tier=api
Type:                     ClusterIP
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       10.101.190.92
IPs:                      10.101.190.92
Port:                     <unset>  80/TCP
TargetPort:               80/TCP
Endpoints:                10.244.1.12:80,10.244.0.4:80,10.244.1.13:80
Session Affinity:         None
Internal Traffic Policy:  Cluster
Events:                   <none>
*/

--Step 15.2 (Lab)
root@minikube-n1:~# kubectl get endpoints backend -n week4-session3
/*
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME      ENDPOINTS                                     AGE
backend   10.244.0.4:80,10.244.1.12:80,10.244.1.13:80   86m
*/

--Step 15.3 (Lab)
root@minikube-n1:~# kubectl get endpoints backend -n week4-session3
/*
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME      ENDPOINTS                                     AGE
backend   10.244.0.4:80,10.244.1.12:80,10.244.1.13:80   86m
*/

--Step 15.4 (Lab)
root@minikube-n1:~# kubectl get pod client -n week4-session3
/*
NAME     READY   STATUS    RESTARTS        AGE
client   1/1     Running   4 (9m28s ago)   4h9m
*/

--Step 15.5 (Lab)
root@minikube-n1:~# kubectl get pods -n week4-session3 -o wide
/*
NAME                              READY   STATUS    RESTARTS        AGE    IP            NODE           NOMINATED NODE   READINESS GATES
backend-66fd998c4-5npt8           1/1     Running   0               11m    10.244.0.4    minikube       <none>           <none>
backend-66fd998c4-cp9z9           1/1     Running   0               11m    10.244.1.13   minikube-m02   <none>           <none>
backend-66fd998c4-dww9c           1/1     Running   0               11m    10.244.1.12   minikube-m02   <none>           <none>
backend-worker-6f56468684-z8qs8   1/1     Running   0               24m    10.244.1.11   minikube-m02   <none>           <none>
client                            1/1     Running   4 (9m34s ago)   4h9m   10.244.1.4    minikube-m02   <none>           <none>
*/

--Step 15.6 (Lab)
root@minikube-n1:~# kubectl get svc backend -n week4-session3
/*
NAME      TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
backend   ClusterIP   10.101.190.92   <none>        80/TCP    88m
*/

--Step 15.7 (Lab)
root@minikube-n1:~# kubectl describe pod -n week4-session3 -l app=backend-worker
/*
Name:             backend-worker-6f56468684-z8qs8
Namespace:        week4-session3
Priority:         0
Service Account:  default
Node:             minikube-m02/192.168.49.3
Start Time:       Thu, 04 Jun 2026 17:03:51 +0545
Labels:           app=backend-worker
                  pod-template-hash=6f56468684
Annotations:      <none>
Status:           Running
IP:               10.244.1.11
IPs:
  IP:           10.244.1.11
Controlled By:  ReplicaSet/backend-worker-6f56468684
Containers:
  worker:
    Container ID:  docker://72482641e947db1738e931c92370f577b958a82aa2cb947f4f5ba3d8cf6661f9
    Image:         busybox:1.36
    Image ID:      docker-pullable://busybox@sha256:73aaf090f3d85aa34ee199857f03fa3a95c8ede2ffd4cc2cdb5b94e566b11662
    Port:          <none>
    Host Port:     <none>
    Command:
      sh
      -c
      while true; do echo worker running near backend; sleep 30; done
    State:          Running
      Started:      Thu, 04 Jun 2026 17:03:54 +0545
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-jcvr8 (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True
  Initialized                 True
  Ready                       True
  ContainersReady             True
  PodScheduled                True
Volumes:
  kube-api-access-jcvr8:
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
  Type     Reason            Age                From               Message
  ----     ------            ----               ----               -------
  Warning  FailedScheduling  20m (x2 over 25m)  default-scheduler  0/2 nodes are available: 2 node(s) didn't match pod affinity rules. no new claims to deallocate, preemption: 0/2 nodes are available: 2 Preemption is not helpful for scheduling.
  Normal   Scheduled         18m                default-scheduler  Successfully assigned week4-session3/backend-worker-6f56468684-z8qs8 to minikube-m02
  Normal   Pulled            18m                kubelet            spec.containers{worker}: Container image "busybox:1.36" already present on machine and can be accessed by the pod
  Normal   Created           18m                kubelet            spec.containers{worker}: Container created
  Normal   Started           18m                kubelet            spec.containers{worker}: Container started
*/

--Step 15.8 (Lab)
root@minikube-n1:~# kubectl get pods -n week4-session3 --show-labels
/*
NAME                              READY   STATUS    RESTARTS      AGE     LABELS
backend-66fd998c4-5npt8           1/1     Running   0             13m     app=api-backend,pod-template-hash=66fd998c4,tier=api
backend-66fd998c4-cp9z9           1/1     Running   0             13m     app=api-backend,pod-template-hash=66fd998c4,tier=api
backend-66fd998c4-dww9c           1/1     Running   0             13m     app=api-backend,pod-template-hash=66fd998c4,tier=api
backend-worker-6f56468684-z8qs8   1/1     Running   0             26m     app=backend-worker,pod-template-hash=6f56468684
client                            1/1     Running   4 (11m ago)   4h11m   run=client
*/

--Step 16 (Lab)
--21. Final validation checklist
root@minikube-n1:~# kubectl get all -n week4-session3
/*
NAME                                  READY   STATUS    RESTARTS      AGE
pod/backend-66fd998c4-5npt8           1/1     Running   0             14m
pod/backend-66fd998c4-cp9z9           1/1     Running   0             14m
pod/backend-66fd998c4-dww9c           1/1     Running   0             14m
pod/backend-worker-6f56468684-z8qs8   1/1     Running   0             27m
pod/client                            1/1     Running   4 (12m ago)   4h12m

NAME                     TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
service/backend          ClusterIP   10.101.190.92   <none>        80/TCP    91m
service/broken-backend   ClusterIP   10.105.191.44   <none>        80/TCP    62m

NAME                             READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/backend          3/3     3            3           14m
deployment.apps/backend-worker   1/1     1            1           45m

NAME                                        DESIRED   CURRENT   READY   AGE
replicaset.apps/backend-66fd998c4           3         3         3       14m
replicaset.apps/backend-worker-6f56468684   1         1         1       45m
*/

--Step 16.1 (Lab)
root@minikube-n1:~# kubectl get pods -n week4-session3 -o wide
/*
NAME                              READY   STATUS    RESTARTS      AGE     IP            NODE           NOMINATED NODE   READINESS GATES
backend-66fd998c4-5npt8           1/1     Running   0             14m     10.244.0.4    minikube       <none>           <none>
backend-66fd998c4-cp9z9           1/1     Running   0             14m     10.244.1.13   minikube-m02   <none>           <none>
backend-66fd998c4-dww9c           1/1     Running   0             14m     10.244.1.12   minikube-m02   <none>           <none>
backend-worker-6f56468684-z8qs8   1/1     Running   0             27m     10.244.1.11   minikube-m02   <none>           <none>
client                            1/1     Running   4 (12m ago)   4h12m   10.244.1.4    minikube-m02   <none>           <none>
*/

--Step 16.2 (Lab)
root@minikube-n1:~# kubectl get svc -n week4-session3
/*
NAME             TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
backend          ClusterIP   10.101.190.92   <none>        80/TCP    91m
broken-backend   ClusterIP   10.105.191.44   <none>        80/TCP    62m
*/

--Step 16.3 (Lab)
root@minikube-n1:~# kubectl get endpoints backend -n week4-session3
/*
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME      ENDPOINTS                                     AGE
backend   10.244.0.4:80,10.244.1.12:80,10.244.1.13:80   91m
*/

--Step 16.4 (Lab)
root@minikube-n1:~# kubectl exec -n week4-session3 client -- curl -s http://$BACKEND_SERVICE_IP
/*
Server address: 10.244.1.12:80
Server name: backend-66fd998c4-dww9c
Date: 04/Jun/2026:11:39:12 +0000
URI: /
Request ID: 52e732581d84f5c8488592e938c209bc
*/