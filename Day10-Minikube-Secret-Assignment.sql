--B1. Create a ConfigMap (imperative)
--Create a ConfigMap named app-config with two literals and one file.
--# literals
--Step 1 (Lab)
root@docker-minikube-n02:~# kubectl create configmap app-config --from-literal=APP_COLOR=blue --from-literal=APP_MODE=prod --dry-run=client
/*
configmap/app-config created (dry run)
*/

--Step 1.1 (Lab)
root@docker-minikube-n02:~# kubectl create configmap app-config --from-literal=APP_COLOR=blue --from-literal=APP_MODE=prod
/*
configmap/app-config created
*/
 
--# inspect it
--Step 1.2 (Lab)
root@docker-minikube-n02:~# kubectl get configmap app-config
/*
NAME         DATA   AGE
app-config   2      5m46s
*/

--Step 1.3 (Lab)
root@docker-minikube-n02:~# kubectl get configmap app-config -o yaml
/*
apiVersion: v1
data:
  APP_COLOR: blue
  APP_MODE: prod
kind: ConfigMap
metadata:
  creationTimestamp: "2026-05-31T08:45:07Z"
  name: app-config
  namespace: default
  resourceVersion: "18410"
  uid: be74b7e2-29c5-48cd-beab-19a8f00f6125
*/

--B2. Create a Secret (imperative)
--Create a generic Secret named db-secret holding a username and password.
--Step 2 (Lab)
root@docker-minikube-n02:~# kubectl create secret generic db-secret --from-literal=DB_USER=admin --from-literal DB_Pass="admin@pass123" --dry-run=client
/*
secret/db-secret created (dry run)
*/

--Step 2.1 (Lab)
root@docker-minikube-n02:~# kubectl create secret generic db-secret --from-literal=DB_USER=admin --from-literal DB_Pass="admin@pass123"
/*
secret/db-secret created
*/

--Step 2.2 (Lab)
root@docker-minikube-n02:~# kubectl get secret db-secret
/*
NAME        TYPE     DATA   AGE
db-secret   Opaque   2      3m54s
*/

--Step 2.3 (Lab)
root@docker-minikube-n02:~# kubectl get secret db-secret -o yaml
/*
apiVersion: v1
data:
  DB_Pass: YWRtaW5AcGFzczEyMw==
  DB_USER: YWRtaW4=
kind: Secret
metadata:
  creationTimestamp: "2026-05-31T08:46:24Z"
  name: db-secret
  namespace: default
  resourceVersion: "18478"
  uid: 6dfb43cb-c356-4182-a8f9-64ef0ca9e2e5
type: Opaque
*/

--Investigate
--The value under data: looks scrambled. Decode it and confirm it is just encoding, not encryption:
--Step 2.3 (Lab)
root@docker-minikube-n02:~# kubectl get secret db-secret -o jsonpath='{.data.DN_Pass}' | base64 --decode


--B3. Consume config as environment variables
--Apply the Pod below. It pulls one value with valueFrom and a whole Secret with envFrom.
--Step 3 (Lab)
root@docker-minikube-n02:~# vi env-demo.yaml
/*
apiVersion: v1
kind: Pod
metadata:
  name: env-demo
spec:
  containers:
    - name: app
      image: busybox:1.36xyz
      command: ['sh', '-c', 'sleep 3600']
      env:
        - name: COLOR
          valueFrom:
            configMapKeyRef:
              name: ap-confg
              key: APP_COLOR
      envFrom:
        - secretRef:
            name: db-secret
*/

--Step 3.1 (Lab)
root@docker-minikube-n02:~# kubectl apply -f env-demo.yaml --dry-run=client
/*
pod/env-demo created (dry run)
*/

--Step 3.2 (Lab)
root@docker-minikube-n02:~# kubectl apply -f env-demo.yaml
/*
pod/env-demo created
*/

--Step 3.3 (Lab -Issue Occured)
root@docker-minikube-n02:~# kubectl get pods env-demo
/*
NAME       READY   STATUS             RESTARTS   AGE
env-demo   0/1     ImagePullBackOff   0          6m30s
*/

--Step 3.4 (Lab -Issue Occured)
root@docker-minikube-n02:~# kubectl get pods env-demo
/*
NAME       READY   STATUS             RESTARTS   AGE
env-demo   0/1     ImagePullBackOff   0          6m33s
*/

--Step 3.5 (Lab -Issue Occured)
root@docker-minikube-n02:~# kubectl delete pod env-demo
/*
pod "env-demo" deleted from default namespace
*/

--Step 3.6 (Lab -Issue Fixed)
root@docker-minikube-n02:~# vi env-demo.yaml
/*
apiVersion: v1
kind: Pod
metadata:
  name: env-demo
spec:
  containers:
    - name: app
      image: busybox:1.36
      command: ['sh', '-c', 'sleep 3600']

      env:
        - name: COLOR
          valueFrom:
            configMapKeyRef:
              name: ap-config
              key: APP_COLOR

      envFrom:
        - secretRef:
            name: db-secret
*/

--Step 3.7 (Lab)
root@docker-minikube-n02:~# kubectl apply -f env-demo.yaml
/*
pod/env-demo created
*/

--Step 3.8 (Lab)
root@docker-minikube-n02:~# kubectl get pods env-demo
/*
NAME       READY   STATUS    RESTARTS   AGE
env-demo   1/1     Running   0          11s
*/


--B4. Consume config as a mounted volume
--Mount the ConfigMap as files and observe how each key becomes a file whose contents are the value.
--Step 4 (Lab)
root@docker-minikube-n02:~# vi vol-demo.yaml
/*
apiVersion: v1
kind: Pod
metadata:
  name: vol-demo
  labels:
   app: orders-api
spec:
  containers:
    - name: app
      image: busybox:1.36
      command: ['sh', '-c', 'sleep 3600']
      volumeMounts:
        - name: config
          mountPath: /etc/appconfig
          readOnly: true
  volumes:
    - name: config
      configMap:
        name: app-config
*/

--Step 4.1 (Lab)
root@docker-minikube-n02:~# kubectl apply -f vol-demo.yaml --dry-run=client
/*
pod/vol-demo created (dry run)
*/

--Step 4.2 (Lab)
root@docker-minikube-n02:~# kubectl apply -f vol-demo.yaml
/*
pod/vol-demo created
*/

--Step 4.3 (Lab)
root@docker-minikube-n02:~# kubectl get pods vol-demo
/*
NAME       READY   STATUS    RESTARTS   AGE
vol-demo   1/1     Running   0          10s
*/

--Step 4.4 (Lab)
root@docker-minikube-n02:~# kubectl describe pod vol-demo
/*
Name:             vol-demo
Namespace:        default
Priority:         0
Service Account:  default
Node:             minikube-m02/192.168.49.3
Start Time:       Sun, 31 May 2026 15:29:22 +0545
Labels:           app=orders-api
Annotations:      <none>
Status:           Running
IP:               10.244.1.17
IPs:
  IP:  10.244.1.17
Containers:
  app:
    Container ID:  docker://22dbfdbbed5fe15f656cbf200d7b9371d308b082d766b0bad5baa8f12aa6df35
    Image:         busybox:1.36
    Image ID:      docker-pullable://busybox@sha256:73aaf090f3d85aa34ee199857f03fa3a95c8ede2ffd4cc2cdb5b94e566b11662
    Port:          <none>
    Host Port:     <none>
    Command:
      sh
      -c
      sleep 3600
    State:          Running
      Started:      Sun, 31 May 2026 15:29:24 +0545
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /etc/appconfig from config (ro)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-5nggq (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True
  Initialized                 True
  Ready                       True
  ContainersReady             True
  PodScheduled                True
Volumes:
  config:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      app-config
    Optional:  false
  kube-api-access-5nggq:
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
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  110s  default-scheduler  Successfully assigned default/vol-demo to minikube-m02
  Normal  Pulled     109s  kubelet            spec.containers{app}: Container image "busybox:1.36" already present on machine and can be accessed by the pod
  Normal  Created    109s  kubelet            spec.containers{app}: Container created
  Normal  Started    108s  kubelet            spec.containers{app}: Container started
*/


--Step 4.5 (Lab)
root@docker-minikube-n02:~# kubectl exec vol-demo -- ls /etc/appconfig
/*
APP_COLOR
APP_MODE
*/

--Step 4.5 (Lab)
root@docker-minikube-n02:~# kubectl exec vol-demo -- cat /etc/appconfig/APP_COLOR
/*
blue
*/



--Part C — Observe & Explain
--Run the experiment, then write down what you observe.
--C1. Does a live update reach the Pod?
--Update the ConfigMap value, then check both the environment-variable Pod and the volume-mounted Pod.
--Step 5 (Lab)
root@docker-minikube-n02:~# kubectl edit configmap app-config
/*
# Please edit the object below. Lines beginning with a '#' will be ignored,
# and an empty file will abort the edit. If an error occurs while saving this file will be
# reopened with the relevant failures.
#
apiVersion: v1
data:
  APP_COLOR: green
  APP_MODE: prod
kind: ConfigMap
metadata:
  creationTimestamp: "2026-05-31T08:45:07Z"
  name: app-config
  namespace: default
  resourceVersion: "22085"
  uid: be74b7e2-29c5-48cd-beab-19a8f00f6125
*/
/*
configmap/app-config edited
*/

--# change APP_COLOR from blue to green, save, exit
--# wait up to ~60s, then check both pods:
--Step 5.1 (Lab)
root@docker-minikube-n02:~# kubectl exec env-demo -- env | grep COLOR
/*
COLOR=blue
*/

--Step 5.2 (Lab)
root@docker-minikube-n02:~# kubectl exec vol-demo -- cat /etc/appconfig/APP_COLOR
/*
green
*/



--Write-up
--Which Pod (if either) reflected the new value? Which did not?
--Based on this, explain the difference between how env-var and volume consumption handle updates.
--Step 5.3 (Lab)
root@docker-minikube-n02:~# kubectl get configmap app-config -o jsonpath='{.data.APP_COLOR}'
/*
green
*/

--Part D — Real-World Scenario
--Bring it all together. Deliver working manifests.
--Step 6 (Lab)
root@docker-minikube-n02:~# kubectl create deployment olders-api --image nginx:alpine --port 80 --replicas=2 -o yaml --dry-run=client
/*
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: olders-api
  name: olders-api
spec:
  replicas: 2
  selector:
    matchLabels:
      app: olders-api
  strategy: {}
  template:
    metadata:
      labels:
        app: olders-api
    spec:
      containers:
      - image: nginx:alpine
        name: nginx
        ports:
        - containerPort: 80
        resources: {}
status: {}
*/

--Step 6.1 (Lab)
root@docker-minikube-n02:~# kubectl create deployment olders-api --image nginx:alpine --port 80 --replicas=2 -o yaml --dry-run=client > olders-api.yaml

--Step 6.2 (Lab)
root@docker-minikube-n02:~# ll olders-api.yaml
/*
-rw-r--r-- 1 root root 398 May 31 15:40 olders-api.yaml
*/

--Step 6.3 (Lab)
root@docker-minikube-n02:~# kubectl apply -f olders-api.yaml
/*
deployment.apps/olders-api created
*/

--Step 6.4 (Lab)
root@docker-minikube-n02:~# kubectl get deployment
/*
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
olders-api   2/2     2            2           19s
*/

--Step 7 (Lab)
root@docker-minikube-n02:~# kubectl create configmap olders-config -n busyns --from-literal LOG_LEVEL=info --from-literal FEATURE_FLAGS=error -o yaml --dry-run=client
/*
apiVersion: v1
data:
  FEATURE_FLAGS: error
  LOG_LEVEL: info
kind: ConfigMap
metadata:
  name: olders-config
  namespace: busyns
*/

--Step 7.1 (Lab)
root@docker-minikube-n02:~# kubectl create configmap olders-config -n busyns --from-literal LOG_LEVEL=info --from-literal FEATURE_FLAGS=error -o yaml --dry-run=client > olders-configmap.yaml

--Step 7.2 (Lab)
root@docker-minikube-n02:~# ll olders-configmap.yaml
/*
-rw-r--r-- 1 root root 130 May 31 15:44 olders-configmap.yaml
*/

--Step 7.3 (Lab)
root@docker-minikube-n02:~# kubectl create ns busyns
/*
namespace/busyns created
*/

--Step 7.4 (Lab)
root@docker-minikube-n02:~# kubectl apply -f olders-configmap.yaml
/*
configmap/olders-config created
*/

--Step 7.5 (Lab)
root@docker-minikube-n02:~# kubectl get configmap
/*
NAME               DATA   AGE
app-config         2      86m
kube-root-ca.crt   1      6h51m
*/

--Step 8 (Lab)
root@docker-minikube-n02:~# kubectl create secret generic olders-db-secret -n busyns --from-literal=DB_USER=admin --from-literal DB_Pass="admin@pass123" -o yaml --dry-run=client
/*
apiVersion: v1
data:
  DB_Pass: YWRtaW5AcGFzczEyMw==
  DB_USER: YWRtaW4=
kind: Secret
metadata:
  name: olders-db-secret
  namespace: busyns
*/

--Step 8.1 (Lab)
root@docker-minikube-n02:~# kubectl create secret generic olders-db-secret -n busyns --from-literal=DB_USER=admin --from-literal DB_Pass="admin@pass123" -o yaml --dry-run=client > olders-db-secret.yaml

--Step 8.2 (Lab)
root@docker-minikube-n02:~# ll olders-db-secret.yaml
/*
-rw-r--r-- 1 root root 141 May 31 15:47 olders-db-secret.yaml
*/

--Step 8.3 (Lab)
root@docker-minikube-n02:~# kubectl apply -f olders-db-secret.yaml
/*
secret/olders-db-secret created
*/

--Step 8.4 (Lab)
root@docker-minikube-n02:~# kubectl get secret
/*
NAME        TYPE     DATA   AGE
db-secret   Opaque   2      86m
*/