--Network Policy: Locking Down the Kirana Shop
--Step 1.0 (Lab)
root@docker-minikube-n01:~# minikube delete --all
/*
* Deleting "minikube" in docker ...
* Removing /root/.minikube/machines/minikube ...
* Removing /root/.minikube/machines/minikube-m02 ...
* Removed all traces of the "minikube" cluster.
* Successfully deleted all profiles
*/

--Step 1.1 (Lab)
--Step 0 — Start the cluster
root@docker-minikube-n01:~# minikube start --nodes 2 --cni=cilium --force
/*
* Successfully deleted all profiles
root@docker-minikube-n01:~# minikube start --nodes 2 --cni=cilium --force
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
* Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
*/

--Step 1.2 (Lab)
--Wait until Cilium is running before you go on:
root@docker-minikube-n01:~# alias k=kubectl
root@docker-minikube-n01:~# k get pods -n kube-system | grep cilium
/*
cilium-b24jf                       1/1     Running   0          3m15s
cilium-envoy-7dws4                 1/1     Running   0          6m10s
cilium-envoy-xswcp                 1/1     Running   0          3m15s
cilium-operator-8dd6995d5-4ls89    1/1     Running   0          6m10s
cilium-r6klm                       1/1     Running   0          6m10s
*/

--Step 2 (Lab)
--Step 1 — Open the shop
root@docker-minikube-n01:~# k create namespace kiranashop
/*
namespace/kiranashop created
*/

--Step 2.1 (Lab)
root@docker-minikube-n01:~# k run frontend --image=wbitt/network-multitool --labels="app=frontend" -n kiranashop \
  --command -- /bin/sh -c "echo 'I am frontend' > /usr/share/nginx/html/index.html && nginx -g 'daemon off;'"
/*
pod/frontend created
*/

--Step 2.2 (Lab)
root@docker-minikube-n01:~# k run backend  --image=wbitt/network-multitool --labels="app=backend"  -n kiranashop \
  --command -- /bin/sh -c "echo 'I am backend' > /usr/share/nginx/html/index.html && nginx -g 'daemon off;'"
/*
pod/backend created
*/

--Step 2.3 (Lab)
root@docker-minikube-n01:~# k run db       --image=wbitt/network-multitool --labels="app=db"        -n kiranashop \
  --command -- /bin/sh -c "echo 'I am DB' > /usr/share/nginx/html/index.html && nginx -g 'daemon off;'"
/*
pod/db created
*/

--Step 2.4 (Lab)
root@docker-minikube-n01:~# k get pods -n kiranashop --show-labels
/*
NAME       READY   STATUS    RESTARTS   AGE   LABELS
backend    1/1     Running   0          87s   app=backend
db         1/1     Running   0          75s   app=db
frontend   1/1     Running   0          95s   app=frontend
*/

--Step 2.4.1 (Lab)
root@docker-minikube-n01:~# k get pods -n kiranashop --show-labels -o wide
/*
NAME       READY   STATUS    RESTARTS   AGE     IP             NODE           NOMINATED NODE   READINESS GATES   LABELS
backend    1/1     Running   0          7m30s   10.244.1.233   minikube-m02   <none>           <none>            app=backend
db         1/1     Running   0          7m18s   10.244.1.186   minikube-m02   <none>           <none>            app=db
frontend   1/1     Running   0          7m38s   10.244.1.62    minikube-m02   <none>           <none>            app=frontend
*/

--Step 2.5 (Lab)
--Now give each part a Service. 
--A Service is like a name plate on the door — instead of remembering changing pod IP addresses, 
--other pods just knock on the door by name (backend, db and frontend).
root@docker-minikube-n01:~# k expose pod frontend --name=frontend --port=80 -n kiranashop
/*
service/frontend exposed
*/

--Step 2.6 (Lab)
root@docker-minikube-n01:~# k expose pod backend --name=backend --port=80 -n kiranashop
/*
service/backend exposed
*/

--Step 2.7 (Lab)
root@docker-minikube-n01:~# k expose pod db --name=db --port=80 -n kiranashop
/*
service/db exposed
*/

--Step 2.8 (Lab)
root@docker-minikube-n01:~# k get svc -n kiranashop
/*
NAME       TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
backend    ClusterIP   10.99.167.31     <none>        80/TCP    4m5s
db         ClusterIP   10.110.127.255   <none>        80/TCP    3m57s
frontend   ClusterIP   10.99.69.245     <none>        80/TCP    4m12s
*/

--Step 2.8.1 (Lab)
root@docker-minikube-n01:~# k get svc -n kiranashop -o wide
/*
NAME       TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE     SELECTOR
backend    ClusterIP   10.99.167.31     <none>        80/TCP    4m9s    app=backend
db         ClusterIP   10.110.127.255   <none>        80/TCP    4m1s    app=db
frontend   ClusterIP   10.99.69.245     <none>        80/TCP    4m16s   app=frontend
*/

--Step 3 (Lab)
--Step 2 — See the problem with your own eyes
--Let's stand inside the frontend pod and knock on the other doors.
--# frontend → frontend  (this is normal and fine)
root@docker-minikube-n01:~# k exec -n kiranashop frontend -- curl -s -m 3 frontend
/*
I am frontend
*/

--Step 3.1 (Lab)
--# frontend → backend  (this is normal and fine)
root@docker-minikube-n01:~# k exec -n kiranashop frontend -- curl -s -m 3 backend
/*
I am backend
*/

--Step 3.2 (Lab)
--# frontend → db  (this should NOT be allowed... but watch)
root@docker-minikube-n01:~# k exec -n kiranashop frontend -- curl -s -m 3 db
/*
I am DB
*/

--Step 4 (Lab)
--Step 3 — Build the first wall: deny everything
--Before we carefully allow the right doors, we slam all doors shut. This is a "default deny" policy — a very common first step in real security work.
--Study this one carefully — it's a worked example. The next two you'll write yourself.
root@docker-minikube-n01:~# vi default-deny.yaml
/*
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: kiranashop
spec:
  podSelector: {}          # {} means "every pod in this namespace"
  policyTypes:
    - Ingress              # we only control traffic coming IN
*/

--Step 4.1 (Lab)
root@docker-minikube-n01:~# k apply -f default-deny.yaml --dry-run=client
/*
networkpolicy.networking.k8s.io/default-deny-ingress created (dry run)
*/

--Step 4.2 (Lab)
root@docker-minikube-n01:~# k apply -f default-deny.yaml
/*
networkpolicy.networking.k8s.io/default-deny-ingress created
*/

--Step 4.3 (Lab)
root@docker-minikube-n01:~# k get netpol -A
/*
NAMESPACE    NAME                   POD-SELECTOR   AGE
kiranashop   default-deny-ingress   <none>         82s
*/

--Step 4.4 (Lab)
root@docker-minikube-n01:~# k get netpol -n kiranashop -o wide
/*
NAME                   POD-SELECTOR   AGE
default-deny-ingress   <none>         74s
*/

--Step 4.5 (Lab)
--Now knock on the doors again:
root@docker-minikube-n01:~# k exec -n kiranashop frontend -- curl -s -m 3 frontend
/*
I am frontend
*/

--Step 4.6 (Lab)
root@docker-minikube-n01:~# k exec -n kiranashop frontend -- curl -s -m 3 backend
/*
command terminated with exit code 28
*/

--Step 4.7 (Lab)
root@docker-minikube-n01:~# k exec -n kiranashop frontend -- curl -s -m 3 db
/*
command terminated with exit code 28
*/

--Step 4.8 (Lab) - Using IP
root@docker-minikube-n01:~# k get pods -n kiranashop -o wide
/*
NAME       READY   STATUS    RESTARTS   AGE   IP             NODE           NOMINATED NODE   READINESS GATES
backend    1/1     Running   0          21m   10.244.1.233   minikube-m02   <none>           <none>
db         1/1     Running   0          20m   10.244.1.186   minikube-m02   <none>           <none>
frontend   1/1     Running   0          21m   10.244.1.62    minikube-m02   <none>           <none>
*/

--Step 4.8.1 (Lab) - Using IP
root@docker-minikube-n01:~# k exec -n kiranashop frontend -- curl http://10.244.1.62 --head
/*
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0    14    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
HTTP/1.1 200 OK
Server: nginx/1.28.0
Date: Thu, 11 Jun 2026 06:37:10 GMT
Content-Type: text/html
Content-Length: 14
Last-Modified: Thu, 11 Jun 2026 06:12:30 GMT
Connection: keep-alive
ETag: "6a2a51ce-e"
Accept-Ranges: bytes
*/

--Step 4.8.2 (Lab) - Using IP
root@docker-minikube-n01:~# k exec -n kiranashop frontend -- curl http://10.244.1.186 --head
/*
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:00:25 --:--:--     0^C
*/

--Step 4.8.3 (Lab) - Using IP
root@docker-minikube-n01:~# k exec -n kiranashop frontend -- curl http://10.244.1.233 --head
/*
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:00:27 --:--:--     0^C
*/

--Step 5 (Lab)
--Step 4 — Your turn: let the frontend talk to the backend
--The shop window needs to reach the shopkeeper. Write a policy that opens only that one door. Fill in the blanks:
root@docker-minikube-n01:~# vi allow-fe-to-be.yaml
/*
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-backend
  namespace: kiranashop
spec:
  podSelector:
    matchLabels:
      app: backend          # which part RECEIVES the knock? => Targeting the backend pod.
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: frontend  # which part is allowed to knock? => Allowing the frontend pod.
      ports:
        - protocol: TCP
          port: 80       # the web page is served on which port? => 80.
*/

--Step 5.1 (Lab)
root@docker-minikube-n01:~# k apply -f allow-fe-to-be.yaml --dry-run=client
/*
networkpolicy.networking.k8s.io/allow-frontend-to-backend created (dry run)
*/

--Step 5.2 (Lab)
root@docker-minikube-n01:~# k apply -f allow-fe-to-be.yaml
/*
networkpolicy.networking.k8s.io/allow-frontend-to-backend created
*/

--Step 5.3 (Lab)
root@docker-minikube-n01:~# k get netpol -n kiranashop -o wide
/*
NAME                        POD-SELECTOR   AGE
allow-frontend-to-backend   app=backend    30s
default-deny-ingress        <none>         17m
*/

--Step 5.4 (Lab)
root@docker-minikube-n01:~# k exec -n kiranashop frontend -- curl -s -m 3 frontend
/*
I am frontend
*/

--Step 5.5 (Lab)
root@docker-minikube-n01:~# k exec -n kiranashop frontend -- curl -s -m 3 backend
/*
I am backend
*/

--Step 5.6 (Lab)
root@docker-minikube-n01:~# k exec -n kiranashop frontend -- curl -s -m 3 db
/*
command terminated with exit code 28
*/

--Step 6 (Lab)
--Step 5 — Your turn again: let the backend talk to the db
--Now the shopkeeper needs to open the safe. Same idea as Step 4. Write allow-backend-to-db.yaml yourself:
--Door to guard: the db pod (top podSelector → app: db)
--Who's allowed in: the backend pod (from.podSelector → app: backend)
--Port: 80
root@docker-minikube-n01:~# vi allow-backend-to-db.yaml
/*
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-backend-to-db
  namespace: kiranashop
spec:
  podSelector:
    matchLabels:
      app: db              # Door to guard: the db pod
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: backend # Who's allowed in: the backend pod
      ports:
        - protocol: TCP
          port: 80         # The port the db pod listens on
*/

--Step 6.1 (Lab)
root@docker-minikube-n01:~# k apply -f allow-backend-to-db.yaml --dry-run=client
/*
networkpolicy.networking.k8s.io/allow-backend-to-db created (dry run)
*/

--Step 6.2 (Lab)
root@docker-minikube-n01:~# k apply -f allow-backend-to-db.yaml
/*
networkpolicy.networking.k8s.io/allow-backend-to-db created
*/

--Step 6.3 (Lab)
root@docker-minikube-n01:~# k get netpol -n kiranashop -o wide
/*
NAME                        POD-SELECTOR   AGE
allow-backend-to-db         app=db         6s
allow-frontend-to-backend   app=backend    11m
default-deny-ingress        <none>         28m
*/

--Step 6.4 (Lab)
root@docker-minikube-n01:~# k exec -n kiranashop backend -- curl -s -m 3 backend
/*
I am backend
*/

--Step 6.5 (Lab)
root@docker-minikube-n01:~# k exec -n kiranashop backend -- curl -s -m 3 db
/*
I am DB
*/

--Step 6.6 (Lab)
root@docker-minikube-n01:~# k exec -n kiranashop backend -- curl -s -m 3 frontend
/*
command terminated with exit code 28
*/

--Step 7 (Lab)
--Step 6 — The big test
--The whole point of today. The shop chain works (frontend → backend → db). But can the shop window still reach into the safe directly?
root@docker-minikube-n01:~# k exec -n kiranashop frontend -- curl -s -m 3 db
/*
command terminated with exit code 28
*/

--Write down what you saw:
|------------------------------------------------|
|Test	            |Should be	   |  What I got |
|-------------------|--------------|-------------|
|frontend → backend | I am backend | I am backend|
|backend → db	    | I am DB 	   | I am DB 	 |
|frontend → db	    | times out    | times out   |
|------------------------------------------------|

--Step 7.1 (Lab)
root@docker-minikube-n01:~# k exec -n kiranashop frontend -- curl -s -m 3 backend
/*
I am backend
*/

--Step 7.2 (Lab)
root@docker-minikube-n01:~# k exec -n kiranashop backend -- curl -s -m 3 db
/*
I am DB
*/

--Step 7.3 (Lab)
root@docker-minikube-n01:~# k exec -n kiranashop frontend -- curl -s -m 3 db
/*
command terminated with exit code 28
*/

--Step 8 (Lab)
--Want more? (optional challenges)
--Q1. Lock the outgoing doors too. Add policyTypes: [Ingress, Egress] to the backend. Something breaks — what? 
--(Hint: the backend can't even look up names anymore. You'll need to allow port 53 to kube-system so DNS works again.)

--A1. When you add Egress to the policyTypes for the backend without defining specific outbound rules, 
--    Kubernetes immediately blocks all outgoing traffic from the backend pod. As a result, CoreDNS resolution 
--    breaks. The backend pod can no longer contact the cluster's DNS server (usually running in the 
--    kube-system namespace) to resolve domain names like db to an IP address.

--The Fix: allow-backend-egress.yaml
--To fix this, you need to allow the backend pod to talk outbound to the db pod and allow outbound UDP/TCP 
--traffic on port 53 to the kube-system namespace for DNS lookups.
--Here is the complete NetworkPolicy to secure the backend's outgoing doors:


--Step 1: Label the Namespaces
--Before writing cross-namespace policies, Kubernetes needs a way to identify the rooms. Make sure your namespaces are labeled so the selectors can find them:
root@docker-minikube-n01:~# k label namespace kiranashop kubernetes.io/metadata.name=kiranashop --overwrite
/*
namespace/kiranashop not labeled
*/

--# Create and label the new database namespace
root@docker-minikube-n01:~# k create namespace kirana-db
/*
namespace/kirana-db created
*/

root@docker-minikube-n01:~# k label namespace kirana-db kubernetes.io/metadata.name=kirana-db
/*
namespace/kirana-db not labeled
*/

--Step 2: The Complete Backend Policy (Ingress + Egress + Cross-Namespace)
--By adding Egress to policyTypes, we lock down all outbound doors. To prevent things from breaking, this manifest explicitly re-opens outbound doors for DNS resolution (Port 53) and the Database (Port 80) in its new namespace.
--Create a file named backend-complete-policy.yaml:

root@docker-minikube-n01:~# vi backend-complete-policy.yaml
/*
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-security-policy
  namespace: kiranashop          # Applied in the backend's room
spec:
  podSelector:
    matchLabels:
      app: backend               # Targets the backend pod
  policyTypes:
    - Ingress
    - Egress

  # --- INBOUND RULES ---
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: frontend      # Only allow the frontend pod (in same NS) to connect
      ports:
        - protocol: TCP
          port: 80            

  # --- OUTBOUND RULES ---
  egress:
    # Challenge 1 Fix: Allow DNS traffic to kube-system so name lookups work
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: kube-system
      ports:
        - protocol: UDP
          port: 53
        - protocol: TCP
          port: 53

    # Challenge 2 Fix: Allow Egress to DB pod inside the NEW namespace
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: kirana-db  # Target the new room
          podSelector:
            matchLabels:
              app: db                                 # and target the DB pod inside it
      ports:
        - protocol: TCP
          port: 80
*/

--Step 8.1 (Lab)
root@docker-minikube-n01:~# k apply -f backend-complete-policy.yaml --dry-run=client
/*
networkpolicy.networking.k8s.io/backend-security-policy created (dry run)
*/

--Step 8.2 (Lab)
root@docker-minikube-n01:~# k apply -f backend-complete-policy.yaml
/*
networkpolicy.networking.k8s.io/backend-security-policy created
*/