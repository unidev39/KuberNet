--Week 6 · Session 3 — Take-Home Lab => RBAC & Helm
--Step 1 (Lab) -- Prerequisites
root@workstation:~# minikube delete --all
* Deleting "minikube" in docker ...
* Removing /root/.minikube/machines/minikube ...
* Removing /root/.minikube/machines/minikube-m02 ...
* Removing /root/.minikube/machines/minikube-m03 ...
* Removed all traces of the "minikube" cluster.
* Successfully deleted all profiles
*/

--Step 1.1 (Lab) -- Cluster (RBAC is enabled by default)
root@workstation:~# minikube start --nodes 3 --cni=cilium --force
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

--Step 1.2 (Lab) --# Helm — install if you don't have it
root@workstation:~# curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
/*
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 11929  100 11929    0     0  29830      0 --:--:-- --:--:-- --:--:-- 29897
Downloading https://get.helm.sh/helm-v3.21.1-linux-amd64.tar.gz
Verifying checksum... Done.
Preparing to install helm into /usr/local/bin
helm installed into /usr/local/bin/helm
*/

--Step 1.2.1 (Lab)
root@workstation:~# helm version
/*
version.BuildInfo{Version:"v3.21.1", GitCommit:"c56dd0095fd76da5d7b30ecdf506103e7f26745e", GitTreeState:"clean", GoVersion:"go1.26.4"}
*/

--Step 1.2.2 (Lab) --# Confirm RBAC is the active authorization mode
root@workstation:~# k api-versions | grep rbac.authorization
/*
rbac.authorization.k8s.io/v1
*/

--Step 2 (Lab) --Part A — RBAC -- Task A1 — Create the namespace
root@workstation:~# mkdir -p /development
root@workstation:~# cd /development/
root@workstation:/development# k create namespace credit --dry-run=client -o yaml > namespace.yaml
root@workstation:/development# cat namespace.yaml
/*
apiVersion: v1
kind: Namespace
metadata:
  name: credit
spec: {}
status: {}
*/

--Step 2.1 (Lab)
root@workstation:/development# k apply -f namespace.yaml --dry-run=client
/*
namespace/credit created (dry run)
*/

--Step 2.2 (Lab)
root@workstation:/development# k apply -f namespace.yaml
/*
namespace/credit created
*/

--Step 2.3 (Lab)
root@workstation:/development# k get ns credit
/*
NAME     STATUS   AGE
credit   Active   15s
*/

--Step 3 (Lab)
--Task A2 — Create the auditor ServiceAccount
--The audit team's tooling will authenticate as a ServiceAccount called auditor in the credit namespace.
root@workstation:/development# k create serviceaccount auditor -n credit --dry-run=client -o yaml > serviceaccount.yaml

--Step 3.1 (Lab)
root@workstation:/development# cat serviceaccount.yaml
/*
apiVersion: v1
kind: ServiceAccount
metadata:
  name: auditor
  namespace: credit
*/

--Step 3.2 (Lab)
--Apply it, then confirm it exists:
root@workstation:/development# k apply -f serviceaccount.yaml --dry-run=client
/*
serviceaccount/auditor created (dry run)
*/

--Step 3.3 (Lab)
root@workstation:/development# k apply -f serviceaccount.yaml
/*
serviceaccount/auditor created
*/

--Step 3.4 (Lab)
root@workstation:/development# k auth can-i --as system:serviceaccount:default:default get pods
/*
no
*/

--Step 3.5 (Lab)
root@workstation:/development# k get serviceaccount -n credit -o wide
/*
NAME      AGE
auditor   32s
default   2m46s
*/

--Step 3.5.1 (Lab)
root@workstation:/development# k get serviceaccount auditor -n credit -o wide
/*
NAME      AGE
auditor   68s
*/


--Step 6 (Lab)
--Task A3 — Create a read-only Role
--Create a Role named pod-reader in the credit namespace that allows only get, list, and watch on pods. Nothing else.
root@workstation:/development# k create role pod-reader --verb=get --verb=list --verb=watch --resource=pods -n credit --dry-run=client -o yaml > role.yaml

--Step 6.1 (Lab)
root@workstation:/development# cat role.yaml
/*
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: credit
rules:
- apiGroups:
  - ""
  resources:
  - pods
  verbs:
  - get
  - list
  - watch
*/

--Step 6.2 (Lab)
root@workstation:/development# k apply -f role.yaml --dry-run=client
/*
role.rbac.authorization.k8s.io/pod-reader created (dry run)
*/

--Step 6.3 (Lab)
root@workstation:/development# k apply -f role.yaml
/*
role.rbac.authorization.k8s.io/pod-reader created
*/

--Step 6.4 (Lab)
root@workstation:/development# k get role pod-reader -n credit
/*
NAME         CREATED AT
pod-reader   2026-06-18T09:59:53Z
*/

--Q1: Why is there no deny rule for delete — how does RBAC make sure the auditor can't delete pods even though you never wrote a rule forbidding it?
--A1: RBAC has no deny rules at all — it is allow-only and additive, deny-by-default. Every action starts forbidden, and a verb becomes allowed only when some Role bound to the subject explicitly grants it. Since delete was never granted, it stays denied automatically. You don't forbid it; you simply never permit it.


--Step 7 (Lab)
--Task A4 — Bind the Role to the ServiceAccount
--Create a RoleBinding named read-pods that binds the pod-reader Role to the auditor ServiceAccount.
root@workstation:/development# k create rolebinding read-pods --role=pod-reader --serviceaccount=credit:auditor -n credit --dry-run=client -o yaml > rolebinding.yaml

--Step 7.1 (Lab)
root@workstation:/development# cat rolebinding.yaml
/*
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: credit
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: pod-reader
subjects:
- kind: ServiceAccount
  name: auditor
  namespace: credit
*/

--Step 7.2 (Lab)
root@workstation:/development# k apply -f rolebinding.yaml --dry-run=client
/*
rolebinding.rbac.authorization.k8s.io/read-pods created (dry run)
*/

--Step 7.3 (Lab)
root@workstation:/development# k apply -f rolebinding.yaml
/*
rolebinding.rbac.authorization.k8s.io/read-pods created
*/

--Step 7.4 (Lab)
root@workstation:/development# k get rolebinding read-pods -n credit
/*
NAME        ROLE              AGE
read-pods   Role/pod-reader   31s
*/

--Q2: In the RoleBinding YAML, which field is the subject (the who) and which is the roleRef (the what)?
--A2: The subjects: field is the who — it points to kind: ServiceAccount, name: auditor. The roleRef: field is the what — it points to kind: Role, name: pod-reader

--Step 8 (Lab)
--Task A5 — Prove least privilege with auth can-i
--This is the heart of the lab. Test the auditor's permissions without logging in as them, using impersonation.
--# Should print: yes
root@workstation:/development# k auth can-i list pods -n credit --as=system:serviceaccount:credit:auditor
/*
yes
*/

--Step 8.1 (Lab)
--# Should print: no
root@workstation:/development# k auth can-i delete pods -n credit --as=system:serviceaccount:credit:auditor
/*
no
*/

--Step 8.2 (Lab)
--# Should print: no
root@workstation:/development# k auth can-i secrets pods -n credit --as=system:serviceaccount:credit:auditor
/*
no
*/

--Step 8.3 (Lab)
--# Should print: yes
root@workstation:/development# k auth can-i watch pods -n credit --as=system:serviceaccount:credit:auditor
/*
yes
*/

--Step 8.4 (Lab)
--# See everything the auditor is allowed to do
root@workstation:/development# k auth can-i --list -n credit --as=system:serviceaccount:credit:auditor
/*
Resources                                       Non-Resource URLs                      Resource Names   Verbs
selfsubjectreviews.authentication.k8s.io        []                                     []               [create]
selfsubjectaccessreviews.authorization.k8s.io   []                                     []               [create]
selfsubjectrulesreviews.authorization.k8s.io    []                                     []               [create]
pods                                            []                                     []               [get list watch]
                                                [/.well-known/openid-configuration/]   []               [get]
                                                [/.well-known/openid-configuration]    []               [get]
                                                [/api/*]                               []               [get]
                                                [/api]                                 []               [get]
                                                [/apis/*]                              []               [get]
                                                [/apis]                                []               [get]
                                                [/healthz]                             []               [get]
                                                [/healthz]                             []               [get]
                                                [/livez]                               []               [get]
                                                [/livez]                               []               [get]
                                                [/openapi/*]                           []               [get]
                                                [/openapi]                             []               [get]
                                                [/openid/v1/jwks/]                     []               [get]
                                                [/openid/v1/jwks]                      []               [get]
                                                [/readyz]                              []               [get]
                                                [/readyz]                              []               [get]
                                                [/version/]                            []               [get]
                                                [/version/]                            []               [get]
                                                [/version]                             []               [get]
                                                [/version]                             []               [get]
*/


--Q4: The auditor can list pods in credit. Run the same list pods check but for the default namespace (-n default). 
--What does it return, and why?
--Step 8.5 (Lab)
root@workstation:/development# k auth can-i list pods -n default --as=system:serviceaccount:credit:auditor
/*
no
*/
--A4:  The grant came from a namespaced Role + RoleBinding scoped to credit. That permission exists only inside credit; default has no binding for the auditor, so deny-by-default applies.

--Step 8.6 (Lab)
--Task A6 — A scoping mistake to reason about
--A colleague suggests: "Just give the audit team the built-in view ClusterRole with a ClusterRoleBinding — it's easier."
--You do not need to apply this — just reason about it.
--Q5: What would that change about the audit team's access compared to your namespaced setup? Is it appropriate for a bank? (One or two sentences.)
--A5: To view ClusterRole via ClusterRoleBinding. That would let the audit team read most resources in every namespace cluster-wide, not just pods in credit (the view role does exclude secrets, but it still grants read across far more resources and namespaces than needed). It breaks least privilege and segregation of duties

--Step 9 (Lab)
--Part B — Helm
--Task B1 — Scaffold a chart
--The app team's loan-status web app needs to become a Helm chart. Scaffold one:
root@workstation:/development# helm create loanapp
/*
Creating loanapp
*/

--Step 9.1 (Lab)
--Look at what was generated:
root@workstation:/development# ls loanapp
/*
charts  Chart.yaml  templates  values.yaml
*/

--Step 9.2 (Lab)
root@workstation:/development# ls loanapp/templates
/*
deployment.yaml  _helpers.tpl  hpa.yaml  httproute.yaml  ingress.yaml  NOTES.txt  serviceaccount.yaml  service.yaml  tests
*/

--Q6: Name the file that holds the chart's default configuration, and the file that holds its name and version.
--A6: values.yaml => holds the default configuration, Chart.yaml => holds the chart's name and version 

--Step 10 (Lab)
--Task B2 — Configure via values
--Open loanapp/values.yaml and change:
--replicaCount to 2
--image.repository to nginx
--image.tag to "1.27"
--service.type to ClusterIP
--Hint: these keys already exist in the generated values.yaml — you are editing values, not the templates.
root@workstation:/development# vi loanapp/values.yaml
/*
replicaCount: 2
  repository: nginx
  tag: "1.27"
  type: ClusterIP
*/

--Step 10.1 (Lab)
root@workstation:/development# cat loanapp/values.yaml | grep -i -E "replicaCount: 2|repository: nginx|1.27|type: ClusterIP"
/*
replicaCount: 2
  repository: nginx
  tag: "1.27"
  type: ClusterIP
*/

--Step 11 (Lab)
--Task B3 — Render before you ship
--Render the templates locally and read them — confirm your values took effect before touching the cluster.
root@workstation:/development# helm template loan-dev ./loanapp | grep -E "replicas:|image:"
/*
  replicas: 2
          image: "nginx:1.27"
      image: busybox
*/

--Step 11.1 (Lab)
--Q7: What replicas value appears in the rendered output, and where did it come from?
--A7: From values.yaml

--Step 11.2 (Lab)
--Now do a server-side dry run:
root@workstation:/development# helm install loan-dev ./loanapp -n credit --dry-run --debug | head -40
/*
install.go:225: 2026-06-18 16:16:52.482715903 +0545 +0545 m=+0.399513908 [debug] Original chart version: ""
install.go:242: 2026-06-18 16:16:52.48475103 +0545 +0545 m=+0.401549084 [debug] CHART PATH: /development/loanapp

NAME: loan-dev
LAST DEPLOYED: Thu Jun 18 16:16:52 2026
NAMESPACE: credit
STATUS: pending-install
REVISION: 1
USER-SUPPLIED VALUES:
{}

COMPUTED VALUES:
affinity: {}
autoscaling:
  enabled: false
  maxReplicas: 100
  minReplicas: 1
  targetCPUUtilizationPercentage: 80
fullnameOverride: ""
httpRoute:
  annotations: {}
  enabled: false
  hostnames:
  - chart-example.local
  parentRefs:
  - name: gateway
    sectionName: http
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /headers
image:
  pullPolicy: IfNotPresent
  repository: nginx
  tag: "1.27"
imagePullSecrets: []
ingress:
  annotations: {}
  className: ""
  enabled: false
  hosts:
  - host: chart-example.local
*/

--Step 12 (Lab)
--Task B4 — Install the release
root@workstation:/development# helm install loan-dev ./loanapp -n credit
/*
NAME: loan-dev
LAST DEPLOYED: Thu Jun 18 16:18:02 2026
NAMESPACE: credit
STATUS: deployed
REVISION: 1
NOTES:
1. Get the application URL by running these commands:
  export POD_NAME=$(kubectl get pods --namespace credit -l "app.kubernetes.io/name=loanapp,app.kubernetes.io/instance=loan-dev" -o jsonpath="{.items[0].metadata.name}")
  export CONTAINER_PORT=$(kubectl get pod --namespace credit $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
  echo "Visit http://127.0.0.1:8080 to use your application"
  kubectl --namespace credit port-forward $POD_NAME 8080:$CONTAINER_PORT
*/

--Step 12.1 (Lab)
root@workstation:/development# helm list -n credit
/*
NAME            NAMESPACE       REVISION        UPDATED                                         STATUS          CHART           APP VERSION
loan-dev        credit          1               2026-06-18 16:18:02.94010308 +0545 +0545        deployed        loanapp-0.1.0   1.16.0
*/

--Step 12.2 (Lab)
root@workstation:/development# k get deployment,pod -n credit -o wide
/*
NAME                               READY   UP-TO-DATE   AVAILABLE   AGE    CONTAINERS   IMAGES       SELECTOR
deployment.apps/loan-dev-loanapp   2/2     2            2           115s   loanapp      nginx:1.27   app.kubernetes.io/instance=loan-dev,app.kubernetes.io/name=loanapp

NAME                                    READY   STATUS    RESTARTS   AGE    IP             NODE           NOMINATED NODE   READINESS GATES
pod/loan-dev-loanapp-76545f599c-jjjg4   1/1     Running   0          115s   10.244.2.90    minikube-m03   <none>           <none>
pod/loan-dev-loanapp-76545f599c-rkgmw   1/1     Running   0          115s   10.244.1.123   minikube-m02   <none>           <none>
*/

--Step 12.3 (Lab)
--Q8: How many pods are running, and which value controlled that?
--A8: There are 2 pods running and controlled by loan-dev

--Step 13 (Lab)
--Task B5 — Upgrade via --set
--The app team wants more replicas for a load test — without editing any YAML.
root@workstation:/development# helm upgrade loan-dev ./loanapp -n credit --set replicaCount=4
/*
Release "loan-dev" has been upgraded. Happy Helming!
NAME: loan-dev
LAST DEPLOYED: Thu Jun 18 16:25:07 2026
NAMESPACE: credit
STATUS: deployed
REVISION: 2
NOTES:
1. Get the application URL by running these commands:
  export POD_NAME=$(kubectl get pods --namespace credit -l "app.kubernetes.io/name=loanapp,app.kubernetes.io/instance=loan-dev" -o jsonpath="{.items[0].metadata.name}")
  export CONTAINER_PORT=$(kubectl get pod --namespace credit $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
  echo "Visit http://127.0.0.1:8080 to use your application"
  kubectl --namespace credit port-forward $POD_NAME 8080:$CONTAINER_PORT
*/

--Step 13.1 (Lab)
root@workstation:/development# k get pods -n credit -o wide -w
/*
NAME                                READY   STATUS              RESTARTS   AGE     IP             NODE           NOMINATED NODE   READINESS GATES
loan-dev-loanapp-76545f599c-jjjg4   1/1     Running             0          7m24s   10.244.2.90    minikube-m03   <none>           <none>
loan-dev-loanapp-76545f599c-rkgmw   1/1     Running             0          7m24s   10.244.1.123   minikube-m02   <none>           <none>
loan-dev-loanapp-76545f599c-tpkxt   0/1     ContainerCreating   0          19s     <none>         minikube       <none>           <none>
loan-dev-loanapp-76545f599c-tvlk7   1/1     Running             0          19s     10.244.1.199   minikube-m02   <none>           <none>
loan-dev-loanapp-76545f599c-tpkxt   0/1     Running             0          39s     10.244.0.153   minikube       <none>           <none>
loan-dev-loanapp-76545f599c-tpkxt   1/1     Running             0          39s     10.244.0.153   minikube       <none>           <none>
*/

--Step 13.2 (Lab)
root@workstation:/development# k get pods -n credit -o wide
/*
NAME                                READY   STATUS    RESTARTS   AGE     IP             NODE           NOMINATED NODE   READINESS GATES
loan-dev-loanapp-76545f599c-jjjg4   1/1     Running   0          8m13s   10.244.2.90    minikube-m03   <none>           <none>
loan-dev-loanapp-76545f599c-rkgmw   1/1     Running   0          8m13s   10.244.1.123   minikube-m02   <none>           <none>
loan-dev-loanapp-76545f599c-tpkxt   1/1     Running   0          68s     10.244.0.153   minikube       <none>           <none>
loan-dev-loanapp-76545f599c-tvlk7   1/1     Running   0          68s     10.244.1.199   minikube-m02   <none>           <none>
*/

--Step 13.3 (Lab)
root@workstation:/development# helm history loan-dev -n credit
/*
REVISION        UPDATED                         STATUS          CHART           APP VERSION     DESCRIPTION
1               Thu Jun 18 16:18:02 2026        superseded      loanapp-0.1.0   1.16.0          Install complete
2               Thu Jun 18 16:25:07 2026        deployed        loanapp-0.1.0   1.16.0          Upgrade complete
*/

--Step 13.4 (Lab)
--Q9: How many revisions does helm history show now, and what does each revision represent?
--A9: History is 2 and Frist One is an Installation and second one is Upgrading.

--Step 14 (Lab)
--Task B6 — Roll back
--The load test caused problems. Roll back to the original 2-replica release with a single command.
root@workstation:/development# helm rollback loan-dev 1 -n credit
/*
Rollback was a success! Happy Helming!
*/

--Step 14.1 (Lab)
root@workstation:/development# k get pods -n credit -o wide
/*
NAME                                READY   STATUS    RESTARTS   AGE    IP             NODE           NOMINATED NODE   READINESS GATES
loan-dev-loanapp-76545f599c-jjjg4   1/1     Running   0          12m    10.244.2.90    minikube-m03   <none>           <none>
loan-dev-loanapp-76545f599c-tpkxt   1/1     Running   0          5m3s   10.244.0.153   minikube       <none>           <none>
*/

--Step 14.2 (Lab)
root@workstation:/development# helm history loan-dev -n credit
/*
REVISION        UPDATED                         STATUS          CHART           APP VERSION     DESCRIPTION
1               Thu Jun 18 16:18:02 2026        superseded      loanapp-0.1.0   1.16.0          Install complete
2               Thu Jun 18 16:25:07 2026        superseded      loanapp-0.1.0   1.16.0          Upgrade complete
3               Thu Jun 18 16:30:03 2026        deployed        loanapp-0.1.0   1.16.0          Rollback to 1
*/

--Step 14.3 (Lab)
--Q10: After the rollback, how many pods are running? What revision number did the rollback itself create in the history (was it 1, or a new number)?
--A10: Running Pods are 2, New One in Helm history is 3