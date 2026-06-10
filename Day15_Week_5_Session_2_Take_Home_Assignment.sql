--DNS & Ingress
--Step 1 (Lab)
--Prerequisites
root@minikube-n1:~#  minikube delete --all
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
root@minikube-n1:~# minikube start --nodes 3 --force
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
root@minikube-n1:~# alias k=kubectl
root@minikube-n1:~# k get nodes -o wide
/*
NAME           STATUS   ROLES           AGE     VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE                         KERNEL-VERSION      CONTAINER-RUNTIME
minikube       Ready    control-plane   43m   v1.35.1   192.168.49.2   <none>        Debian GNU/Linux 12 (bookworm)   6.8.0-111-generic   docker://29.2.1
minikube-m02   Ready    <none>          41m   v1.35.1   192.168.49.3   <none>        Debian GNU/Linux 12 (bookworm)   6.8.0-111-generic   docker://29.2.1
minikube-m03   Ready    <none>          39m   v1.35.1   192.168.49.4   <none>        Debian GNU/Linux 12 (bookworm)   6.8.0-111-generic   docker://29.2.1
*/

--Step 1.3 (Lab)
--Enable the Ingress controller
root@minikube-n1:~# minikube addons enable ingress
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
root@minikube-n1:~# k get pods -n ingress-nginx --watch
/*
NAME                                        READY   STATUS      RESTARTS   AGE
ingress-nginx-admission-create-vws57        0/1     Completed   0          86s
ingress-nginx-admission-patch-6j627         0/1     Completed   1          86s
ingress-nginx-controller-596f8778bc-r6dgw   1/1     Running     0          86s
*/

--Step 1.4.1 (Lab)
root@minikube-n1:~# kubectl get pods -n ingress-nginx -o wide
/*
NAME                                        READY   STATUS      RESTARTS   AGE     IP           NODE       NOMINATED NODE   READINESS GATES
ingress-nginx-admission-create-vws57        0/1     Completed   0          94s   10.244.0.4   minikube   <none>           <none>
ingress-nginx-admission-patch-6j627         0/1     Completed   1          94s   10.244.0.3   minikube   <none>           <none>
ingress-nginx-controller-596f8778bc-r6dgw   1/1     Running     0          94s   10.244.0.5   minikube   <none>           <none>
*/

--Part 1 — Build and Publish Container Images
--Step 2 (Lab)
--Step 1 — Create the repositories on DockerHub.
--Go to https://hub.docker.com/repositories/unidev39, 
--create two repositories named kiranashop-backend and kiranashop-frontend, and set both to Public.

--Step 2.1 (Lab)
root@minikube-n1:~# mkdir -p backend/
root@minikube-n1:~# mkdir -p frontend/
root@minikube-n1:~# tree /root/
/*
/root/
├── backend
│   ├── app.py
│   ├── Dockerfile
│   └── requirements.txt
├── frontend
│   ├── app.py
│   ├── Dockerfile
│   └── requirements.txt
*/

--Step 2.2 (Lab)
--Create the Dockerfiles
root@minikube-n1:~# vi backend/Dockerfile
/*
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .
EXPOSE 5000
CMD ["python", "app.py"]
*/

--Step 2.2.1 (Lab)
root@minikube-n1:~# vi backend/app.py
/*
import os
import psycopg2
from flask import Flask, jsonify

app = Flask(__name__)


def get_db():
    return psycopg2.connect(os.environ["DATABASE_URL"])


@app.route("/items")
def items():
    conn = get_db()
    cur = conn.cursor()
    cur.execute("SELECT id, name, category, price FROM items ORDER BY id")
    rows = cur.fetchall()
    cur.close()
    conn.close()
    return jsonify([
        {"id": r[0], "name": r[1], "category": r[2], "price": float(r[3])}
        for r in rows
    ])


@app.route("/health")
def health():
    return "ok"


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
*/

--Step 2.2.2 (Lab)
root@minikube-n1:~# cat backend/requirements.txt
/*
flask
psycopg2-binary
*/

--Step 2.3 (Lab)
--Create the Frontend Dockerfile
root@minikube-n1:~# vi frontend/Dockerfile
/*
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .
EXPOSE 8080
CMD ["python", "app.py"]
*/

--Step 2.3.1 (Lab)
root@minikube-n1:~# vi frontend/app.py
/*
import os
import requests
from flask import Flask

app = Flask(__name__)
BACKEND_URL = os.environ.get("BACKEND_URL", "http://localhost:5000")


@app.route("/")
def index():
    try:
        items = requests.get(f"{BACKEND_URL}/items", timeout=5).json()
    except Exception as e:
        return f"<p>Error connecting to backend: {e}</p>", 500

    rows = "".join(
        f"<tr><td>{i['id']}</td><td>{i['name']}</td><td>{i['category']}</td><td>{i['price']}</td></tr>"
        for i in items
    )
    return f"""<html>
<head><title>KiranaShop</title></head>
<body>
<h2>KiranaShop Items</h2>
<table border="1" cellpadding="8" cellspacing="0">
  <tr><th>ID</th><th>Name</th><th>Category</th><th>Price (NPR)</th></tr>
  {rows}
</table>
</body>
</html>"""


@app.route("/health")
def health():
    return "ok"


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
*/

--Step 2.3.2 (Lab)
root@minikube-n1:~# cat frontend/requirements.txt
/*
flask
requests
*/

--Srep 3 (Lab)
--Step 2 — Log in to DockerHub from your terminal.
root@minikube-n1:~# docker login -u unidev39
/*
i Info → A Personal Access Token (PAT) can be used instead.
         To create a PAT, visit https://app.docker.com/settings


Password:
Login Succeeded
*/

--Srep 4 (Lab) - Docker Build
root@minikube-n1:~# docker build -t unidev39/kiranashop-backend:v1 backend/
/*
[+] Building 44.8s (10/10) FINISHED                                                                                                                                           docker:default
 => [internal] load build definition from Dockerfile                                                                                                                                    0.1s
 => => transferring dockerfile: 200B                                                                                                                                                    0.0s
 => [internal] load metadata for docker.io/library/python:3.12-slim                                                                                                                     0.4s
 => [internal] load .dockerignore                                                                                                                                                       0.0s
 => => transferring context: 2B                                                                                                                                                         0.0s
 => [1/5] FROM docker.io/library/python:3.12-slim@sha256:090ba77e2958f6af52a5341f788b50b032dd4ca28377d2893dcf1ecbdfdfe203                                                              15.7s
 => => resolve docker.io/library/python:3.12-slim@sha256:090ba77e2958f6af52a5341f788b50b032dd4ca28377d2893dcf1ecbdfdfe203                                                               0.1s
 => => sha256:07342fe545e640a2c4960e97ffe33a301cd8e61e0c4d4307d7ac66b6b8a9eb2d 250B / 250B                                                                                              0.8s
 => => sha256:e113665b194b20ba7e9093ef6a1a38edbaebbfb983c00e379a45a142a95a86ef 12.11MB / 12.11MB                                                                                        2.2s
 => => sha256:4a9dde5cdde190bfa0a3ab17863a083e66ea9636b157638c315357dfa476ba76 1.29MB / 1.29MB                                                                                          1.3s
 => => sha256:5b4d6ff92fc4e14e911b7753c954fac965d48c40fe1075758d284148ccace970 29.78MB / 29.78MB                                                                                        3.8s
 => => extracting sha256:5b4d6ff92fc4e14e911b7753c954fac965d48c40fe1075758d284148ccace970                                                                                               7.1s
 => => extracting sha256:4a9dde5cdde190bfa0a3ab17863a083e66ea9636b157638c315357dfa476ba76                                                                                               0.6s
 => => extracting sha256:e113665b194b20ba7e9093ef6a1a38edbaebbfb983c00e379a45a142a95a86ef                                                                                               3.8s
 => => extracting sha256:07342fe545e640a2c4960e97ffe33a301cd8e61e0c4d4307d7ac66b6b8a9eb2d                                                                                               0.0s
 => [internal] load build context                                                                                                                                                       0.1s
 => => transferring context: 717B                                                                                                                                                       0.0s
 => [2/5] WORKDIR /app                                                                                                                                                                  1.5s
 => [3/5] COPY requirements.txt .                                                                                                                                                       0.1s
 => [4/5] RUN pip install --no-cache-dir -r requirements.txt                                                                                                                           17.1s
 => [5/5] COPY app.py .                                                                                                                                                                 0.2s
 => exporting to image                                                                                                                                                                  9.2s
 => => exporting layers                                                                                                                                                                 6.3s
 => => exporting manifest sha256:06b98a6725ad7ca443b78f7b3f4d81ed0748b6a41209f0a53ae1f5739242bf56                                                                                       0.0s
 => => exporting config sha256:42273ad7a6f1e5754bd18762d1d1a9eb645f7c4463d75bee570a27550cbd40c6                                                                                         0.0s
 => => exporting attestation manifest sha256:2e47ac09b5db57a3b95f525cec3be8a9dfccb314904c9e4a38d25951485520e9                                                                           0.1s
 => => exporting manifest list sha256:c2eb14307880382bfcf18f0680b5901c9eff8ba78a24d7b062534453f06a92ef                                                                                  0.0s
 => => naming to docker.io/unidev39/kiranashop-backend:v1                                                                                                                               0.0s
 => => unpacking to docker.io/unidev39/kiranashop-backend:v1                                            
*/

--Srep 4.1 (Lab) - Docker Push
root@minikube-n1:~/backend# docker push unidev39/kiranashop-backend:v1
/*
The push refers to repository [docker.io/unidev39/kiranashop-backend]
5b4d6ff92fc4: Pushed
07342fe545e6: Pushed
71ca6b649792: Pushed
c4c59a7cf5b0: Pushed
721412ed7321: Pushed
71a4cbad6695: Pushed
4a9dde5cdde1: Pushed
0b4f4437fd75: Pushed
e113665b194b: Pushed
v1: digest: sha256:c2eb14307880382bfcf18f0680b5901c9eff8ba78a24d7b062534453f06a92ef size: 856
*/

--Srep 5 (Lab) - Docker Build
root@minikube-n1:~# docker build -t unidev39/kiranashop-frontend:v1 frontend/
/*
[+] Building 22.1s (10/10) FINISHED                                                                                                                                           docker:default
 => [internal] load build definition from Dockerfile                                                                                                                                    0.0s
 => => transferring dockerfile: 200B                                                                                                                                                    0.0s
 => [internal] load metadata for docker.io/library/python:3.12-slim                                                                                                                     1.2s
 => [internal] load .dockerignore                                                                                                                                                       0.0s
 => => transferring context: 2B                                                                                                                                                         0.0s
 => [1/5] FROM docker.io/library/python:3.12-slim@sha256:090ba77e2958f6af52a5341f788b50b032dd4ca28377d2893dcf1ecbdfdfe203                                                               0.1s
 => => resolve docker.io/library/python:3.12-slim@sha256:090ba77e2958f6af52a5341f788b50b032dd4ca28377d2893dcf1ecbdfdfe203                                                               0.1s
 => [internal] load build context                                                                                                                                                       0.1s
 => => transferring context: 969B                                                                                                                                                       0.0s
 => CACHED [2/5] WORKDIR /app                                                                                                                                                           0.0s
 => [3/5] COPY requirements.txt .                                                                                                                                                       0.1s
 => [4/5] RUN pip install --no-cache-dir -r requirements.txt                                                                                                                           14.5s
 => [5/5] COPY app.py .                                                                                                                                                                 0.2s
 => exporting to image                                                                                                                                                                  5.6s
 => => exporting layers                                                                                                                                                                 3.4s
 => => exporting manifest sha256:d9b2c21919f8d0fe7a94140c21dc70eedb506ced5e1c324c46dc28f6bdd7624f                                                                                       0.0s
 => => exporting config sha256:b3987f74c6d6c089a0eff309167c72c1e3911bbfddea1d8170b0b526d045fbe7                                                                                         0.0s
 => => exporting attestation manifest sha256:3393e9b50d23d7a68cbfa39d95cfd80e9dc2b8d8e5d98d5264f76b765eda0122                                                                           0.0s
 => => exporting manifest list sha256:75b3134660f63b99efd98c8371900293ee1a29ff4588554a5fcc1c5d5a7ac6ae                                                                                  0.0s
 => => naming to docker.io/unidev39/kiranashop-frontend:v1                                                                                                                              0.0s
 => => unpacking to docker.io/unidev39/kiranashop-frontend:v1                                  
*/

--Srep 5.1 (Lab) - Docker Push
root@minikube-n1:~# docker push unidev39/kiranashop-frontend:v1
/*
The push refers to repository [docker.io/unidev39/kiranashop-frontend]
74260e5a4da6: Pushed
d9763daa8ea7: Pushed
edc2de5e49fd: Pushed
236e1c978aa7: Pushed
5b4d6ff92fc4: Mounted from unidev39/kiranashop-backend
e113665b194b: Mounted from unidev39/kiranashop-backend
07342fe545e6: Mounted from unidev39/kiranashop-backend
0b4f4437fd75: Mounted from unidev39/kiranashop-backend
4a9dde5cdde1: Mounted from unidev39/kiranashop-backend
v1: digest: sha256:75b3134660f63b99efd98c8371900293ee1a29ff4588554a5fcc1c5d5a7ac6ae size: 856
*/

--Srep 6 (Lab)
root@minikube-n1:~# docker images | grep -i -E "kiranashop"
/*
unidev39/kiranashop-backend:v1  c2eb14307880        214MB         52.6MB
unidev39/kiranashop-frontend:v1 75b3134660f6        202MB         49.2MB                                                                       eed3c13d6099       92.7MB           26MB
*/

--Step 6.1 (Lab)
root@minikube-n1:~# k get pods -A -o wide
/*
NAMESPACE       NAME                                        READY   STATUS      RESTARTS   AGE   IP             NODE           NOMINATED NODE   READINESS GATES
ingress-nginx   ingress-nginx-admission-create-vws57        0/1     Completed   0          32m   10.244.0.4     minikube       <none>           <none>
ingress-nginx   ingress-nginx-admission-patch-6j627         0/1     Completed   1          32m   10.244.0.3     minikube       <none>           <none>
ingress-nginx   ingress-nginx-controller-596f8778bc-r6dgw   1/1     Running     0          32m   10.244.0.5     minikube       <none>           <none>
kube-system     coredns-7d764666f9-jrzbr                    1/1     Running     0          76m   10.244.0.2     minikube       <none>           <none>
kube-system     etcd-minikube                               1/1     Running     0          76m   192.168.49.2   minikube       <none>           <none>
kube-system     kindnet-l28p2                               1/1     Running     0          72m   192.168.49.4   minikube-m03   <none>           <none>
kube-system     kindnet-lpg5x                               1/1     Running     0          76m   192.168.49.2   minikube       <none>           <none>
kube-system     kindnet-n2dwl                               1/1     Running     0          74m   192.168.49.3   minikube-m02   <none>           <none>
kube-system     kube-apiserver-minikube                     1/1     Running     0          76m   192.168.49.2   minikube       <none>           <none>
kube-system     kube-controller-manager-minikube            1/1     Running     0          76m   192.168.49.2   minikube       <none>           <none>
kube-system     kube-proxy-5t576                            1/1     Running     0          72m   192.168.49.4   minikube-m03   <none>           <none>
kube-system     kube-proxy-rn4f9                            1/1     Running     0          76m   192.168.49.2   minikube       <none>           <none>
kube-system     kube-proxy-xzqtj                            1/1     Running     0          74m   192.168.49.3   minikube-m02   <none>           <none>
kube-system     kube-scheduler-minikube                     1/1     Running     0          76m   192.168.49.2   minikube       <none>           <none>
kube-system     storage-provisioner                         1/1     Running     0          76m   192.168.49.2   minikube       <none>           <none>
*/

--Step 6.2 (Lab)
--Knowledge check
--Q1. True or False: Kubernetes pulls container images at the time the Deployment is created, not when individual pods are scheduled.
--A1. False

--Q2: A pod is stuck in ImagePullBackOff. What does this indicate?
--A2: Not Seen

--Step 7 (Lab)
--Part 2 — Deploy PostgreSQL as a StatefulSet
root@minikube-n1:~# vi postgres-statefulset.yaml
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
root@minikube-n1:~# k apply -f postgres-statefulset.yaml --dry-run=client
/*
service/postgres created (dry run)
statefulset.apps/postgres created (dry run)
*/

--Step 7.2 (Lab)
root@minikube-n1:~# k apply -f postgres-statefulset.yaml
/*
service/postgres created
statefulset.apps/postgres created
*/

--Step 7.3 (Lab)
root@minikube-n1:~# k get statefulset postgres
/*
NAME       READY   AGE
postgres   0/1     53s
*/

--Step 7.3.1 (Lab)
root@minikube-n1:~# k get statefulset postgres -o wide
/*
NAME       READY   AGE   CONTAINERS   IMAGES
postgres   0/1     83s   postgres     postgres:15
*/

--Step 7.4 (Lab)
root@minikube-n1:~# k get pods -l app=postgres --watch
/*
NAME         READY   STATUS   RESTARTS        AGE
postgres-0   0/1     Error    4 (2m16s ago)   3m46s
postgres-0   0/1     CrashLoopBackOff   4 (84s ago)     3m47s
postgres-0   0/1     Error              5 (85s ago)     3m48s
*/

--Step 7.4.1 (Lab)
root@minikube-n1:~# k get pods -l app=postgres -o wide
/*
NAME         READY   STATUS             RESTARTS      AGE     IP           NODE           NOMINATED NODE   READINESS GATES
postgres-0   0/1     CrashLoopBackOff   5 (98s ago)   5m25s   10.244.2.2   minikube-m03   <none>           <none>
*/

-- Note: postgres-0 in CrashLoopBackOff — this is expected because we haven't set the password yet.

--Step 7.5 (Lab)
--Knowledge check
--Q1: True or False: StatefulSet pod names are randomly generated, just like Deployment pods.
--A1: False

--Q2: What is the name of the pod created by a StatefulSet named postgres for its first replica?
--A2: postgres-0

--Step 8 (Lab)
--Part 3 — Secrets Management
root@minikube-n1:~# k create secret generic db-secret \
  --from-literal=POSTGRES_PASSWORD=Passw0rD \
  --from-literal=POSTGRES_DB=kiranashop \
  --from-literal=DATABASE_URL=postgresql://postgres:Passw0rD@postgres:5432/kiranashop
/*
secret/db-secret created
*/

--Step 8.1 (Lab)
root@minikube-n1:~# k get secret db-secret -o yaml > db-secret.yaml

--Step 8.1.1 (Lab)
root@minikube-n1:~# cat db-secret.yaml
/*
apiVersion: v1
data:
  DATABASE_URL: cG9zdGdyZXNxbDovL3Bvc3RncmVzOlBhc3N3MHJEQHBvc3RncmVzOjU0MzIva2lyYW5hc2hvcA==
  POSTGRES_DB: a2lyYW5hc2hvcA==
  POSTGRES_PASSWORD: UGFzc3cwckQ=
kind: Secret
metadata:
  creationTimestamp: "2026-06-10T09:23:53Z"
  name: db-secret
  namespace: default
  resourceVersion: "6076"
  uid: 742bd93e-be4e-4969-9419-7f49cb3ea392
type: Opaque
*/

--Step 8.1.2 (Lab)
root@minikube-n1:~# k describe secret db-secret
/*
Name:         db-secret
Namespace:    default
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====
DATABASE_URL:       55 bytes
POSTGRES_DB:        10 bytes
POSTGRES_PASSWORD:  8 bytes
*/

--Step 8.2 (Lab) -- add an envFrom block inside the container spec
root@minikube-n1:~# vi postgres-statefulset.yaml
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
root@minikube-n1:~# k apply -f postgres-statefulset.yaml --dry-run=client
/*
service/postgres unchanged (dry run)
statefulset.apps/postgres configured (dry run)
*/

--Step 8.4 (Lab)
root@minikube-n1:~# k apply -f postgres-statefulset.yaml
/*
service/postgres unchanged
statefulset.apps/postgres configured
*/

--Step 8.5 (Lab)
root@minikube-n1:~# k get statefulset postgres -o wide
/*
NAME       READY   AGE   CONTAINERS   IMAGES
postgres   0/1     19m   postgres     postgres:15
*/

--Step 8.6 (Lab)
root@minikube-n1:~# k get pods -l app=postgres -o wide
/*
NAME         READY   STATUS             RESTARTS        AGE   IP           NODE           NOMINATED NODE   READINESS GATES
postgres-0   0/1     CrashLoopBackOff   6 (4m34s ago)   11m   10.244.2.2   minikube-m03   <none>           <none>
*/

--Step 8.7 (Lab)
root@minikube-n1:~# k delete pod postgres-0
/*
pod "postgres-0" deleted from default namespace
*/

--Step 8.8 (Lab)
--The StatefulSet controller will recreate postgres-0 right away. Wait for it to become ready:
root@minikube-n1:~# k rollout status statefulset/postgres
/*
partitioned roll out complete: 1 new pods have been updated...
*/

--Step 8.9 (Lab)
root@minikube-n1:~# k get statefulset postgres
/*
NAME       READY   AGE
postgres   1/1     23m
*/

--Step 8.10 (Lab)
root@minikube-n1:~# k get statefulset postgres -o wide
/*
NAME       READY   AGE   CONTAINERS   IMAGES
postgres   1/1     23m   postgres     postgres:15
*/

--Step 8.11 (Lab)
root@minikube-n1:~# k get pods -l app=postgres -o wide
/*
NAME         READY   STATUS    RESTARTS   AGE   IP           NODE           NOMINATED NODE   READINESS GATES
postgres-0   1/1     Running   0          42s   10.244.1.3   minikube-m02   <none>           <none>
*/

--Step 8.12 (Lab)
--Knowledge check
--Q1. True or False: Kubernetes Secrets store values in plain text inside the cluster etcd database.
--A1. False 

--Q2. What envFrom field type injects all keys from a Secret as environment variables into a container?
--A2. secretRef

--Step 9 (Lab)
--Part 4 — Database Initialisation
root@minikube-n1:~# k exec -it postgres-0 -- psql -U postgres -d kiranashop
/*
psql (15.18 (Debian 15.18-1.pgdg13+1))
Type "help" for help.

kiranashop=# CREATE TABLE items (
    id       SERIAL PRIMARY KEY,
    name     VARCHAR(100),
    category VARCHAR(50),
    price    NUMERIC(10,2)
);
CREATE TABLE
kiranashop=# INSERT INTO items (name, category, price) VALUES
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
kiranashop=# SELECT * FROM items;
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

kiranashop=# \q
*/

--Step 9.1 (Lab)
--Knowledge check
--Q1. True or False: kubectl exec works on any pod, regardless of whether it was created by a Deployment or a StatefulSet. 
--A1. True
--Q2. What is the benefit of a StatefulSet that allowed you to run kubectl exec -it postgres-0 directly, without first running kubectl get pods?
--A2. Predictable and stable pod naming

--Step 10 (Lab)
--Part 5 — Deploy the Backend Service
root@minikube-n1:~# k create deployment kiranashop-backend \
  --image=unidev39/kiranashop-backend:v1 \
  --replicas=2 \
  --dry-run=client -o yaml
/*
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: kiranashop-backend
  name: kiranashop-backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: kiranashop-backend
  strategy: {}
  template:
    metadata:
      labels:
        app: kiranashop-backend
    spec:
      containers:
      - image: unidev39/kiranashop-backend:v1
        name: kiranashop-backend
        resources: {}
status: {}
*/

--Step 10.1 (Lab)
root@minikube-n1:~# k create deployment kiranashop-backend \
  --image=unidev39/kiranashop-backend:v1 \
  --replicas=2 \
  --dry-run=client -o yaml > backend-deployment.yaml

--Step 10.2 (Lab)
--Open backend-deployment.yaml. Make two additions under spec.template.spec — note that this is spec.template.spec, not spec.template.metadata:
--1. Add a DATABASE_URL environment variable from the Secret:
--Under spec.template.spec.containers[0], add an env entry that reads DATABASE_URL from db-secret using valueFrom.secretKeyRef.
--2. Add pod anti-affinity:
--Under spec.template.spec, add an affinity.podAntiAffinity block using preferredDuringSchedulingIgnoredDuringExecution with topologyKey: kubernetes.io/hostname. 
--The labelSelector should match pods with label app: kiranashop-backend.
root@minikube-n1:~# vi backend-deployment.yaml
/*
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: kiranashop-backend
  name: kiranashop-backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: kiranashop-backend
  strategy: {}
  template:
    metadata:
      labels:
        app: kiranashop-backend
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
                        - kiranashop-backend
                topologyKey: kubernetes.io/hostname
      containers:
        - image: unidev39/kiranashop-backend:v1
          name: kiranashop-backend
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
root@minikube-n1:~# k apply -f backend-deployment.yaml --dry-run=client
/*
deployment.apps/kiranashop-backend created (dry run)
*/

--Step 10.4 (Lab)
root@minikube-n1:~# k apply -f backend-deployment.yaml
/*
deployment.apps/kiranashop-backend created
*/

--Step 10.5 (Lab)
root@minikube-n1:~# k rollout status deployment/kiranashop-backend
/*
Waiting for deployment "kiranashop-backend" rollout to finish: 0 of 2 updated replicas are available...
Waiting for deployment "kiranashop-backend" rollout to finish: 1 of 2 updated replicas are available...
deployment "kiranashop-backend" successfully rolled out
*/

--Step 10.5.1 (Lab)
root@minikube-n1:~# k get deploy -o wide
/*
NAME                 READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS           IMAGES                           SELECTOR
kiranashop-backend   2/2     2            2           2m10s   kiranashop-backend   unidev39/kiranashop-backend:v1   app=kiranashop-backend
*/

--Step 10.5.2 (Lab)
root@minikube-n1:~# k get pods -o wide
/*
NAME                                  READY   STATUS    RESTARTS   AGE   IP           NODE           NOMINATED NODE   READINESS GATES
kiranashop-backend-7c8c559bf4-6tq67   1/1     Running   0          3m    10.244.2.4   minikube-m03   <none>           <none>
kiranashop-backend-7c8c559bf4-vhfsg   1/1     Running   0          3m    10.244.1.2   minikube-m02   <none>           <none>
postgres-0                            1/1     Running   0          13m   10.244.2.3   minikube-m03   <none>           <none>
*/

--Step 10.6 (Lab)
root@minikube-n1:~# k expose deployment kiranashop-backend --port=5000 --target-port=5000
/*
service/kiranashop-backend exposed
*/

--Step 10.7 (Lab)
root@minikube-n1:~# k get service kiranashop-backend -o yaml > backend-service.yaml

--Step 10.7.1 (Lab)
root@minikube-n1:~# cat backend-service.yaml
/*
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: "2026-06-10T09:42:40Z"
  labels:
    app: kiranashop-backend
  name: kiranashop-backend
  namespace: default
  resourceVersion: "7412"
  uid: fc100c37-d174-4609-8648-5c39f5038596
spec:
  clusterIP: 10.99.95.164
  clusterIPs:
  - 10.99.95.164
  internalTrafficPolicy: Cluster
  ipFamilies:
  - IPv4
  ipFamilyPolicy: SingleStack
  ports:
  - port: 5000
    protocol: TCP
    targetPort: 5000
  selector:
    app: kiranashop-backend
  sessionAffinity: None
  type: ClusterIP
status:
  loadBalancer: {}
*/

--Step 10.8 (Lab)
root@minikube-n1:~# k get svc kiranashop-backend -o wide
/*
NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE   SELECTOR
kiranashop-backend   ClusterIP   10.99.95.164   <none>        5000/TCP   71s   app=kiranashop-backend
*/

--Step 10.8.1 (Lab)
root@minikube-n1:~# k get svc  -o wide
/*
NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE    SELECTOR
kiranashop-backend   ClusterIP   10.99.95.164   <none>        5000/TCP   89s    app=kiranashop-backend
kubernetes           ClusterIP   10.96.0.1      <none>        443/TCP    105m   <none>
postgres             ClusterIP   None           <none>        5432/TCP   27m    app=postgres
*/

--Step 10.8.2 (Lab)
root@minikube-n1:~# k get pods -o wide -l app=kiranashop-backend
/*
NAME                                  READY   STATUS    RESTARTS   AGE    IP           NODE           NOMINATED NODE   READINESS GATES
kiranashop-backend-7c8c559bf4-6tq67   1/1     Running   0          6m4s   10.244.2.4   minikube-m03   <none>           <none>
kiranashop-backend-7c8c559bf4-vhfsg   1/1     Running   0          6m4s   10.244.1.2   minikube-m02   <none>           <none>
*/

--Step 10.9 (Lab)
root@minikube-n1:~# k get endpoints kiranashop-backend -o wide
/*
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME                 ENDPOINTS                         AGE
kiranashop-backend   10.244.1.2:5000,10.244.2.4:5000   3m42s
*/

root@minikube-n1:~#  k get endpoints -o wide
/*
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME                 ENDPOINTS                         AGE
kiranashop-backend   10.244.1.2:5000,10.244.2.4:5000   3m59s
kubernetes           192.168.49.2:8443                 108m
postgres             10.244.2.3:5432                   30m
*/

--Step 10.10 (Lab)
--Knowledge check
--Q1. True or False: preferredDuringSchedulingIgnoredDuringExecution will block pod scheduling if it cannot place pods on separate nodes.
--A1. False
--Q2. In a Deployment manifest, is the affinity block placed under spec.template.metadata or spec.template.spec?
--A2. spec.template.spec

--Step 11 (Lab)
--Part 6 — Frontend Configuration
root@minikube-n1:~# cat frontend/app.py | grep -i -E "BACKEND_URL "
/*
BACKEND_URL = os.environ.get("BACKEND_URL", "http://localhost:5000")
*/

--Step 11.1 (Lab)
root@minikube-n1:~# k create configmap frontend-config \
 --from-literal=BACKEND_URL=http://kiranashop-backend:5000
/*
configmap/frontend-config created
*/

--Step 11.2 (Lab)
root@minikube-n1:~# k get configmap frontend-config
/*
NAME              DATA   AGE
frontend-config   1      19s
*/

--Step 11.3 (Lab)
root@minikube-n1:~# k describe configmap frontend-config
/*
Name:         frontend-config
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
BACKEND_URL:
----
http://kiranashop-backend:5000


BinaryData
====

Events:  <none>
*/

--Step 11.4 (Lab)
root@minikube-n1:~# k get configmap frontend-config -o yaml > frontend-configmap.yaml
root@minikube-n1:~# cat frontend-configmap.yaml
/*
apiVersion: v1
data:
  BACKEND_URL: http://kiranashop-backend:5000
kind: ConfigMap
metadata:
  creationTimestamp: "2026-06-10T09:53:20Z"
  name: frontend-config
  namespace: default
  resourceVersion: "8137"
  uid: dd58a4c5-5016-4246-b263-e693d92ac066
*/

--Step 11.5 (Lab)
root@minikube-n1:~# k get configmap -o wide
/*
NAME               DATA   AGE
frontend-config    1      3m25s
kube-root-ca.crt   1      118m
*/

--Step 11.6 (Lab)
root@minikube-n1:~# k get cm -o wide
/*
NAME               DATA   AGE
frontend-config    1      4m
kube-root-ca.crt   1      118m
*/

--Step 11.7 (Lab)
--Knowledge check
--Q1. True or False: A ConfigMap is the appropriate place to store a database password.
--A1. FALSE
--Q2. Why is the backend URL stored in a ConfigMap rather than a Secret?
--A2. Because the backend URL is non-sensitive configuration data.

--Step 12 (Lab)
--Part 7 — Deploy the Frontend Service
root@minikube-n1:~# k create deployment kiranashop-frontend \
  --image=unidev39/kiranashop-frontend:v1 \
  --replicas=2 \
  --dry-run=client -o yaml
/*
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: kiranashop-frontend
  name: kiranashop-frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: kiranashop-frontend
  strategy: {}
  template:
    metadata:
      labels:
        app: kiranashop-frontend
    spec:
      containers:
      - image: unidev39/kiranashop-frontend:v1
        name: kiranashop-frontend
        resources: {}
status: {}
*/

--Step 12.1 (Lab)
root@minikube-n1:~# k create deployment kiranashop-frontend \
  --image=unidev39/kiranashop-frontend:v1 \
  --replicas=2 \
  --dry-run=client -o yaml > frontend-deployment.yaml

--Step 12.2 (Lab)
--Open frontend-deployment.yaml and make two additions under spec.template.spec:
--1. Inject all keys from the ConfigMap as environment variables:
--Under spec.template.spec.containers[0], add an envFrom entry using configMapRef pointing to frontend-config.
--2. Add pod anti-affinity:
--Same pattern as Part 5. Add the affinity.podAntiAffinity block under spec.template.spec. Change the matchLabels.app value to kiranashop-frontend.
root@minikube-n1:~# vi frontend-deployment.yaml
/*
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: kiranashop-frontend
  name: kiranashop-frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: kiranashop-frontend
  strategy: {}
  template:
    metadata:
      labels:
        app: kiranashop-frontend
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
                        - kiranashop-frontend
                topologyKey: kubernetes.io/hostname
      containers:
        - image: unidev39/kiranashop-frontend:v1
          name: kiranashop-frontend
          ports:
            - containerPort: 8080
          envFrom:
            - configMapRef:
                name: frontend-config
          resources: {}
status: {}
*/

--Step 12.3 (Lab)
root@minikube-n1:~# k apply -f frontend-deployment.yaml --dry-run=client
/*
deployment.apps/kiranashop-frontend created (dry run)
*/

--Step 12.4 (Lab)
root@minikube-n1:~# k apply -f frontend-deployment.yaml
/*
deployment.apps/kiranashop-frontend created
*/

--Step 12.5 (Lab)
root@minikube-n1:~# k rollout status deployment/kiranashop-frontend
/*
Waiting for deployment "kiranashop-frontend" rollout to finish: 0 of 2 updated replicas are available...
Waiting for deployment "kiranashop-frontend" rollout to finish: 1 of 2 updated replicas are available...
deployment "kiranashop-frontend" successfully rolled out
*/

--Step 12.6 (Lab)
root@minikube-n1:~# k get pods -o wide
/*
NAME                                   READY   STATUS    RESTARTS   AGE   IP           NODE           NOMINATED NODE   READINESS GATES
kiranashop-backend-7c8c559bf4-6tq67    1/1     Running   0          25m   10.244.2.4   minikube-m03   <none>           <none>
kiranashop-backend-7c8c559bf4-vhfsg    1/1     Running   0          25m   10.244.1.2   minikube-m02   <none>           <none>
kiranashop-frontend-6d64554f84-4cwj8   1/1     Running   0          38s   10.244.2.5   minikube-m03   <none>           <none>
kiranashop-frontend-6d64554f84-ktt8h   1/1     Running   0          38s   10.244.1.3   minikube-m02   <none>           <none>
postgres-0                             1/1     Running   0          36m   10.244.2.3   minikube-m03   <none>           <none>
*/

--Step 12.7 (Lab)
root@minikube-n1:~# k get deploy -o wide
/*
NAME                  READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS            IMAGES                            SELECTOR
kiranashop-backend    2/2     2            2           26m   kiranashop-backend    unidev39/kiranashop-backend:v1    app=kiranashop-backend
kiranashop-frontend   2/2     2            2           82s   kiranashop-frontend   unidev39/kiranashop-frontend:v1   app=kiranashop-frontend
*/

--Step 12.8 (Lab)
root@minikube-n1:~# k get pods -o wide -l app=kiranashop-frontend
/*
NAME                                   READY   STATUS    RESTARTS   AGE    IP           NODE           NOMINATED NODE   READINESS GATES
kiranashop-frontend-6d64554f84-4cwj8   1/1     Running   0          109s   10.244.2.5   minikube-m03   <none>           <none>
kiranashop-frontend-6d64554f84-ktt8h   1/1     Running   0          109s   10.244.1.3   minikube-m02   <none>           <none>
*/

--Step 12.9 (Lab)
--Expose it as a ClusterIP Service on port 8080:
root@minikube-n1:~# k expose deployment kiranashop-frontend --port=8080 --target-port=8080
/*
service/kiranashop-frontend exposed
*/

--Step 12.10 (Lab)
root@minikube-n1:~# k get service kiranashop-frontend -o yaml > frontend-service.yaml

--Step 12.10.1 (Lab)
root@minikube-n1:~# cat frontend-service.yaml
/*
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: "2026-06-10T10:10:40Z"
  labels:
    app: kiranashop-frontend
  name: kiranashop-frontend
  namespace: default
  resourceVersion: "9344"
  uid: e14dfa0f-829b-42a1-9369-9e074e5dfd48
spec:
  clusterIP: 10.102.15.42
  clusterIPs:
  - 10.102.15.42
  internalTrafficPolicy: Cluster
  ipFamilies:
  - IPv4
  ipFamilyPolicy: SingleStack
  ports:
  - port: 8080
    protocol: TCP
    targetPort: 8080
  selector:
    app: kiranashop-frontend
  sessionAffinity: None
  type: ClusterIP
status:
  loadBalancer: {}
*/

--Step 12.11 (Lab)
root@minikube-n1:~# k get svc -o wide
/*
NAME                  TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE     SELECTOR
kiranashop-backend    ClusterIP   10.99.95.164   <none>        5000/TCP   30m     app=kiranashop-backend
kiranashop-frontend   ClusterIP   10.102.15.42   <none>        8080/TCP   2m11s   app=kiranashop-frontend
kubernetes            ClusterIP   10.96.0.1      <none>        443/TCP    134m    <none>
postgres              ClusterIP   None           <none>        5432/TCP   56m     app=postgres
*/

--Step 12.12 (Lab)
root@minikube-n1:~# k get pods -o wide
/*
NAME                                   READY   STATUS    RESTARTS   AGE     IP           NODE           NOMINATED NODE   READINESS GATES
kiranashop-backend-7c8c559bf4-6tq67    1/1     Running   0          34m     10.244.2.4   minikube-m03   <none>           <none>
kiranashop-backend-7c8c559bf4-vhfsg    1/1     Running   0          34m     10.244.1.2   minikube-m02   <none>           <none>
kiranashop-frontend-6d64554f84-4cwj8   1/1     Running   0          9m37s   10.244.2.5   minikube-m03   <none>           <none>
kiranashop-frontend-6d64554f84-ktt8h   1/1     Running   0          9m37s   10.244.1.3   minikube-m02   <none>           <none>
postgres-0                             1/1     Running   0          45m     10.244.2.3   minikube-m03   <none>           <none>
*/

--Step 12.13 (Lab)
--Knowledge check
--Q1. True or False: envFrom.configMapRef injects only specific keys from a ConfigMap — you must list each key individually.
--A1. False
--Q2. The frontend connects to the backend using http://kiranashop-backend:5000. What Kubernetes feature makes kiranashop-backend resolvable as a hostname inside the cluster?
--A2. Kubernetes DNS (Kubernetes - dns / CoreDNS)


--Step 13 (Lab)
--Part 8 — Ingress Routing
root@minikube-n1:~# k create ingress kiranashop --class=nginx --rule="frontend.kiranashop.com/*=kiranashop-frontend:8080"
/*
ingress.networking.k8s.io/kiranashop created
*/

--Step 13.1 (Lab)
root@minikube-n1:~# k get ingress kiranashop -o wide
/*
NAME         CLASS   HOSTS                     ADDRESS        PORTS   AGE
kiranashop   nginx   frontend.kiranashop.com   192.168.49.2   80      46s
*/

--Step 13.2 (Lab)
root@minikube-n1:~# k get ingress kiranashop -o yaml > ingress.yaml

--Step 13.3 (Lab)
root@minikube-n1:~# cat ingress.yaml
/*
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  creationTimestamp: "2026-06-10T10:18:20Z"
  generation: 1
  name: kiranashop
  namespace: default
  resourceVersion: "9874"
  uid: cb1015e8-67ba-40b5-a900-cd5fd3054798
spec:
  ingressClassName: nginx
  rules:
  - host: frontend.kiranashop.com
    http:
      paths:
      - backend:
          service:
            name: kiranashop-frontend
            port:
              number: 8080
        path: /
        pathType: Prefix
status:
  loadBalancer:
    ingress:
    - ip: 192.168.49.2
*/

--Step 13.4 (Lab)
--Knowledge check
--Q1. True or False: An Ingress resource works without an Ingress controller deployed in the cluster.
--A1. False
--Q2. What HTTP header does an Ingress rule host field match against in an incoming request? 
--A2. The Host header (host: frontend.kiranashop.com)

--Step 14 (Lab)
--Part 9 — End-to-End Validation
root@minikube-n1:~# k get pods -o wide
/*
NAME                                   READY   STATUS    RESTARTS   AGE   IP           NODE           NOMINATED NODE   READINESS GATES
kiranashop-backend-7c8c559bf4-6tq67    1/1     Running   0          45m   10.244.2.4   minikube-m03   <none>           <none>
kiranashop-backend-7c8c559bf4-vhfsg    1/1     Running   0          45m   10.244.1.2   minikube-m02   <none>           <none>
kiranashop-frontend-6d64554f84-4cwj8   1/1     Running   0          20m   10.244.2.5   minikube-m03   <none>           <none>
kiranashop-frontend-6d64554f84-ktt8h   1/1     Running   0          20m   10.244.1.3   minikube-m02   <none>           <none>
postgres-0                             1/1     Running   0          56m   10.244.2.3   minikube-m03   <none>           <none>
*/

--Step 14.1 (Lab)
--In a separate terminal (keep it running):
root@minikube-n1:~# alias k=kubectl
root@minikube-n1:~# k port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80
/*
Forwarding from 127.0.0.1:8080 -> 80
Forwarding from [::1]:8080 -> 80
Handling connection for 8080
*/

--Step 14.2 (Lab)
root@minikube-n1:~# curl -H "Host: frontend.kiranashop.com" http://localhost:8080
/*
<html>
<head><title>KiranaShop</title></head>
<body>
<h2>KiranaShop Items</h2>
<table border="1" cellpadding="8" cellspacing="0">
  <tr><th>ID</th><th>Name</th><th>Category</th><th>Price (NPR)</th></tr>
  <tr><td>1</td><td>Rice (1kg)</td><td>Grain</td><td>120.0</td></tr><tr><td>2</td><td>Lentils (500g)</td><td>Grain</td><td>95.0</td></tr><tr><td>3</td><td>Mustard Oil (1L)</td><td>Oil</td><td>280.0</td></tr><tr><td>4</td><td>Salt (1kg)</td><td>Spice</td><td>25.0</td></tr><tr><td>5</td><td>Sugar (1kg)</td><td>Sweetener</td><td>85.0</td></tr><tr><td>6</td><td>Tea Leaves (250g)</td><td>Beverage</td><td>150.0</td></tr><tr><td>7</td><td>Wheat Flour (1kg)</td><td>Grain</td><td>65.0</td></tr><tr><td>8</td><td>Milk (1L)</td><td>Dairy</td><td>110.0</td></tr><tr><td>9</td><td>Onion (1kg)</td><td>Vegetable</td><td>60.0</td></tr><tr><td>10</td><td>Potato (1kg)</td><td>Vegetable</td><td>45.0</td></tr>
</table>
</body>
*/

--Step 15 (Lab)
--Optional: validate the backend API directly
--Step 15.1 (Lab)
--In a separate terminal (keep it running):
root@minikube-n1:~# alias k=kubectl
root@minikube-n1:~# k port-forward svc/kiranashop-backend 5000:5000
/*
Forwarding from 127.0.0.1:5000 -> 5000
Forwarding from [::1]:5000 -> 5000
Handling connection for 5000
Handling connection for 5000
*/

--Step 15.2 (Lab)
root@minikube-n1:~# curl http://localhost:5000/items
/*
[{"category":"Grain","id":1,"name":"Rice (1kg)","price":120.0},{"category":"Grain","id":2,"name":"Lentils (500g)","price":95.0},{"category":"Oil","id":3,"name":"Mustard Oil (1L)","price":280.0},{"category":"Spice","id":4,"name":"Salt (1kg)","price":25.0},{"category":"Sweetener","id":5,"name":"Sugar (1kg)","price":85.0},{"category":"Beverage","id":6,"name":"Tea Leaves (250g)","price":150.0},{"category":"Grain","id":7,"name":"Wheat Flour (1kg)","price":65.0},{"category":"Dairy","id":8,"name":"Milk (1L)","price":110.0},{"category":"Vegetable","id":9,"name":"Onion (1kg)","price":60.0},{"category":"Vegetable","id":10,"name":"Potato (1kg)","price":45.0}]
*/
