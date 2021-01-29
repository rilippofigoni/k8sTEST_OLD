# TEST MULTIPASS+MICROk8s+MULTUS

Created: Jan 18, 2021 12:01 PM
Created By: Filippo Rigoni
Last Edited By: Filippo Rigoni
Last Edited Time: Jan 19, 2021 1:09 PM

Ho seguito la guida di installazione di Multipass e Microk8s sul mio notebook con MacOSX 10.15

Vedi sito doc : ([https://microk8s.io/docs](https://microk8s.io/docs)). Una volta che l'ambiente era operativo ho proceduto con questi step :

```bash
# Creazione master
$ multipass launch --name master -m 2G
Launched: master

# Creazione workers1
$ multipass launch --name worker1 -m 2G
Launched: worker1

# Creazione workers2
$ multipass launch --name worker2 -m 2G
Launched: worker2

# Stato:
$ multipass ls
Name                    State             IPv4             Image
master                  Running           192.168.64.4     Ubuntu 18.04 LTS
worker1                 Running           192.168.64.5     Ubuntu 18.04 LTS
worker2                 Running           192.168.64.6     Ubuntu 18.04 LTS
```

```bash
# Login sul master
$ multipass shell master

# Installazione microk8s snap
$ sudo snap install microk8s --classic 
2020-06-13T12:03:41-03:00 INFO Waiting for restart...
microk8s (1.18/stable) v1.18.3 from Canonical✓ installed

# Predisponi i permessi per l'utente corrente

$ sudo usermod -a -G microk8s $USER
$ sudo chown -f -R $USER ~/.kube

# Creazione alias per il cmd kubectl

$ echo "alias kubectl='microk8s kubectl'" >> ~/.bash_aliases
$ source ~/.bash_aliases
```

```bash
$ microk8s status --wait-ready

microk8s is running
high-availability: no
  datastore master nodes: 127.0.0.1:19001
  datastore standby nodes: none
addons:
  enabled:
    ha-cluster           # Configure high availability on the current node
  disabled:
    ambassador           # Ambassador API Gateway and Ingress
    cilium               # SDN, fast with full network policy
    dashboard            # The Kubernetes dashboard
    dns                  # CoreDNS
    fluentd              # Elasticsearch-Fluentd-Kibana logging and monitoring
    gpu                  # Automatic enablement of Nvidia CUDA
    helm                 # Helm 2 - the package manager for Kubernetes
    helm3                # Helm 3 - Kubernetes package manager
    host-access          # Allow Pods connecting to Host services smoothly
    ingress              # Ingress controller for external access
    istio                # Core Istio service mesh services
    jaeger               # Kubernetes Jaeger operator with its simple config
    keda                 # Kubernetes-based Event Driven Autoscaling
    knative              # The Knative framework on Kubernetes.
    kubeflow             # Kubeflow for easy ML deployments
    linkerd              # Linkerd is a service mesh for Kubernetes and other frameworks
    metallb              # Loadbalancer for your Kubernetes cluster
    metrics-server       # K8s Metrics Server for API access to service metrics
    multus               # Multus CNI enables attaching multiple network interfaces to pods
    portainer            # Portainer UI for your Kubernetes cluster
    prometheus           # Prometheus operator for monitoring and logging
    rbac                 # Role-Based Access Control for authorisation
    registry             # Private image registry exposed on localhost:32000
    storage              # Storage class; allocates storage from host directory
    traefik              # traefik Ingress controller for external access

# installiamo il plugin MULTUS

$ microk8s enable multus

Enabling Multus
Waiting for microk8s to be ready.
Applying manifest for multus daemonset.
customresourcedefinition.apiextensions.k8s.io/network-attachment-definitions.k8s.cni.cncf.io created
clusterrole.rbac.authorization.k8s.io/multus created
clusterrolebinding.rbac.authorization.k8s.io/multus created
serviceaccount/multus created
daemonset.apps/kube-multus-ds-amd64 created
Waiting for multus daemonset to start...................................................................
Multus is enabled
Multus is enabled with version:
multus-cni version:v3.4.2, commit:4eac660359f223d34bcaf0fddbc42fd542f02ba1, date:2020-05-15T12:43:46+0000

Currently installed CNI and IPAM plugins include:
bandwidth bridge calico calico-ipam dhcp flannel flanneld host-device host-local ipvlan loopback macvlan multus portmap ptp sample tuning vlan

New CNI plugins can be installed in /var/snap/microk8s/current/opt/cni/bin/

For information on configuration please refer to the multus documentation.
  First you need to create network definitions:
    https://github.com/intel/multus-cni/blob/master/doc/how-to-use.md#create-network-attachment-definition
  Then you need to tell your pods to use those networks via annotations
    https://github.com/intel/multus-cni/blob/master/doc/how-to-use.md#run-pod-with-network-annotation
```

```bash
# Creazione della "join" dei nodi worker al master
# NOTA : va fatto su ogni nodo

$ sudo microk8s add-node

Join node with: microk8s join 192.168.64.4:25000/IfrgUOBCMGxZyAcRgEXXLONcwMKWpstO

# JOIN del Nodo Worker1 + Woker2

# Aprire la shell del nodo
$ multipass shell worker1

# install microk8s nel nodo
$ sudo snap install microk8s --classic --channel=1.18/stable

# Ora la join al master del nodo
$ sudo microk8s join 192.168.64.4:25000/IfrgUOBCMGxZyAcRgEXXLONcwMKWpstO

# Log in master
$ multipass shell master

# Show dei nodi attivi
$ kubectl get nodes

NAME      STATUS   ROLES    AGE     VERSION
worker1   Ready    <none>   9m56s   v1.20.1-34+e7db93d188d0d1
master    Ready    <none>   34m     v1.20.1-34+e7db93d188d0d1
worker2   Ready    <none>   63s     v1.20.1-34+e7db93d188d0d1
```

B) Creazione di un microservizio  (hello-node) e relativo POD :

```bash
# Log in master
$ kubectl create deployment hello-node --image=k8s.gcr.io/echoserver:1.4
deployment.apps/hello-node created

# Show del deploy
$ kubectl get deployments
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
hello-node   1/1     1            1           28s

# Show dei pods
$ kubectl get pods
NAME                          READY   STATUS    RESTARTS   AGE
hello-node-7bf657c596-htx9p   1/1     Running   0
```

```bash
# Aggiungiamo un Ingress al Cluster
# usando il plugin micro8ks (nginx ingress)

$ microk8s enable ingress
Enabling Ingress
namespace/ingress created
serviceaccount/nginx-ingress-microk8s-serviceaccount created
clusterrole.rbac.authorization.k8s.io/nginx-ingress-microk8s-clusterrole created
role.rbac.authorization.k8s.io/nginx-ingress-microk8s-role created
clusterrolebinding.rbac.authorization.k8s.io/nginx-ingress-microk8s created
rolebinding.rbac.authorization.k8s.io/nginx-ingress-microk8s created
configmap/nginx-load-balancer-microk8s-conf created
daemonset.apps/nginx-ingress-microk8s-controller created
Ingress is enabled
```

```bash
# Creiamo il servizio per hello-node app
$ cat <<EOF | kubectl apply -f -
kind: Service
apiVersion: v1
metadata:
  name: hello-node
spec:
  selector:
    app: hello-node
  ports:
  # Default port
  - port: 8080
EOF
service/hello-node created

# Configuriamo l'ingress controller a "forwardare" al servizio hello-node

$ cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: my-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
spec:
  rules:
  - http:
      paths:
      - path: /hello
        backend:
          serviceName: hello-node
          servicePort: 8080
EOF

ingress.extensions/my-ingress created
```

```bash
# Accediamo al servizio usando ill master IP
# sulla LAN del POD

$ curl http://192.168.64.4/hello
CLIENT VALUES:
client_address=10.1.21.1
command=GET
real path=/
query=nil
request_version=1.1
request_uri=http://192.168.64.4:8080/

SERVER VALUES:
server_version=nginx: 1.10.0 - lua: 10001

HEADERS RECEIVED:
accept=*/*
host=192.168.64.4
user-agent=curl/7.58.0
x-forwarded-for=192.168.64.1
x-forwarded-host=192.168.64.4
x-forwarded-port=80
x-forwarded-proto=http
x-original-uri=/hello
x-real-ip=192.168.64.5
x-request-id=c128fb95cd6919745659310198f823c1
x-scheme=http
BODY:
-no body in request-
```

```bash
# a questo punto vogliamo aggiungere un'interfaccia al nostro POD
# su una rete diversa e quindi configureremo il Plugin MULTUS

$ microk8s enable multus

$ microk8s kubectl get pods -n kube-system --selector=app=multus

NAME                         READY   STATUS    RESTARTS   AGE
kube-multus-ds-amd64-6mzdb   1/1     Running   0          38m
kube-multus-ds-amd64-2cfvz   1/1     Running   0          20m
kube-multus-ds-amd64-tgs75   1/1     Running   0          11m

# il seguente comando crea NetworkAttachmentDefinition per una nuova subnet. 
# La configurazione CNI è un esempio nel campo config:

$ cat <<EOF | kubectl create -f -
>apiVersion: "k8s.cni.cncf.io/v1"
kind: NetworkAttachmentDefinition
metadata:
  name: mgnt
spec:
  config: '{
    "cniVersion": "0.3.1",
    "name": "mgnt",
    "type": "mac-vlan",
    "bridge": "br100",
    "isDefaultGateway": false,
    "forceAddress": false,
    "ipMasq": false,
    "hairpinMode": false,
    "ipam": {
      "type": "host-local",
      "subnet": "192.168.1.0/24",
      "rangeStart": "192.168.1.201",
      "rangeEnd": "192.168.1.250",
      "routes": [
        { "dst": "0.0.0.0/0" }
      ],
      "gateway": "192.168.1.1"
    }
  }'
EOF
networkattachmentdefinition.k8s.cni.cncf.io/mgnt created
```

```bash
# Ora implementiamo ed eseguiamo il pod hello-node 
# con la nuova configurazione di rete

$ cat <<EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: hello-node
  annotations:
    k8s.v1.cni.cncf.io/networks: '[
            { "name" : "mgtn"}
    ]'
spec:
  containers:
  - name: hello-node
    image: docker.io/centos/tools:latest
    command:
    - /sbin/init
EOF

# Controlliamo lo stato del network del nostro pod

$ kubectl exec -it hello-node -- ip -d address

1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00 promiscuity 0 numtxqueues 1 numrxqueues 1 gso_max_size 65536 gso_max_segs 65535
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
3: eth0@if11: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue state UP group default
    link/ether 0a:58:0a:f4:02:06 brd ff:ff:ff:ff:ff:ff link-netnsid 0 promiscuity 0
    veth numtxqueues 1 numrxqueues 1 gso_max_size 65536 gso_max_segs 65535
    inet 192.168.4.4/24 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::ac66:45ff:fe7c:3a19/64 scope link
       valid_lft forever preferred_lft forever
4: mgnt@if3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN group default
    link/ether 4e:6d:7a:4e:14:87 brd ff:ff:ff:ff:ff:ff link-netnsid 0 promiscuity 0
    macvlan mode bridge numtxqueues 1 numrxqueues 1 gso_max_size 65536 gso_max_segs 65535
    inet 192.168.1.201/24 scope global mgnt
       valid_lft forever preferred_lft forever
    inet6 fe80::4c6d:7aff:fe4e:1487/64 scope link
       valid_lft forever preferred_lft forever
```

```bash
# Controlliamo se è raggiungibile dall'esterno sulla nuova vlan

# funziona anche su altri nodi (worker1 e worker2), ovviamente dopo aver 
# ripetuto la configurazione di rete aggiuntiva.

$ curl http://192.168.1.201/hello
CLIENT VALUES:
client_address=10.1.21.1
command=GET
real path=/
query=nil
request_version=1.1
request_uri=http://192.168.1.201:8080/

SERVER VALUES:
server_version=nginx: 1.10.0 - lua: 10001

HEADERS RECEIVED:
accept=*/*
host=192.168.1.201
user-agent=curl/7.58.0
x-forwarded-for=192.168.1.1
x-forwarded-host=192.168.1.201
x-forwarded-port=80
x-forwarded-proto=http
x-original-uri=/hello
x-request-id=c128fb95cd6919745659310198f823c1
x-scheme=http
BODY:
-no body in request-
```