Nicola, scusa la latitanza, ma credimi che fino ad ora non ho staccato un attimo per portare a termine almeno la prima fase operativa del VM TEST ENVIRONMENT. 

Come ti dicevo ieri, ho dovuto reinstallare da zero il CLUSTER VM per via della configurazione di rete e dei vari PLUGIN CNI testati (FLANNEL, WAVENET, CALICO E MULTUS)  hanno incasinato il cluster networking, non permettendo l’installazione sia di KUMA che di LINKERD. (purtroppo non avevo uno snapshot buono e quindi ho preferito ripartire da una situazione “pulita”)

Una volta reinstallato il tutto e configurato la parte Networking con FLANNEL e MULTUS, ho riprovato con l’ultima versione di KUMA (1.0.6) ma l’installazione su K8S del CP non è andata a buon fine, sempre per problemi di compatibilità con la ver. 1.20.2 mentre è andata bene in modo “universal”, cioè disgiunta dal cluster K8S, stand-alone in CentOS.

https://kuma.io/docs/0.5.0/quickstart/universal/

Poi , tornando indietro, ho installato per Test, Linkerd, ver. 2.9.2 (stable) che in primo momento, sembrava funzionare, ma poi, mi sono accorto che il sidecar proxy (envoy) che iniettava nei container, non rispondeva più (penso per problemi di certificati TLS non validi) e dopo aver perso circa 3 ore, provando e riprovando, purtroppo non c’è stato nulla da fare.

(per togliermi la curiosità, l’ho installato in locale su un’istanza di minikube e funzionava una meraviglia!) 

Alla fine, per esclusione (e soprattutto per disperazione), ho testato ISTIO (1.8.2)e con somma sorpresa, si è installato subito senza nessun problema, creando correttamente tutto quello che ci serve e cioè : un Control Plane, un Data Plane, un ingress controller e anche un egress controller. Ovviamente anche lui usa Envoy e la comunicazione MTLS va che è un piacere.

Ho finito ora di effettuare i test della loro app DEMO , per testare le mesh policy, ed è andato tutto bene. (ho documentato e salvato tutto).

Questo è il loro esempio di default che ho seguito :  https://istio.io/latest/docs/examples/bookinfo/



```yaml
`[centos@k8smaster kube]$ kubectl get services
NAME          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
details       ClusterIP   10.104.190.30   <none>        9080/TCP   4m15s
kubernetes    ClusterIP   10.96.0.1       <none>        443/TCP    20h
productpage   ClusterIP   10.102.78.140   <none>        9080/TCP   4m12s
ratings       ClusterIP   10.108.1.161    <none>        9080/TCP   4m14s
reviews       ClusterIP   10.97.148.126   <none>        9080/TCP   4m14s`
```



```yaml
[centos@k8smaster kube]$ kubectl get pods -A
NAMESPACE      NAME                                      READY   STATUS    RESTARTS   AGE
default        details-v1-79c697d759-rgq2l               2/2     Running   0          20m
default        productpage-v1-65576bb7bf-kvcnf           2/2     Running   0          20m
default        ratings-v1-7d99676f7f-jk9zw               2/2     Running   0          20m
default        reviews-v1-987d495c-k4ltf                 2/2     Running   0          20m
default        reviews-v2-6c5bf657cf-b5zd8               2/2     Running   0          20m
default        reviews-v3-5f7b9f4f77-fggxw               2/2     Running   0          20m
istio-system   istio-egressgateway-64d976b9b5-fwbtv      1/1     Running   0          84m
istio-system   istio-ingressgateway-68c86b9fc8-2s5xd     1/1     Running   0          84m
istio-system   istiod-5c986fb85b-fj2xv                   1/1     Running   0          84m
kube-system    coredns-74ff55c5b-7pjvq                   1/1     Running   1          20h
kube-system    coredns-74ff55c5b-lcq9j                   1/1     Running   1          20h
kube-system    etcd-k8smaster.local                      1/1     Running   1          20h
kube-system    kube-apiserver-k8smaster.local            1/1     Running   1          20h
kube-system    kube-controller-manager-k8smaster.local   1/1     Running   1          20h
kube-system    kube-flannel-ds-4ctvz                     1/1     Running   3          20h
kube-system    kube-flannel-ds-ktt85                     1/1     Running   3          20h
kube-system    kube-flannel-ds-wbdmn                     1/1     Running   1          20h
kube-system    kube-proxy-2clbg                          1/1     Running   3          20h
kube-system    kube-proxy-jrxhq                          1/1     Running   3          20h
kube-system    kube-proxy-t8dmw                          1/1     Running   1          20h
kube-system    kube-scheduler-k8smaster.local            1/1     Running   1          20h
```
```yaml
`[centos@k8smaster httpbin]$  export INGRESS_HOST=$(kubectl get po -l istio=ingressgateway -n istio-system -o jsonpath='{.items[0].status.hostIP}')
[centos@k8smaster httpbin]$ curl -s -I -HHost:httpbin.example.com "http://$INGRESS_HOST:$INGRESS_PORT/status/200"
HTTP/1.1 200 OK
server: istio-envoy
date: Wed, 27 Jan 2021 15:45:33 GMT
content-type: text/html; charset=utf-8
access-control-allow-origin: *
access-control-allow-credentials: true
content-length: 0
x-envoy-upstream-service-time: 64`
```


#### ARCHITETTURA :

![](ISTIO_2_1_mXfP8dp7vpnf1d7QCeVcFQ.png)







Poi questi link sono più esaustivi :

https://istio.io/latest/docs/setup/getting-started/

https://istio.io/latest/docs/tasks/traffic-management/request-routing/

https://istio.io/latest/docs/setup/install/multicluster/

Diciamo che rispetto a Kuma, è come guidare una Mercedes rispetto ad una Fiat, poi c’è un mare di documentazione e di esempi online ed è fatto dalla stessa Google, mamma anche di K8S. Di contro però è veramente complesso ed esoso di risorse rispetto agli altri ma, almeno per il mio environment vmware su notebook malandato, tutto si è installato correttamente e gira onestamente. Devo ancora vedere poi, il discorso, metrics con Grafana e Prometheus, che viene gestito nativamente, tramite la su dashboard Kiali che provvederò a testare domani.

 A questo punto ti chiedo di fare le tue valutazioni in merito, tenendo conto di quanto riportato sopra.

Grazie.  