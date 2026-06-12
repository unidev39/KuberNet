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
--1.Lock the outgoing doors too. Add policyTypes: [Ingress, Egress] to the backend. Something breaks — what? (Hint: the backend can't even look up names anymore. You'll need to allow port 53 to kube-system so DNS works again.)
--2.Move the safe to another room. Put db in its own namespace. Why does your podSelector-only rule stop working? (Hint: you now also need a namespaceSelector.)
--3.Peek under the hood. See how Cilium tracks each pod: kubectl exec -n kube-system <cilium-pod> -- cilium endpoint list

--Steps 1 and 2 : The Complete Backend Policy (Ingress + Egress + Cross-Namespace)
--By adding Egress to policyTypes, we lock down all outbound doors. To prevent things from breaking, this manifest explicitly re-opens outbound doors for DNS resolution (Port 53) and the Database (Port 80) in its new namespace.
--Create a file named backend-complete-policy.yaml:

--Step 8.1 (Lab)
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

--Step 8.2 (Lab)
root@docker-minikube-n01:~# k apply -f backend-complete-policy.yaml --dry-run=client
/*
networkpolicy.networking.k8s.io/backend-security-policy created (dry run)
*/

--Step 8.3 (Lab)
root@docker-minikube-n01:~# k apply -f backend-complete-policy.yaml
/*
networkpolicy.networking.k8s.io/backend-security-policy created
*/

--Step 8.4 (Lab)
root@docker-minikube-n01:~# k get netpol -A
/*
NAMESPACE    NAME                        POD-SELECTOR   AGE
kiranashop   allow-backend-to-db         app=db         24h
kiranashop   allow-frontend-to-backend   app=backend    24h
kiranashop   backend-security-policy     app=backend    156m
kiranashop   default-deny-ingress        <none>         24h
*/

--Step 8.5 (Lab)
root@docker-minikube-n01:~# k exec -n kiranashop backend -- nslookup db.kirana-db
/*
;; Got recursion not available from 10.96.0.10
;; Got recursion not available from 10.96.0.10
Server:         10.96.0.10
Address:        10.96.0.10#53

Name:   db.kirana-db.svc.cluster.local
Address: 10.96.94.223
;; Got recursion not available from 10.96.0.10
*/

--Step 8.6 (Lab)
root@docker-minikube-n01:~# k exec -n kiranashop backend -- curl -s -m 3 db
/*
command terminated with exit code 28
*/

--Step 8.7 (Lab)
root@docker-minikube-n01:~# k get netpol -A -o wide
/*
NAMESPACE    NAME                        POD-SELECTOR   AGE
kiranashop   allow-backend-to-db         app=db         24h
kiranashop   allow-frontend-to-backend   app=backend    24h
kiranashop   backend-security-policy     app=backend    163m
kiranashop   default-deny-ingress        <none>         25h
*/

--Step 8.8 (Lab)
root@docker-minikube-n01:~# k describe -n kiranashop netpol backend-security-policy
/*
Name:         backend-security-policy
Namespace:    kiranashop
Created on:   2026-06-12 10:32:38 +0545 +0545
Labels:       <none>
Annotations:  <none>
Spec:
  PodSelector:     app=backend
  Allowing ingress traffic:
    To Port: 8080/TCP
    From:
      PodSelector: app=frontend
  Allowing egress traffic:
    To Port: 53/UDP
    To Port: 53/TCP
    To:
      NamespaceSelector: kubernetes.io/metadata.name=kube-system
    ----------
    To Port: 80/TCP
    To:
      NamespaceSelector: kubernetes.io/metadata.name=kirana-db
      PodSelector: app=db
  Policy Types: Ingress, Egress
*/

--Step 8.9 (Lab)
root@docker-minikube-n01:~# k get pod -n kiranashop db -o yaml > db-pod.yaml

--Step 8.10 (Lab)
-- NameSpace From kiranashop to kirana-db
root@docker-minikube-n01:~# vi db-pod.yaml
/*
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: "2026-06-11T06:12:04Z"
  generation: 1
  labels:
    app: db
  name: db
  namespace: kirana-db
  resourceVersion: "1436"
  uid: 48d8221d-6f84-4d87-afef-19d54493a7a1
spec:
  containers:
  - command:
    - /bin/sh
    - -c
    - echo 'I am DB' > /usr/share/nginx/html/index.html && nginx -g 'daemon off;'
    image: wbitt/network-multitool
    imagePullPolicy: Always
    name: db
    resources: {}
    terminationMessagePath: /dev/termination-log
    terminationMessagePolicy: File
    volumeMounts:
    - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
      name: kube-api-access-b7gtm
      readOnly: true
  dnsPolicy: ClusterFirst
  enableServiceLinks: true
  nodeName: minikube-m02
  preemptionPolicy: PreemptLowerPriority
  priority: 0
  restartPolicy: Always
  schedulerName: default-scheduler
  securityContext: {}
  serviceAccount: default
  serviceAccountName: default
  terminationGracePeriodSeconds: 30
  tolerations:
  - effect: NoExecute
    key: node.kubernetes.io/not-ready
    operator: Exists
    tolerationSeconds: 300
  - effect: NoExecute
    key: node.kubernetes.io/unreachable
    operator: Exists
    tolerationSeconds: 300
  volumes:
  - name: kube-api-access-b7gtm
    projected:
      defaultMode: 420
      sources:
      - serviceAccountToken:
          expirationSeconds: 3607
          path: token
      - configMap:
          items:
          - key: ca.crt
            path: ca.crt
          name: kube-root-ca.crt
      - downwardAPI:
          items:
          - fieldRef:
              apiVersion: v1
              fieldPath: metadata.namespace
            path: namespace
status:
  conditions:
  - lastProbeTime: null
    lastTransitionTime: "2026-06-11T06:12:34Z"
    observedGeneration: 1
    status: "True"
    type: PodReadyToStartContainers
  - lastProbeTime: null
    lastTransitionTime: "2026-06-11T06:12:04Z"
    observedGeneration: 1
    status: "True"
    type: Initialized
  - lastProbeTime: null
    lastTransitionTime: "2026-06-11T06:12:34Z"
    observedGeneration: 1
    status: "True"
    type: Ready
  - lastProbeTime: null
    lastTransitionTime: "2026-06-11T06:12:34Z"
    observedGeneration: 1
    status: "True"
    type: ContainersReady
  - lastProbeTime: null
    lastTransitionTime: "2026-06-11T06:12:04Z"
    observedGeneration: 1
    status: "True"
    type: PodScheduled
  containerStatuses:
  - containerID: docker://354bbb227afbdfe82409e51108c8e0018cd7b0b2f8b9959c7b4216c73daf21a7
    image: wbitt/network-multitool:latest
    imageID: docker-pullable://wbitt/network-multitool@sha256:db2810fe2c8d36db074eab5d98fbf861c8ed55e0786d648d3477b3de9135632e
    lastState: {}
    name: db
    ready: true
    resources: {}
    restartCount: 0
    started: true
    state:
      running:
        startedAt: "2026-06-11T06:12:33Z"
    volumeMounts:
    - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
      name: kube-api-access-b7gtm
      readOnly: true
      recursiveReadOnly: Disabled
  hostIP: 192.168.49.3
  hostIPs:
  - ip: 192.168.49.3
  observedGeneration: 1
  phase: Running
  podIP: 10.244.1.186
  podIPs:
  - ip: 10.244.1.186
  qosClass: BestEffort
  startTime: "2026-06-11T06:12:04Z"
*/

--Step 8.11 (Lab)
root@docker-minikube-n01:~# k create ns kirana-db
/*
namespaces/kirana-db created
*/

--Step 8.12 (Lab)
root@docker-minikube-n01:~# k apply -f db-pod.yaml -n kirana-db
/*
pod/db created
*/

--Step 8.13 (Lab)
root@docker-minikube-n01:~# k get pods -n kirana-db
/*
NAME   READY   STATUS              RESTARTS   AGE
db     0/1     ContainerCreating   0          4s
*/

--Step 8.13.1 (Lab)
root@docker-minikube-n01:~# k get pods -n kirana-db
/*
NAME   READY   STATUS    RESTARTS   AGE
db     1/1     Running   0          10s
*/

--Step 8.14 (Lab)
root@docker-minikube-n01:~# k expose pod db -n kirana-db --dry-run=client --port 80 -o yaml > db-svc.yaml

--Step 8.14.1 (Lab)
root@docker-minikube-n01:~# cat db-svc.yaml
/*
apiVersion: v1
kind: Service
metadata:
  labels:
    app: db
  name: db
  namespace: kirana-db
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: db
status:
  loadBalancer: {}
*/

--Step 8.14.2 (Lab)
root@docker-minikube-n01:~# k apply -f db-svc.yaml -n kirana-db --dry-run=client
/*
service/db unchanged (dry run)
*/

--Step 8.14.3 (Lab)
root@docker-minikube-n01:~# k apply -f db-svc.yaml -n kirana-db
/*
service/db created
*/

--Step 8.18 (Lab)
root@docker-minikube-n01:~# k get pods -n kiranashop -o wide
/*
NAME       READY   STATUS    RESTARTS   AGE   IP             NODE           NOMINATED NODE   READINESS GATES
backend    1/1     Running   0          25h   10.244.1.233   minikube-m02   <none>           <none>
db         1/1     Running   0          25h   10.244.1.186   minikube-m02   <none>           <none>
frontend   1/1     Running   0          25h   10.244.1.62    minikube-m02   <none>           <none>
*/

--Step 8.19 (Lab)
root@docker-minikube-n01:~# k get pods -n kirana-db -o wide
/*
NAME   READY   STATUS    RESTARTS   AGE    IP             NODE           NOMINATED NODE   READINESS GATES
db     1/1     Running   0          170m   10.244.1.107   minikube-m02   <none>           <none>
*/

--Step 8.20 (Lab)
root@docker-minikube-n01:~# kubectl get svc -n kiranashop
/*
NAME       TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
backend    ClusterIP   10.99.167.31     <none>        80/TCP    25h
db         ClusterIP   10.110.127.255   <none>        80/TCP    25h
frontend   ClusterIP   10.99.69.245     <none>        80/TCP    25h
*/

--Step 8.21 (Lab)
root@docker-minikube-n01:~# kubectl get svc -n kirana-db
/*
NAME   TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
db     ClusterIP   10.96.94.223   <none>        80/TCP    177m
*/

--Step 8.22 (Lab)
root@docker-minikube-n01:~# k exec -n kiranashop backend -- curl -s -m 3 db
/*
command terminated with exit code 28
*/

--Step 8.23 (Lab)
root@docker-minikube-n01:~# k exec -n kiranashop backend -- curl -s -m 3 db.kiranashop
/*
command terminated with exit code 28
*/

--Step 8.24 (Lab)
root@docker-minikube-n01:~# k exec -n kiranashop backend -- curl -s -m 3 db.kirana-db
/*
I am DB
*/

--Step 8.25 (Lab)
root@docker-minikube-n01:~# k exec -n kiranashop frontend -- curl -s -m 3 db.kirana-db
/*
I am DB
*/

