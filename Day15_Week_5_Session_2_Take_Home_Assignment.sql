--DNS & Ingress
--Step 1 (Lab)
--Prerequisites
root@docker-minikube-n01:~#  minikube delete --all
/*
* Deleting "minikube" in docker ...
* Removing /root/.minikube/machines/minikube ...
* Removing /root/.minikube/machines/minikube-m02 ...
* Removed all traces of the "minikube" cluster.
* Successfully deleted all profiles
*/

--Step 1.1 (Lab)
--Environment Setup
--This deployment uses pod anti-affinity rules that require pods to spread across nodes. Provision a 3-node cluster:
root@docker-minikube-n01:~# minikube start --nodes 3 --force
/*
* minikube v1.38.1 on Ubuntu 24.04
! minikube skips various validations when --force is supplied; this may lead to unexpected behavior
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
--Verify all three nodes are in Ready state before continuing:
root@docker-minikube-n01:~# alias k=kubectl
root@docker-minikube-n01:~# k get nodes -o wide
/*
NAME           STATUS   ROLES           AGE     VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE                         KERNEL-VERSION      CONTAINER-RUNTIME
minikube       Ready    control-plane   5m50s   v1.35.1   192.168.49.2   <none>        Debian GNU/Linux 12 (bookworm)   6.8.0-124-generic   docker://29.2.1
minikube-m02   Ready    <none>          3m55s   v1.35.1   192.168.49.3   <none>        Debian GNU/Linux 12 (bookworm)   6.8.0-124-generic   docker://29.2.1
minikube-m03   Ready    <none>          2m3s    v1.35.1   192.168.49.4   <none>        Debian GNU/Linux 12 (bookworm)   6.8.0-124-generic   docker://29.2.1
*/

--Step 1.3 (Lab)
--Enable the Ingress controller
root@docker-minikube-n01:~# minikube addons enable ingress
/*
* ingress is an addon maintained by Kubernetes. For any concerns contact minikube on GitHub.
You can view the list of minikube maintainers at: https://github.com/kubernetes/minikube/blob/master/OWNERS
  - Using image registry.k8s.io/ingress-nginx/controller:v1.14.3
  - Using image registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.6.7
  - Using image registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.6.7
* Verifying ingress addon...
* The 'ingress' addon is enabled
*/

--Step 1.4 (Lab)
--The Ingress controller
root@docker-minikube-n01:~# kubectl get pods -n ingress-nginx --watch
/*
NAME                                        READY   STATUS      RESTARTS   AGE
ingress-nginx-admission-create-d8hk4        0/1     Completed   0          3m38s
ingress-nginx-admission-patch-xfp78         0/1     Completed   1          3m38s
ingress-nginx-controller-596f8778bc-pk8cq   1/1     Running     0          3m39s
*/

--Step 1.4.1 (Lab)
root@docker-minikube-n01:~# kubectl get pods -n ingress-nginx -o wide
/*
NAME                                        READY   STATUS      RESTARTS   AGE     IP           NODE       NOMINATED NODE   READINESS GATES
ingress-nginx-admission-create-d8hk4        0/1     Completed   0          3m50s   10.244.0.4   minikube   <none>           <none>
ingress-nginx-admission-patch-xfp78         0/1     Completed   1          3m50s   10.244.0.3   minikube   <none>           <none>
ingress-nginx-controller-596f8778bc-pk8cq   1/1     Running     0          3m51s   10.244.0.5   minikube   <none>           <none>
*/

--Part 1 — Build and Publish Container Images
--Step 2 (Lab)
--Step 1 — Create the repositories on DockerHub.
--Go to https://hub.docker.com/repositories/unidev39, 
--create two repositories named kirashop-backend and kirashop-frontend, and set both to Public.

--Step 2.1 (Lab)
root@docker-minikube-n01:~# mkdir -p /root/backend
root@docker-minikube-n01:~# mkdir -p /root/frontend

--Step 2.2 (Lab) - Node.js Backend & React/Frontend
--Create the Dockerfiles
root@docker-minikube-n01:~# cd /root/backend/
root@docker-minikube-n01:~# vi /backend/Dockerfile_Backend
/*
# backend/Dockerfile
FROM node:18-alpine

WORKDIR /usr/src/app

# Copy package management files to leverage Docker layer caching
COPY package*.json ./
RUN npm install --omit=dev

# Copy the remaining backend source code
COPY . .

# Document that the backend service listens on port 5000
EXPOSE 5000

# Execute the application start command
CMD ["node", "server.js"]
*/

--Step 2.2.1 (Lab) - Node.js Backend & React/Frontend
root@docker-minikube-n01:~/backend# cat <<EOF > package.json
{
  "name": "kirashop-backend",
  "version": "1.0.0",
  "description": "Kirashop Backend Service",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.19.2"
  }
}
EOF


--Step 2.3 (Lab) - Node.js Backend & React/Frontend
--Create the Frontend Dockerfile
root@docker-minikube-n01:~# cd /root/frontend/
root@docker-minikube-n01:~# vi Dockerfile_FrontEnd
/*
# frontend/Dockerfile
# --- Stage 1: Build static assets ---
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# --- Stage 2: Serve the compiled build files ---
FROM nginx:alpine
COPY --from=builder /app/build /usr/share/nginx/html

# Expose port 80 for web traffic
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
*/

--Step 2.3.1 (Lab) - Node.js Backend & React/Frontend
root@docker-minikube-n01:~/frontend# cat <<EOF > package.json
{
  "name": "kirashop-frontend",
  "version": "1.0.0",
  "scripts": {
    "build": "mkdir -p build && echo '<h1>Welcome to Kirashop Frontend</h1>' > build/index.html"
  }
}
EOF

--Srep 3 (Lab)
--Step 2 — Log in to DockerHub from your terminal.
root@docker-minikube-n01:~# docker login -u unidev39
/*
i Info → A Personal Access Token (PAT) can be used instead.
         To create a PAT, visit https://app.docker.com/settings


Password:
Login Succeeded
*/

--Srep 4 (Lab) - Docker Build
root@docker-minikube-n01:~/backend# docker build -t unidev39/kirashop-backend:v1 -f Dockerfile_Backend .
/*
[+] Building 39.4s (11/11) FINISHED                                                                                                                                           docker:default
 => [internal] load build definition from Dockerfile_Backend                                                                                                                            0.1s
 => => transferring dockerfile: 413B                                                                                                                                                    0.0s
 => [internal] load metadata for docker.io/library/node:18-alpine                                                                                                                       1.5s
 => [auth] library/node:pull token for registry-1.docker.io                                                                                                                             0.0s
 => [internal] load .dockerignore                                                                                                                                                       0.0s
 => => transferring context: 2B                                                                                                                                                         0.0s
 => [1/5] FROM docker.io/library/node:18-alpine@sha256:8d6421d663b4c28fd3ebc498332f249011d118945588d0a35cb9bc4b8ca09d9e                                                                 0.1s
 => => resolve docker.io/library/node:18-alpine@sha256:8d6421d663b4c28fd3ebc498332f249011d118945588d0a35cb9bc4b8ca09d9e                                                                 0.1s
 => [internal] load build context                                                                                                                                                       0.0s
 => => transferring context: 335B                                                                                                                                                       0.0s
 => CACHED [2/5] WORKDIR /usr/src/app                                                                                                                                                   0.0s
 => [3/5] COPY package*.json ./                                                                                                                                                         0.1s
 => [4/5] RUN npm install --omit=dev                                                                                                                                                   32.0s
 => [5/5] COPY . .                                                                                                                                                                      0.3s
 => exporting to image                                                                                                                                                                  4.7s
 => => exporting layers                                                                                                                                                                 2.3s
 => => exporting manifest sha256:c687d7b8ae7cc2c3578c55c123681c9628a651d9998c24a336e8493788a26eb5                                                                                       0.0s
 => => exporting config sha256:7e5fa8a872f6f87958302287869f5abaafc9ba50005a73b86970af79f4c75312                                                                                         0.0s
 => => exporting attestation manifest sha256:84dcc12eda1e0dfb9d4b998d9a75d972ed07e59e5a6d0e9cb003516e35fb19e3                                                                           0.1s
 => => exporting manifest list sha256:68bda72f365c1f43c0a98d1d4e0df08b109efeedffe042d315f2027c0ac62c1a                                                                                  0.0s
 => => naming to docker.io/unidev39/kirashop-backend:v1                                                                                                                                 0.0s
 => => unpacking to docker.io/unidev39/kirashop-backend:v1     
*/

--Srep 4.1 (Lab) - Docker Push
root@docker-minikube-n01:~/backend# docker push unidev39/kirashop-backend:v1
/*
The push refers to repository [docker.io/unidev39/kirashop-backend]
721bde4ae532: Pushed
25ff2da83641: Pushed
1e5a4c89cee5: Pushed
0c286fd39ffc: Pushed
185c7e6b10b3: Pushed
f18232174bc9: Pushed
dd71dde834b5: Pushed
d10371f160fa: Pushed
ddd36cf50888: Pushed
v1: digest: sha256:68bda72f365c1f43c0a98d1d4e0df08b109efeedffe042d315f2027c0ac62c1a size: 856
*/

--Srep 5 (Lab) - Docker Build
root@docker-minikube-n01:~/frontend# docker build -t unidev39/kirashop-frontend:v1 -f Dockerfile_FrontEnd .
/*
[+] Building 18.6s (16/16) FINISHED                                                                                                                                           docker:default
 => [internal] load build definition from Dockerfile_FrontEnd                                                                                                                           0.1s
 => => transferring dockerfile: 420B                                                                                                                                                    0.0s
 => [internal] load metadata for docker.io/library/node:18-alpine                                                                                                                       1.7s
 => [internal] load metadata for docker.io/library/nginx:alpine                                                                                                                         1.7s
 => [auth] library/nginx:pull token for registry-1.docker.io                                                                                                                            0.0s
 => [auth] library/node:pull token for registry-1.docker.io                                                                                                                             0.0s
 => [internal] load .dockerignore                                                                                                                                                       0.0s
 => => transferring context: 2B                                                                                                                                                         0.0s
 => [builder 1/6] FROM docker.io/library/node:18-alpine@sha256:8d6421d663b4c28fd3ebc498332f249011d118945588d0a35cb9bc4b8ca09d9e                                                         0.1s
 => => resolve docker.io/library/node:18-alpine@sha256:8d6421d663b4c28fd3ebc498332f249011d118945588d0a35cb9bc4b8ca09d9e                                                                 0.1s
 => [stage-1 1/2] FROM docker.io/library/nginx:alpine@sha256:8b1e78743a03dbb2c95171cc58639fef29abc8816598e27fb910ed2e621e589a                                                           9.4s
 => => resolve docker.io/library/nginx:alpine@sha256:8b1e78743a03dbb2c95171cc58639fef29abc8816598e27fb910ed2e621e589a                                                                   0.2s
 => => extracting sha256:fbaed3f7fcbe6a0d591ac8601934f1f05252cee42741fde9e950dce55580af18                                                                                               9.2s
 => [internal] load build context                                                                                                                                                       0.1s
 => => transferring context: 636B                                                                                                                                                       0.0s
 => CACHED [builder 2/6] WORKDIR /app                                                                                                                                                   0.0s
 => [builder 3/6] COPY package*.json ./                                                                                                                                                 0.1s
 => [builder 4/6] RUN npm install                                                                                                                                                      11.3s
 => [builder 5/6] COPY . .                                                                                                                                                              0.2s
 => [builder 6/6] RUN npm run build                                                                                                                                                     3.5s
 => [stage-1 2/2] COPY --from=builder /app/build /usr/share/nginx/html                                                                                                                  0.1s
 => exporting to image                                                                                                                                                                  0.8s
 => => exporting layers                                                                                                                                                                 0.3s
 => => exporting manifest sha256:da2147edafb9577df2a98edfd260946fedcd3e706b5a176949b3dec290e882c0                                                                                       0.0s
 => => exporting config sha256:2353493d102b1c574afa8cef721b1646c14e297a9c06fb80286c6c82395b0f70                                                                                         0.0s
 => => exporting attestation manifest sha256:34fad6f30c7baabc989f291dc191da7303cfa39ec22024fa1967dc1a53e544d2                                                                           0.1s
 => => exporting manifest list sha256:eed3c13d6099ee701d22761ce4aa44e5a4f2ffdbc757508eb5f62d41eaa5966b                                                                                  0.0s
 => => naming to docker.io/unidev39/kirashop-frontend:v1                                                                                                                                0.0s
 => => unpacking to docker.io/unidev39/kirashop-frontend:v1
*/

--Srep 5.1 (Lab) - Docker Push
root@docker-minikube-n01:~/frontend# docker push unidev39/kirashop-frontend:v1
/*
The push refers to repository [docker.io/unidev39/kirashop-frontend]
e654dbbbb9e1: Pushed
e1961e4a2561: Pushed
6a0ac1617861: Pushed
94d083cf706a: Pushed
fbaed3f7fcbe: Pushed
f2e0376178c8: Pushed
abaae85d1626: Pushed
43f834d60d8a: Pushed
de1b677d8c00: Pushed
a5008f4a4b25: Pushed
v1: digest: sha256:eed3c13d6099ee701d22761ce4aa44e5a4f2ffdbc757508eb5f62d41eaa5966b size: 856
*/

--Srep 6 (Lab)
root@docker-minikube-n01:~# docker images
/*                                                                                                                                                                         i Info →   U  In Use
IMAGE                                                                                                 ID             DISK USAGE   CONTENT SIZE   EXTRA
gcr.io/k8s-minikube/kicbase:v0.0.50                                                                   b97074569ae9       1.94GB          545MB
gcr.io/k8s-minikube/kicbase@sha256:eb4fec00e8ad70adf8e6436f195cc429825ffb85f95afcdb5d8d9deb576f3e93   eb4fec00e8ad       1.94GB          545MB    U
unidev39/kirashop-backend:v1                                                                          68bda72f365c        196MB         47.3MB
unidev39/kirashop-frontend:v1                                                                         eed3c13d6099       92.7MB           26MB
*/

--Step 6.1 (Lab)
root@docker-minikube-n01:~# k get pods -A -o wide
/*
NAMESPACE       NAME                                        READY   STATUS      RESTARTS   AGE    IP             NODE           NOMINATED NODE   READINESS GATES
ingress-nginx   ingress-nginx-admission-create-d8hk4        0/1     Completed   0          152m   10.244.0.4     minikube       <none>           <none>
ingress-nginx   ingress-nginx-admission-patch-xfp78         0/1     Completed   1          152m   10.244.0.3     minikube       <none>           <none>
ingress-nginx   ingress-nginx-controller-596f8778bc-pk8cq   1/1     Running     0          152m   10.244.0.5     minikube       <none>           <none>
kube-system     coredns-7d764666f9-rd65f                    1/1     Running     0          159m   10.244.0.2     minikube       <none>           <none>
kube-system     etcd-minikube                               1/1     Running     0          159m   192.168.49.2   minikube       <none>           <none>
kube-system     kindnet-4dfkg                               1/1     Running     0          157m   192.168.49.3   minikube-m02   <none>           <none>
kube-system     kindnet-52gcs                               1/1     Running     0          159m   192.168.49.2   minikube       <none>           <none>
kube-system     kindnet-xszzq                               1/1     Running     0          155m   192.168.49.4   minikube-m03   <none>           <none>
kube-system     kube-apiserver-minikube                     1/1     Running     0          159m   192.168.49.2   minikube       <none>           <none>
kube-system     kube-controller-manager-minikube            1/1     Running     0          159m   192.168.49.2   minikube       <none>           <none>
kube-system     kube-proxy-4t4xr                            1/1     Running     0          157m   192.168.49.3   minikube-m02   <none>           <none>
kube-system     kube-proxy-9dv9k                            1/1     Running     0          155m   192.168.49.4   minikube-m03   <none>           <none>
kube-system     kube-proxy-qq5k2                            1/1     Running     0          159m   192.168.49.2   minikube       <none>           <none>
kube-system     kube-scheduler-minikube                     1/1     Running     0          159m   192.168.49.2   minikube       <none>           <none>
kube-system     storage-provisioner                         1/1     Running     0          159m   192.168.49.2   minikube       <none>           <none>
*/

--Step 6.2 (Lab)
--Knowledge check
--Q1. True or False: Kubernetes pulls container images at the time the Deployment is created, not when individual pods are scheduled.
--A1. False

--Q2: A pod is stuck in ImagePullBackOff. What does this indicate?
--A2: Not Seen

--Step 7 (Lab)
--Part 2 — Deploy PostgreSQL as a StatefulSet
root@docker-minikube-n01:~# vi postgres-statefulset.yaml
/*
apiVersion: v1
kind: Service
metadata:
  name: postgres
spec:
  clusterIP: None
  selector:
    app: postgres
  ports:
    - port: 5432
      targetPort: 5432
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  serviceName: postgres
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
        - name: postgres
          image: postgres:15
          ports:
            - containerPort: 5432
*/

--Step 7.1 (Lab)
root@docker-minikube-n01:~# k apply -f postgres-statefulset.yaml --dry-run=client
/*
service/postgres created (dry run)
statefulset.apps/postgres created (dry run)
*/

--Step 7.2 (Lab)
root@docker-minikube-n01:~# k apply -f postgres-statefulset.yaml
/*
service/postgres created
statefulset.apps/postgres created
*/

--Step 7.3 (Lab)
root@docker-minikube-n01:~# kubectl get statefulset postgres
/*
NAME       READY   AGE
postgres   0/1     53s
*/

--Step 7.3.1 (Lab)
root@docker-minikube-n01:~# k get statefulset postgres -o wide
/*
NAME       READY   AGE   CONTAINERS   IMAGES
postgres   0/1     83s   postgres     postgres:15
*/

--Step 7.4 (Lab)
root@docker-minikube-n01:~# kubectl get pods -l app=postgres
/*
NAME         READY   STATUS             RESTARTS     AGE
postgres-0   0/1     CrashLoopBackOff   1 (3s ago)   69s
*/

--Step 7.4.1 (Lab)
root@docker-minikube-n01:~# kubectl get pods -l app=postgres -o wide
/*
NAME         READY   STATUS             RESTARTS      AGE   IP           NODE           NOMINATED NODE   READINESS GATES
postgres-0   0/1     CrashLoopBackOff   2 (14s ago)   93s   10.244.1.2   minikube-m02   <none>           <none>
*/

--Step 7.5 (Lab)
--Knowledge check
--Q1: True or False: StatefulSet pod names are randomly generated, just like Deployment pods.
--A1: False

--Q2: What is the name of the pod created by a StatefulSet named postgres for its first replica?
--A2: postgres-0

--Step 8 (Lab)
--Part 3 — Secrets Management
root@docker-minikube-n01:~# k create secret generic db-secret \
  --from-literal=POSTGRES_PASSWORD=Passw0rD \
  --from-literal=POSTGRES_DB=kiranashaop \
  --from-literal=DATABASE_URL=postgresql://postgres:Passw0rD@postgres:5432/kiranashaop
/*
secret/db-secret created
*/

--Step 8.1 (Lab)
root@docker-minikube-n01:~# k get secret db-secret -o yaml > db-secret.yaml

--Step 8.1.1 (Lab)
root@docker-minikube-n01:~# cat db-secret.yaml
/*
apiVersion: v1
data:
  DATABASE_URL: cG9zdGdyZXNxbDovL3Bvc3RncmVzOlBhc3N3MHJEQHBvc3RncmVzOjU0MzIva2lyYW5hc2hhb3A=
  POSTGRES_DB: a2lyYW5hc2hhb3A=
  POSTGRES_PASSWORD: UGFzc3cwckQ=
kind: Secret
metadata:
  creationTimestamp: "2026-06-09T11:38:35Z"
  name: db-secret
  namespace: default
  resourceVersion: "12858"
  uid: c6b02154-797f-4a1e-947f-093144bd563d
type: Opaque
*/

--Step 8.2 (Lab) -- add an envFrom block inside the container spec
root@docker-minikube-n01:~# vi postgres-statefulset.yaml
/*
apiVersion: v1
kind: Service
metadata:
  name: postgres
spec:
  clusterIP: None
  selector:
    app: postgres
  ports:
    - port: 5432
      targetPort: 5432
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  serviceName: postgres
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
        - name: postgres
          image: postgres:15
          ports:
            - containerPort: 5432
          envFrom:
            - secretRef:
                name: db-secret
*/

--Step 8.3 (Lab)
root@docker-minikube-n01:~# k apply -f postgres-statefulset.yaml --dry-run=client
/*
service/postgres unchanged (dry run)
statefulset.apps/postgres configured (dry run)
*/

--Step 8.4 (Lab)
root@docker-minikube-n01:~# k apply -f postgres-statefulset.yaml
/*
service/postgres unchanged
statefulset.apps/postgres configured
*/

--Step 8.5 (Lab)
root@docker-minikube-n01:~# k get statefulset postgres -o wide
/*
NAME       READY   AGE   CONTAINERS   IMAGES
postgres   0/1     19m   postgres     postgres:15
*/

--Step 8.6 (Lab)
root@docker-minikube-n01:~# kubectl get pods -l app=postgres -o wide
/*
NAME         READY   STATUS             RESTARTS        AGE   IP           NODE           NOMINATED NODE   READINESS GATES
postgres-0   0/1     CrashLoopBackOff   8 (2m52s ago)   19m   10.244.1.2   minikube-m02   <none>           <none>
*/

--Step 8.7 (Lab)
root@docker-minikube-n01:~# k delete pod postgres-0
/*
pod "postgres-0" deleted from default namespace
*/

--Step 8.8 (Lab)
--The StatefulSet controller will recreate postgres-0 right away. Wait for it to become ready:
root@docker-minikube-n01:~# k rollout status statefulset/postgres
/*
partitioned roll out complete: 1 new pods have been updated...
*/

--Step 8.9 (Lab)
root@docker-minikube-n01:~# k get statefulset postgres
/*
NAME       READY   AGE
postgres   1/1     23m
*/

--Step 8.10 (Lab)
root@docker-minikube-n01:~# k get statefulset postgres -o wide
/*
NAME       READY   AGE   CONTAINERS   IMAGES
postgres   1/1     23m   postgres     postgres:15
*/

--Step 8.11 (Lab)
root@docker-minikube-n01:~# kubectl get pods -l app=postgres -o wide
/*
NAME         READY   STATUS    RESTARTS   AGE   IP           NODE           NOMINATED NODE   READINESS GATES
postgres-0   1/1     Running   0          42s   10.244.1.3   minikube-m02   <none>           <none>
*/

--Step 9 (Lab)
--Part 4 — Database Initialisation
root@docker-minikube-n01:~# k exec -it postgres-0 -- psql -U postgres -d kiranashaop
/*
psql (15.18 (Debian 15.18-1.pgdg13+1))
Type "help" for help.

kiranashaop=# CREATE TABLE items (
    id       SERIAL PRIMARY KEY,
    name     VARCHAR(100),
    category VARCHAR(50),
    price    NUMERIC(10,2)
);
CREATE TABLE
kiranashaop=# INSERT INTO items (name, category, price) VALUES
  ('Rice (1kg)',        'Grain',      120.00),
  ('Lentils (500g)',    'Grain',       95.00),
  ('Mustard Oil (1L)',  'Oil',        280.00),
  ('Salt (1kg)',        'Spice',       25.00),
  ('Sugar (1kg)',       'Sweetener',   85.00),
  ('Tea Leaves (250g)', 'Beverage',   150.00),
  ('Wheat Flour (1kg)', 'Grain',       65.00),
  ('Milk (1L)',         'Dairy',      110.00),
  ('Onion (1kg)',       'Vegetable',   60.00),
  ('Potato (1kg)',      'Vegetable',   45.00);
INSERT 0 10
kiranashaop=# SELECT * FROM items;
 id |       name        | category  | price
----+-------------------+-----------+--------
  1 | Rice (1kg)        | Grain     | 120.00
  2 | Lentils (500g)    | Grain     |  95.00
  3 | Mustard Oil (1L)  | Oil       | 280.00
  4 | Salt (1kg)        | Spice     |  25.00
  5 | Sugar (1kg)       | Sweetener |  85.00
  6 | Tea Leaves (250g) | Beverage  | 150.00
  7 | Wheat Flour (1kg) | Grain     |  65.00
  8 | Milk (1L)         | Dairy     | 110.00
  9 | Onion (1kg)       | Vegetable |  60.00
 10 | Potato (1kg)      | Vegetable |  45.00
(10 rows)

kiranashaop=# \q
*/

--Step 10 (Lab)
--Part 5 — Deploy the Backend Service
root@docker-minikube-n01:~# k create deployment kirashop-backend \
  --image=unidev39/kirashop-backend:v1 \
  --replicas=2 \
  --dry-run=client -o yaml
/*
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: kirashop-backend
  name: kirashop-backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: kirashop-backend
  strategy: {}
  template:
    metadata:
      labels:
        app: kirashop-backend
    spec:
      containers:
      - image: unidev39/kirashop-backend:v1
        name: kirashop-backend
        resources: {}
status: {}
*/

--Step 10.1 (Lab)
root@docker-minikube-n01:~# k create deployment kirashop-backend   --image=unidev39/kirashop-backend:v1   --replicas=2   --dry-run=client -o yaml > backend-deployment.yaml

--Step 10.2 (Lab)
--Open backend-deployment.yaml. Make two additions under spec.template.spec — note that this is spec.template.spec, not spec.template.metadata:
--1. Add a DATABASE_URL environment variable from the Secret:
--Under spec.template.spec.containers[0], add an env entry that reads DATABASE_URL from db-secret using valueFrom.secretKeyRef.
--2. Add pod anti-affinity:
--Under spec.template.spec, add an affinity.podAntiAffinity block using preferredDuringSchedulingIgnoredDuringExecution with topologyKey: kubernetes.io/hostname. 
--The labelSelector should match pods with label app: kirashop-backend.
root@docker-minikube-n01:~# vi backend-deployment.yaml
/*
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: kirashop-backend
  name: kirashop-backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: kirashop-backend
  strategy: {}
  template:
    metadata:
      labels:
        app: kirashop-backend
    spec:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 100
              podAffinityTerm:
                labelSelector:
                  matchExpressions:
                    - key: app
                      operator: In
                      values:
                        - kirashop-backend
                topologyKey: kubernetes.io/hostname
      containers:
        - image: unidev39/kirashop-backend:v1
          name: kirashop-backend
          env:
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: db-secret
                  key: DATABASE_URL
          resources: {}
status: {}
*/

--Step 10.3 (Lab)
root@docker-minikube-n01:~# k apply -f backend-deployment.yaml --dry-run=client
/*
deployment.apps/kirashop-backend created (dry run)
*/

--Step 10.4 (Lab)
root@docker-minikube-n01:~# k apply -f backend-deployment.yaml
/*
deployment.apps/kirashop-backend created
*/

--Step 10.5 (Lab)
root@docker-minikube-n01:~# k rollout status deployment/kirashop-backend
/*
Waiting for deployment "kirashop-backend" rollout to finish: 0 of 2 updated replicas are available...
Waiting for deployment "kirashop-backend" rollout to finish: 1 of 2 updated replicas are available...
deployment "kirashop-backend" successfully rolled out
*/

--Step 10.6 (Lab)
root@docker-minikube-n01:~# kubectl expose deployment kirashop-backend --port=5000 --target-port=5000
/*
service/kirashop-backend exposed
*/

--Step 10.7 (Lab)
root@docker-minikube-n01:~# kubectl get service kirashop-backend -o yaml > backend-service.yaml

--Step 10.7.1 (Lab)
root@docker-minikube-n01:~# cat backend-service.yaml
/*
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: "2026-06-09T12:01:21Z"
  labels:
    app: kirashop-backend
  name: kirashop-backend
  namespace: default
  resourceVersion: "14486"
  uid: 3a9e1eed-a92e-48c0-88e9-d177160c851b
spec:
  clusterIP: 10.107.135.237
  clusterIPs:
  - 10.107.135.237
  internalTrafficPolicy: Cluster
  ipFamilies:
  - IPv4
  ipFamilyPolicy: SingleStack
  ports:
  - port: 5000
    protocol: TCP
    targetPort: 5000
  selector:
    app: kirashop-backend
  sessionAffinity: None
  type: ClusterIP
status:
  loadBalancer: {}
*/

--Step 10.8 (Lab)
root@docker-minikube-n01:~# k get svc kirashop-backend -o wide
/*
NAME               TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE   SELECTOR
kirashop-backend   ClusterIP   10.107.135.237   <none>        5000/TCP   61s   app=kirashop-backend
*/

--Step 10.9 (Lab)
root@docker-minikube-n01:~# k get endpoints kirashop-backend -o wide
/*
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME               ENDPOINTS                         AGE
kirashop-backend   10.244.1.4:5000,10.244.2.3:5000   87s
*/

--Step 11 (Lab)
--Part 6 — Frontend Configuration
root@docker-minikube-n01:~# vi /root/frontend/app.py
/*
import os
import requests
from flask import Flask

app = Flask(__name__)
BACKEND_URL = os.environ.get("BACKEND_URL", "http://localhost:5000")
*/

--Step 11.1 (Lab)
root@docker-minikube-n01:~# k create configmap frontend-config --from-literal=BACKEND_URL=http://kirashop-backend:5000
/*
configmap/frontend-config created
*/

--Step 11.2 (Lab)
root@docker-minikube-n01:~# k get configmap frontend-config
/*
NAME              DATA   AGE
frontend-config   1      19s
*/

--Step 11.3 (Lab)
root@docker-minikube-n01:~# k describe configmap frontend-config
/*
Name:         frontend-config
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
BACKEND_URL:
----
http://kirashop-backend:5000


BinaryData
====

Events:  <none>
*/

--Step 11.4 (Lab)
root@docker-minikube-n01:~# k get configmap frontend-config -o yaml > frontend-configmap.yaml
root@docker-minikube-n01:~# cat frontend-configmap.yaml
/*
apiVersion: v1
data:
  BACKEND_URL: http://kirashop-backend:5000
kind: ConfigMap
metadata:
  creationTimestamp: "2026-06-09T12:13:00Z"
  name: frontend-config
  namespace: default
  resourceVersion: "15284"
  uid: 8c690f1d-e7c7-401b-8618-bbfb452b7f8d
*/

--Step 12 (Lab)
--Part 7 — Deploy the Frontend Service
root@docker-minikube-n01:~# k create deployment kirashop-frontend \
  --image=unidev39/kirashop-frontend:v1 \
  --replicas=2 \
  --dry-run=client -o yaml
/*
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: kirashop-frontend
  name: kirashop-frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: kirashop-frontend
  strategy: {}
  template:
    metadata:
      labels:
        app: kirashop-frontend
    spec:
      containers:
      - image: unidev39/kirashop-frontend:v1
        name: kirashop-frontend
        resources: {}
status: {}
*/

--Step 12.1 (Lab)
root@docker-minikube-n01:~# k create deployment kirashop-frontend \
  --image=unidev39/kirashop-frontend:v1 \
  --replicas=2 \
  --dry-run=client -o yaml > frontend-deployment.yaml

--Step 12.2 (Lab)
--Open frontend-deployment.yaml and make two additions under spec.template.spec:
--1. Inject all keys from the ConfigMap as environment variables:
--Under spec.template.spec.containers[0], add an envFrom entry using configMapRef pointing to frontend-config.
--2. Add pod anti-affinity:
--Same pattern as Part 5. Add the affinity.podAntiAffinity block under spec.template.spec. Change the matchLabels.app value to kirashop-frontend.
root@docker-minikube-n01:~# vi frontend-deployment.yaml
/*
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: kirashop-frontend
  name: kirashop-frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: kirashop-frontend
  strategy: {}
  template:
    metadata:
      labels:
        app: kirashop-frontend
    spec:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 100
              podAffinityTerm:
                labelSelector:
                  matchExpressions:
                    - key: app
                      operator: In
                      values:
                        - kirashop-frontend
                topologyKey: kubernetes.io/hostname
      containers:
        - image: unidev39/kirashop-frontend:v1
          name: kirashop-frontend
          envFrom:
            - configMapRef:
                name: frontend-config
          resources: {}
status: {}
*/

--Step 12.3 (Lab)
root@docker-minikube-n01:~# k apply -f frontend-deployment.yaml --dry-run=client
/*
deployment.apps/kirashop-frontend created (dry run)
*/

--Step 12.4 (Lab)
root@docker-minikube-n01:~# k apply -f frontend-deployment.yaml
/*
deployment.apps/kirashop-frontend created
*/

--Step 12.5 (Lab)
root@docker-minikube-n01:~# k rollout status deployment/kirashop-frontend
/*
Waiting for deployment "kirashop-frontend" rollout to finish: 0 of 2 updated replicas are available...
Waiting for deployment "kirashop-frontend" rollout to finish: 1 of 2 updated replicas are available...
deployment "kirashop-frontend" successfully rolled out
*/

--Step 12.6 (Lab)
root@docker-minikube-n01:~# k get pods -o wide -l app=kirashop-frontend
/*
NAME                                 READY   STATUS    RESTARTS   AGE     IP           NODE           NOMINATED NODE   READINESS GATES
kirashop-frontend-699d4944f7-2hdn5   1/1     Running   0          2m12s   10.244.1.5   minikube-m02   <none>           <none>
kirashop-frontend-699d4944f7-bbp4n   1/1     Running   0          2m12s   10.244.2.4   minikube-m03   <none>           <none>
*/

--Step 12.7 (Lab)
root@docker-minikube-n01:~# k get pods -o wide
/*
NAME                                 READY   STATUS             RESTARTS   AGE     IP           NODE           NOMINATED NODE   READINESS GATES
dnsutils                             0/1     ImagePullBackOff   0          67m     10.244.2.2   minikube-m03   <none>           <none>
kirashop-backend-5bf58866cd-68c4c    1/1     Running            0          28m     10.244.1.4   minikube-m02   <none>           <none>
kirashop-backend-5bf58866cd-htmzn    1/1     Running            0          28m     10.244.2.3   minikube-m03   <none>           <none>
kirashop-frontend-699d4944f7-2hdn5   1/1     Running            0          4m47s   10.244.1.5   minikube-m02   <none>           <none>
kirashop-frontend-699d4944f7-bbp4n   1/1     Running            0          4m47s   10.244.2.4   minikube-m03   <none>           <none>
postgres-0                           1/1     Running            0          42m     10.244.1.3   minikube-m02   <none>           <none>
*/


--Step 13 (Lab)
--Part 8 — Ingress Routing
root@docker-minikube-n01:~# k create ingress kirashop --class=nginx --rule="frontend.kiranshop.com/*=kiranashop-frontend:8080"
/*
ingress.networking.k8s.io/kirashop created
*/

--Step 13.1 (Lab)
root@docker-minikube-n01:~# k get ingress kirashop -o wide
/*
NAME       CLASS   HOSTS                    ADDRESS   PORTS   AGE
kirashop   nginx   frontend.kiranshop.com             80      18s
*/

--Step 14 (Lab)
--Part 9 — End-to-End Validation
root@docker-minikube-n01:~# k get pods -A -o wide
/*
NAMESPACE       NAME                                        READY   STATUS             RESTARTS   AGE     IP             NODE           NOMINATED NODE   READINESS GATES
default         dnsutils                                    0/1     ImagePullBackOff   0          76m     10.244.2.2     minikube-m03   <none>           <none>
default         kirashop-backend-5bf58866cd-68c4c           1/1     Running            0          38m     10.244.1.4     minikube-m02   <none>           <none>
default         kirashop-backend-5bf58866cd-htmzn           1/1     Running            0          38m     10.244.2.3     minikube-m03   <none>           <none>
default         kirashop-frontend-699d4944f7-2hdn5          1/1     Running            0          14m     10.244.1.5     minikube-m02   <none>           <none>
default         kirashop-frontend-699d4944f7-bbp4n          1/1     Running            0          14m     10.244.2.4     minikube-m03   <none>           <none>
default         postgres-0                                  1/1     Running            0          51m     10.244.1.3     minikube-m02   <none>           <none>
ingress-nginx   ingress-nginx-admission-create-d8hk4        0/1     Completed          0          3h53m   10.244.0.4     minikube       <none>           <none>
ingress-nginx   ingress-nginx-admission-patch-xfp78         0/1     Completed          1          3h53m   10.244.0.3     minikube       <none>           <none>
ingress-nginx   ingress-nginx-controller-596f8778bc-pk8cq   1/1     Running            0          3h53m   10.244.0.5     minikube       <none>           <none>
kube-system     coredns-7d764666f9-rd65f                    1/1     Running            0          3h59m   10.244.0.2     minikube       <none>           <none>
kube-system     etcd-minikube                               1/1     Running            0          3h59m   192.168.49.2   minikube       <none>           <none>
kube-system     kindnet-4dfkg                               1/1     Running            0          3h58m   192.168.49.3   minikube-m02   <none>           <none>
kube-system     kindnet-52gcs                               1/1     Running            0          3h59m   192.168.49.2   minikube       <none>           <none>
kube-system     kindnet-xszzq                               1/1     Running            0          3h56m   192.168.49.4   minikube-m03   <none>           <none>
kube-system     kube-apiserver-minikube                     1/1     Running            0          3h59m   192.168.49.2   minikube       <none>           <none>
kube-system     kube-controller-manager-minikube            1/1     Running            0          3h59m   192.168.49.2   minikube       <none>           <none>
kube-system     kube-proxy-4t4xr                            1/1     Running            0          3h58m   192.168.49.3   minikube-m02   <none>           <none>
kube-system     kube-proxy-9dv9k                            1/1     Running            0          3h56m   192.168.49.4   minikube-m03   <none>           <none>
kube-system     kube-proxy-qq5k2                            1/1     Running            0          3h59m   192.168.49.2   minikube       <none>           <none>
kube-system     kube-scheduler-minikube                     1/1     Running            0          3h59m   192.168.49.2   minikube       <none>           <none>
kube-system     storage-provisioner                         1/1     Running            0          3h59m   192.168.49.2   minikube       <none>           <none>
*/

--Step 14.1 (Lab)
--In a separate terminal (keep it running):
root@docker-minikube-n01:~# kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80
/*
Forwarding from 127.0.0.1:8080 -> 80
Forwarding from [::1]:8080 -> 80
Handling connection for 8080
Handling connection for 8080
Handling connection for 8080
Handling connection for 8080
*/

--Step 14.2 (Lab)
root@docker-minikube-n01:~# curl -H "Host: frontend.kiranshop.com" http://localhost:8080
/*
<html>
<head><title>503 Service Temporarily Unavailable</title></head>
<body>
<center><h1>503 Service Temporarily Unavailable</h1></center>
<hr><center>nginx</center>
</body>
</html>
*/