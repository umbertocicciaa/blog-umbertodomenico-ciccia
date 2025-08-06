---
date: '2025-08-06T21:49:41+02:00'
title: 'Cka Notes'
description: Notes for CKA 2025 Certification
tags: ["kubernetes", "kubestronaut", "devops", "certifications", "cka", "notes"]
---

## Core concepts

### Cluster Architecture

**Master node**: orchestrate nodes → schedule, monitor, worker, state, manage cluster

**Worker node**: host applications as container

Master node components:

- **ETCD**: database of the state of the cluster
- **KUBE-SCHEDULER:** schedule pods to worker nodes
- **CONTROLLER-MANAGER**
  - **NODE-CONTROLLER:** orchestrate nodes
  - **REPLICATION-CONTROLLER:** orchestrate replication groups
- **KUBE-APISERVER**: expose k8s cluster from external thought api

Worker node components:

- **CONTAINER RUNTIME: container** runtime engine
- **KUBELET:** agent that run in every node, for receive api call from api server
- **KUBE-PROXY:** manage communication between container, nodes

### Container runtime interface

**Container runtime interface CRI**: allow to use k8s with all container runtime

CRI is compliance with **Open Container Initiative** **OCI**

**Open Container Initiative**: specify how image should develop, build, and the specification of runtime

#### Docker

**Docker**: container runtime CRI only image compilance to OCI

#### Containerd

**Containerd**: container runtime CRI and OCI compliance

**ctr**: cli for debug container in containerd

**nerdctl**: cli docker simil es nerdctl run —name redis redis:alpine

#### Crictl

**Crictl**: cli for interact from k8s to container runtime (cli for k8s CRI), work across different container runtime

Example commands:

```bash
crictl pull busybox
```

```bash
crictl images
```

```bash
crictl ps -a
```

```bash
crictl exec -i t container-id commandtoexec
```

```bash
crictl pods
```

### Etcd

**ETCD:** key-value distributed store

#### Install ETCD

1. Download binaries from github
2. Extract binaries
3. Run ETCD Service → listen on port 2379

#### Etcdctl

**Etcdctl**: cli for operate with etcd

Example commands:

```bash
etcdctl set key1 value1
```

```bash
etcdctl get key1
```

#### ETCD Versions

```bash
etcdctl —version # return version of api and cli
```

```bash
**ETCDTL_API**=version # env variable for api version of etcdctl
```

#### ETCD on K8s

**ETCD on K8s**: maintain cluster configuration

/registry/ root path of k8s configuration on etcd

### Kube-apiserver

**Kube-apiserver**: api server for interact with the cluster, example kubectl get nodes, retrieve info about the nodes from etcd after you connect to the kube-apiserver through kubectl, if you are authenticated

#### Kube-apiserver flow

1. Make post request
2. Authenticate User
3. Validate Request
4. Retrieve data
5. Update etcd
6. scheduler
7. kubelet

#### Installing kube-apiserver

1. download binaries
2. extract binaries
3. run service

### Controller manager

Controller: continuously monitor the state of the cluster and keep the state alive

#### Node controller

**Node controller**: control status of nodes

**Node monitor period**: every 5s control status of nodes

**Node monitor grace period:** if node is unhealthy wait 40 second for mark node as unreachable

**POD Eviction Timeout: if Node monitor grace period** is end remove pod from the node

#### Replication controller

**Replication controller**: control if the pod replication is respected

#### Others controller

- Service account controller
- PV-Binder-controller
- PV-Protection-controller
- Namespace-controller
- Endpoint-controller
- Deployment-controller
- Cronjob

#### Installing kube-controller-manager

1. Download binaries
2. Extract binaries
3. Run service

### Kube-scheduler

**kube-scheduler**: decide which pod in which pod

**Kubelet**: create pod in the node

#### Scheduling phase

1. Filter nodes: filter all possible nodes for the pod
2. Rank nodes: classify the best nodes for the specification

#### Installing kube-scheduler

1. download binaries
2. extract binaries
3. run service

### Kubelet

**kubelet**: register the node with the cluster, create pod in the node, monitor node and pods in the node

#### Installing kubelet

1. download binaries
2. extract binaries
3. run service

### Kube-proxy

**kube-proxy**: run in every node and every time new service is create manage networking of the service through routing table

#### Installing Kube-proxy

1. download binaries
2. extract binaries
3. run service

### Yaml

```yaml
apiVersion: # version of k8s api
kind:       # kind of object to create
metadata:   # metadata of the object
spec:       # specification of the object
```

### Pod

**Pod**: encapsulate containers

**Multi-Container pods**: pod with other container inside like sidecar containers → container are in the same newtork, they can have the same storage

#### Yaml pod

```yaml
apiVersion: v1
kind: Pod      
metadata:   
  name: mypod-prod
  labels: # help identify pods
   app: myapp
   type: front-end
spec: 
 containers: # specify container of the pod
 - name: nginx-container
  image: nginx      
```

### ReplicaSet

**ReplicaSet**: manage replication for a pod for ha, can work cross nodes

#### Yaml ReplicaSet

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
 name: myapp-replica
 labels:
  app: myapp
  type: front-end
spec:
 template: # define pod to replicate template
  metadata:
   name: myapp-replica
   labels:
    app: myapp
    type: front-end
  spec: 
   containers: # specify container of the pod
   - name: nginx-container
    image: nginx
replicas: 3 # number of replica
selector: # for replicate all pod with a label
 matchLabels:
  type: front-end
```

#### Label and Selector

**Label**: label object for selection

**Selector**: filter object with a label

### Deployments

**Deployments**: replicaset + rollout, rollbacks and versioning

#### Yaml Deployments

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
 name: myapp-deployment
 labels:
  app: myapp
  type: front-end
spec:
 template: # define pod to replicate template
  metadata:
   name: myapp-replica
   labels:
    app: myapp
    type: front-end
  spec: 
   containers: # specify container of the pod
   - name: nginx-container
    image: nginx
replicas: 3 # number of replica
selector: # for replicate all pod with a label
 matchLabels:
  type: front-end
```

#### Commands

```bash
kubectl rollout undo deployment/name
```

```bash
kubectl rollout status deployment/name (or daemonset/name)
```

```bash
kubectl rollout restart deployment/name
```

### Services

**Service**: expose application and enable connectivity between pods

#### NodePort Service

**Node port service:** make pod accessible from the external to a port and the ip of the node

```yaml
apiVersion: v1
kind: Service
metadata:
 name: myapp-service
spec:
 type: NodePort
 ports:
 - targetPort: 80 # target port of pod
  port: 80 # internal port forward to target
  nodePort: 30008 # port of noide exposed
 selector: # define which pod to expose
  app: myapp
  type: frontent
```

#### ClusterIp

**ClusterIp**: virtual ip that enable communication between pods, and can internal comunication

```yaml
apiVersion: v1
kind: Service
metadata:
 name: backend # name for access to backend pods
spec:
 type: ClusterIP
 ports:
 - targetPort: 80 # target port of pod
  port: 80 # internal port forward to target
 selector: # define which pod to expose
  app: myapp
  type: back-end
```

#### LoadBalancer

**LoadBalancer**: nodeport with external cloud load balancer

```yaml
apiVersion: v1
kind: Service
metadata:
 name: myapp-service
spec:
 type: loadBalancer
 ports:
 - targetPort: 80 # target port of pod
  port: 80 # internal port forward to target
  nodePort: 30008
```

### Namespace

**Namespaces:** virtual isolation in cluster, every namespace is isolated

```yaml
apiVersion: v1
kind: namespace
metadata:
 name: dev
```

#### ResourceQuota

**ResourceQuota**: define max resource for namespace

### Kubectl apply

**apply command:** apply configuration

if object exist compare old configuraiton saved in json under [kubectl.kubernetes.io/last-applied-configuration](http://kubectl.kubernetes.io/last-applied-configuration) annotations

## Scheduling

### Manual scheduling

**nodeName**: setting nodeName propriety on pod you manually assign pod to a node

```yaml
# ... 
spec:
 nodeName: node01
```

#### Change node after schedule

**Binding object**: bind pod to a node after another schedule

```yaml
apiVersion: v1
kind: Binding
metadata:
 name: nginx
target:
 apiVersion: v1
 kind: Node
 name: node01
```

### Taint

**Taint**: taint node restrict which pod can be schedule in the node → block schedule some pod in a node

#### Commands Taint

```bash
kubectl taint nodes node-name key=value:taint-effect # taint
```

```bash
kubectl taint nodes node-name key=value:taint-effect- #untaint with - at the end
```

#### Taint Effect

**NoSchedule:** no schedule pod to a node

**PreferNoSchedule:** prefer to not schedule pod in a node

**NoExecute:** no execute pod in the node, if is executing it get purged

### Toleration

**Toleration**: a pod tolerate the taint and can be schedule in the node → allow schedule some pod in a tainted node

#### Command Tolerations

```bash
kubectl taint nodes node1 app=blue:NoSchedule
```

```yaml
# ... pods defintions ...
spec:
 containers:
 - name: nginx-container
  image: nginx
 tolerations:
 - key: "app"
   operator: "Equal"
   value: "blue"
   effect: "NoSchedule"
```

### NodeSelectors

**NodeSelector: specify in which node pod should be scheduled**

```yaml
# ...
spec:
 nodeSelector:
  label-key: label-value
```

**Label nodes:** assign label to a node

```bash
kubectl label nodes <node-name> <label-key>=<label-value>
```

### Node Affinity

Node Affinity: ensure a pod is scheduled only in a node, can specify advanced expression

### Resource

#### Memory

Gi == 1024

G == 1000

#### Cpu

1 Cpu == 1 core

### Resource limits

#### Resource request

**Resource request**: request specific hardware for a pod

```yaml
spec:
 resources:
  requests:
   memory: "4Gi"
   cpu: 2
```

#### Resource limits

**Resource limits**: request max specific hardware for a pod

```yaml
spec:
 resources:
  limits:
   memory: "4Gi"
   cpu: 2
```

**Exceed Cpu**: throttle pod

**Exceed memory**: OOM Out of Memory Exception

#### Limit range

**Limit Range**: limit in a range of memory and cpu

```yaml
spec:
 limits:
 - default: 
   cpu: 500m
  defaultRequest:
   cpu: 500m
  max:
   cpu: "1"
  min:
   cpu: 100m
  type: Container
```

#### Resource Quota

**Resource Quota:** restrict the max resource of all the pod in the namespace

### DaemonSet

**DaemonSet**: deploy 1 pod in every node of the cluster

### Static pod

**Static pod**: pod deployed by kubelet without master node, and ignored by scheduler

### Priorities

**Priorities:** specify the priority of the schedule

**PriorityClass**: object for define priority

**PriorityClassName**: use priority in pod definition

```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
 name: my-prio
value: 100000000
description: "priority"
```

```yaml
spec:
 priorityClassName: my-prio
```

### Admission Controller

**Admission Controllers:** intercept  and manage the request after authentication and authorization to the kube-apiserver

## Monitoring

### Metric Server

**Metric Server:** retrieve and collect metric from nodes (in memory) → nel kubelet

#### Install metric server

```bash
minikube addons enable metric-server
```

```bash
git clone https://github.com/kubernetes-incubator/metrics-server.git
kubectl create -f deploy/1.8+/
```

#### Retrieve metric

```bash
kubectl top node
kubectl top pod
```

### Application logs

```bash
kubectl logs -f podname
```

## Application Lifecycle Management

### Rolling updates and rollbacks

Revision: version of a deployment

#### Strategy

**Recreate** **strategy**: recreate with new version

**Rolling strategy**: gradually update to new version

#### Commands

```bash
## create
kubectl create -f mydeployment.yaml

## Update
kubectl apply -f mydeployment.yaml
kubectl set image deployment <deployment-name> <container-name>=<image-name>:<version>

## Status
kubectl rollout history deployment/my-deploy ## check history of deployment
kubectl rollout status deployment/my-deploy ## check status of deployment

## Rollback
kubectl rollout undo deployment/mydeployment
```

### Command and Arguments

```yaml
spec:
 containers:
 - name: test
   image: debian
   command: ["printenv"] # command at startup of container
    args: ["HOSTNAME", "KUBERNETES_PORT"] # arguments of the command
```

### Environment Variables

#### ConfigMap

**ConfigMap**: encapsulate env variables

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
 name: app-config
data:
 APP_COLOR: blue
```

#### Injection of the config map

1. All config map

    ```yaml
    envFrom:
    - configMapRef: 
      name: configmap # name of the config map with the values to assign to CONFIGMAP_ENV
    ```

2. Single

```yaml
env:
- name: CONFIGMAP_ENV
 valueFrom:
  configMapKeyRef: 
   name: configmap # name of the config map with the value to assign to CONFIGMAP_ENV
   key: key # key of the config map to assign to CONFIGMAP_ENV
```

1. Volume

```yaml
volume:
- name: my-volume
 configMap:
  name: configmap
```

**####** Secrets

Base64 commands:

```bash
echo -n "ciao" | base64
echo Y2lhbw== | base64 --decode
```

```yaml
apiVersion: v1
kind: Secret
metadata:
 name: app-secret
data:
 PASSWORD: <base64encodedvalue>
```

#### Injection of the secrets

1. All config map

    ```yaml
    envFrom:
    - secretRef: 
      name: configmap # name of the secret  with the valu
    ```

2. Single

```yaml
env:
- name: SECRET_ENV
 valueFrom:
  secretKeyRef: 
   name: secretname # name of the secret with the value to assign to SECRET_ENV
   key: key # key of the secret map to assign to SECRET_ENV
```

1. Volume

```yaml
volume:
- name: my-volume
 secret:
  name: mysecret
```

#### Example

```yaml
spec:
 containers:
 - name: test
   image: debian
   env:
  - name: MESSAGE
    value: "hello world"
  - name: CONFIGMAP_ENV
   valueFrom:
    configMapKeyRef: 
     name: configmap # name of the config map with the value to assign to CONFIGMAP_ENV
     key: key # key of the config map to assign to CONFIGMAP_ENV
  - name: SECRET_ENV
   valueFrom:
    secretKeyRef: 
     name: secret # name of the config map with the value to assign to CONFIGMAP_ENV
     key: key # key of the config map to assign to CONFIGMAP_ENV 
  command: ["/bin/echo"]
  args: ["$(MESSAGE)"]
```

### Multi-container pod

#### Colocated Container

**Colocated Containe**r: 2 container in the same pod

```yaml
spec:
 containers:
 - name: debian
   image: debian
 - name: nginx
   image: nginx  
```

#### Init Container

**Init Containe**r: init container run before the main pod and after the initialisation processing go down

```yaml
spec:
 containers:
 - name: debian
   image: debian
 initContainers:
 - name: nginx
   image: nginx
   restartPolicy: Always  
```

#### Side Container

**Side Containe**r: side container run before the main pod and after the initialisation processing continue to run

### Autoscaling

#### Horizontal pod autoscaling

**Horizontal pod autoscaling:** automatically horizontal scale application

```bash
kubectl autoscale deployment my-app # provision horizontal autoscaler
```

#### Vertical pod autoscaling

Vertical **pod autoscaling:** automatically vertical scale application

```bash
kubectl apply -f https://github.com/kubernetes/autoscaler/releases/latest/download/vertical-pod-autoscaler.yaml
```

## Cluster Maintenance

### Os upgrade

**Drain node**: recreate all pod from a node to another

```bash
kubectl drain node-name ## drain node
kuebctl cordon node-name ## make node unschedable
kuebctl uncordon node-name ## undrain node
```

### Cluster Upgrade

**Upgrade policy:** 1 minor version at time, k8s support 3 older version at every newer

```bash
## Upgrade with kubeadm
kubeadm upgrade plan  # return upgrade plan
kubeadm upgrade apply # upgrade 

## Manually upgrade
# done for every component
apt-get upgrade -y kubelet01.12.0-00
systemctl restart kubelet
```

## Security

**Secure Hos**t: secure on the physical nodes

### Authentication

**Authentication**: Who can access

**User**: humans → manage by third part , ldap, file, …

**Service account**: process, service, application → manage in k8s

```bash
kubectl create sa nomesa  ## create service account
kubectl get sa
```

#### Authentication to api server

**Static password file**: file csv with username, password, userid, passed to kube-apiserver with —basic-auth-file property on the startup of kube-apiserver.

```bash
# authentication
curl -v -k https://master-node-ip:6443/api/v1/pods -u "user1:password"
```

Token file: file token, user, userid passed to kube-apiserver with —token-auth-file property on the startup of kube-apiserver.

```bash
# authentication
curl -v -k https://master-node-ip:6443/api/v1/pods --header "Authorization: Bearer token"
```

### Tls

#### Key and Certificates

**Directory .ssh/authorized_keys**: contiene chiavi pubbliche autorizzate all’accesso sistema

**Directory /etc/ssl/certs/ca-certificates.crt:** contiene certificati

**Naming convention**:

- *.crt*.pem → certificate (public key)
- *-key.pem*.key → private key

```bash
# generate certificate with new key
openssl req -newkey rsa:4096  -x509  -sha512  -days 365 -nodes -out certificate.pem -keyout privatekey.pem

# read pem certificate
openssl x509 -noout -in certificate.pem -text

# read public key
openssl x509 -pubkey -noout -in certificate.pem

# sign key
echo '@cert-authority *.example.com' $(cat CA.pub) >> ~/.ssh/known_hosts
ssh-keygen -s CA -I user -n user -V +55w  id_ed25519.pub
```

[SSH Certificate Authorities and Key Signing - Documentation](https://docs.rockylinux.org/guides/security/ssh_ca_key_signing/#:~:text=Creating%20a%20user%20SSH%20key%20and%20signing%20it%3A,signing%20it%3A%20%5Buser%40rocky%20~%5D%20%24%20scp%20user%40rocky-vm.example.com%3A%2Fetc%2Fssh%2Fssh_host_ed25519_key.pub%20.)

[How to create Self-Signed CA Certificate with OpenSSL | GoLinuxCloud](https://www.golinuxcloud.com/create-certificate-authority-root-ca-linux/)

#### Tls in k8s

Server side:

- **Kube-Apiserver**: has apiserver.crt and private key
- **Etcd-server**: has etcdserver.crt and private key
- **kubelet-server**: has kubeletserver.crt and private key

Client side:

- **Client**: request certificate and private key to api server for authenticate es admin.crt admin.key
- **Scheduler-client**: request certificate and private key to api server for authenticate es scheduler.crt scheduler.key
- **kube-controller-manager**: request certificate and private key to api server for authenticate es controller.crt controller.key
- **kube-proxy**: request certificate and private key to api server for authenticate es proxy.crt proxy.key

Only client for etcd:

- **Kube-Apiserver:** use is keypair or generate newer

**CA Authority of cluster**: sign certificates

### Certificate Api

**Certificate Api**: api for manage ca and key

Controller manager: responsible for sign ca

#### Sign request

1. Create key

```bash
openssl genrsa-out name.key 2048 # create key
```

1. Request new key

```bash
openssl req -new -key name.key -subj "/C" # -subj "/C" is the common name associate with the reuqest (pc name)
# output name.csr
```

1. Request sign in k8s

```bash
cat name.csr | base64
```

```yaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSignRequest
metadata:
 name: name
spec:
 expirationSeconds: 600
 usages:
 - digital signature
 - key enciphermet
 - server auth
 request:
  <base64 of csr>
```

1. Approve request

```bash
kubectl certificate approve name
```

1. Decode certificate

```bash
kubectl get csr name -o yaml
echo "abse65 certificate" | base64 --decode
```

### Kubeconfig

**Clusters**: all clusters → contains ca and server ip for every cluster

**Users**: user that access to cluster (existing user) → contains private key and ca for access

**Contexts**: which user to which cluster

```yaml
apiVersion: v1
kind: Config

clusters:
- name: my-cluster
 cluster:
  server: <cluster-ip>
  certificate-authority: <my crt>
  # certificate-authority-data: base64 of crt
contexts:
- name: my-admin@my-cluster

users: 
- name: my-admin
 user:
  client-certificate: <my-crt>
  client-key: <my-key>
```

```bash
kubectl config view # view current config
kubectl config use-context <name>
```

**kubectl proxy:** proxy that inject ca, keys, and config info in the kubectl command

### Authorization

#### Role base Authorization

**Role base access control:** assign role to user and assign permission to role

**Role**: define a role with the permissions

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: pod-reader
rules:
# simple permission for watch get and list pods
- apiGroups: [""] # "" indicates the core API group
  resources: ["pods"] # resource of the permission
  verbs: ["get", "watch", "list"] # operations
```

**RoleBindings**: bind a role to a user in a namespace

```yaml
apiVersion: rbac.authorization.k8s.io/v1
# This role binding allows "jane" to read pods in the "default" namespace.
# You need to already have a Role named "pod-reader" in that namespace.
kind: RoleBinding
metadata:
  name: read-pods
  namespace: default
subjects:
# You can specify more than one "subject"
- kind: User
  name: jane # "name" is case sensitive
  apiGroup: rbac.authorization.k8s.io
roleRef:
  # "roleRef" specifies the binding to a Role / ClusterRole
  kind: Role #this must be Role or ClusterRole
  name: pod-reader # this must match the name of the Role or ClusterRole you wish to bind to
  apiGroup: rbac.authorization.k8s.io
```

```bash
 kubectl auth can-i <operation> <resource>            # check if my user can perform action
 kubectl auth can-i <operation> <resource> --as user  # check if my user can perform action as user
```

#### ClusterRole Based Authorization

**ClusterRole**: role cluster based

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  # "namespace" omitted since ClusterRoles are not namespaced
  name: secret-reader
rules:
- apiGroups: [""]
  #
  # at the HTTP level, the name of the resource for accessing Secret
  # objects is "secrets"
  resources: ["secrets"]
  verbs: ["get", "watch", "list"]
```

**ClusterRoleBindings**: bind a user to a cluster role

```yaml
apiVersion: rbac.authorization.k8s.io/v1
# This cluster role binding allows anyone in the "manager" group to read secrets in any namespace.
kind: ClusterRoleBinding
metadata:
  name: read-secrets-global
subjects:
- kind: Group
  name: manager # Name is case sensitive
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: secret-reader
  apiGroup: rbac.authorization.k8s.io
```

#### Role vs ClusterRole

**ClusterRole vs Role**: role are namespace based

#### Node base Authorization

**Node authorization**: node authorization from node authoriser

#### Service Account

**Service account:** non-human user

**Token**: for authorization with the sa

```bash
kubectl create serviceaccount my-sa # create a token in a secret automatically with the sa
kubectl describe serviceaccount my-sa
kubectl create token serviceaccount-name
```

**Default Service account**: created for every namespace, automatically mount a token in every pod by calling the token api

```yaml
kind: Pod
spec:
 serviceAccountName: my-sa # specify sa used by the pod
 automountServiceAccountToken: false 
```

### Image Security

**Docker hub**: registry/usernameoraccount/imageorrepository

```bash
kubectl create secret docker-registry myregistry --docker-server=privateserver --docker-username=myuser --docker-password= my-password --docker-email=myemail 
```

```yaml
kind: Pod
spec:
 containers:
 imagePullSecrets:
 - name: my-secret
```

### Network Security

**Default Network Security:** allow all port communication from everywhere

Network Policy: overwrite default policy for a pod

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
 name: my-policy
spec:
 podSelector:
  matchLabels:
   mylabel: label
 policyTypes:
 - Ingress # ingress, ingress from others # egress, egress to others
 ingresses:
 - from:
  - podSelector:
    matchLabels:
     name: labelwhoingresstomypod
  - nameSpaceSelector: # from which namespace
     matchLabels:
     name: prod
  - ipBlock: # from which ips
    cidr: 192.168.5.10/32
  ports:
  - protocol: TCP
   port: 8080
```

### Tools

#### Kubectx

**kubectx:** easy switch between context

```bash
kubectx # list all context
kubectx nameofcontext # change context
kubectx - # go to rpevious context
kubectx -c # see current context
```

#### Kubens

**Kubens:** easy switch between namespace

```bash
kubens <new_namespace> # switch to namespace
```

### Custom resource definition

**Custom resource definition**: define custom api

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  # name must match the spec fields below, and be in the form: <plural>.<group>
  name: crontabs.stable.example.com
spec:
  # group name to use for REST API: /apis/<group>/<version>
  group: stable.example.com
  # list of versions supported by this CustomResourceDefinition
  versions:
    - name: v1
      # Each version can be enabled/disabled by Served flag.
      served: true
      # One and only one version must be marked as the storage version.
      storage: true
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              properties:
                cronSpec:
                  type: string
                image:
                  type: string
                replicas:
                  type: integer
  # either Namespaced or Cluster
  scope: Namespaced
  names:
    # plural name to be used in the URL: /apis/<group>/<version>/<plural>
    plural: crontabs
    # singular name to be used as an alias on the CLI and for display
    singular: crontab
    # kind is normally the CamelCased singular type. Your resource manifests use this.
    kind: CronTab
    # shortNames allow shorter string to match your resource on the CLI
    shortNames:
    - ct
```

**Custom resource**: object created with the configuration of the crds, saved in etcd

```yaml
apiVersion: "stable.example.com/v1" # group and version of crds
kind: CronTab
metadata:
  name: my-new-cron-object
spec:
  cronSpec: "* * * * */5"
  image: my-awesome-cron-image
```

### Custom controller

**Custom Controller:** monitor and define the behaviour of a custom resource

### Operator Framework

**Operator**: treating k8s application like a single object and not a collection of files

**Use cases**: automate day1(installation, configuration) and day2(manage, backup, restore ,recover) operations

**Operator Framework:** Orchestrate and manage operator

## Storage

### Container Storage Interface

**Container Storage Interface (CSI):** interface for abstract orchestration of volume

### Volume

**Volume:** shared filesystem between containers in the same pod or between pods, durable

```yaml
kind: Pod
spec:
  containers:
  - name: my-container
    image: alpine
    volumeMounts:
    - mountPath: /opt # path where volume is mounted
      name: my-volume # name of mìvolume
 volumes:
 - name: my-volume
   hostPath:
    path: /data # path in the volume with the data
    type: Directory
```

### Persistent volume

**PV**: piece of storage provisioned by the cluster or a storage classes

### Persistent volume

**PVC:** claim of the storage with a request of storage class, storage required, storage type ecc

Delete of PVC:

- **Retain**: remain until manually deleted
- **Delete**: delete automatically storage
- **Recycle**: available to other claim

### Storage classes

**Storage classes**: dynamically provisioning of storage on cloud provider

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
 name: google-storage
provisioner: kubernetes.io/gce-pd
```

```yaml
apiVersion: v1
kind: PersistentVolumeCLaim
metadata:
 name: myclaim
spec:
  accessModes:
 - ReadWriteOnce
  storageClassName: google-storage
  resources:
   requests: 
    storage: 500Mi
```

```yaml
apiVersion: v1
kind: Pod
metadata:
 name: name
spec: 
  containers:
  - name: alpine
   image: alpine
   volumeMounts:
   - mountPath: /opt
    name: my-volume
 volumes:
 - name: my-volume
   persistentVolumeClaim:
   claimName: myclaim
```

## Networking

### Linux command

**Network switch**: hardware for create a network between computer

**Ip link**: list all network connectivity of the device

```bash
ip link
```

**Ip addr add**: add ip to newtork

```bash
 ip link add [ link DEVICE ] [ name ] NAME
               [ txqueuelen PACKETS ]
               [ address LLADDR ] [ broadcast LLADDR ]
               [ mtu MTU ]
               [ numtxqueues QUEUE_COUNT ] [ numrxqueues QUEUE_COUNT ]
               type TYPE [ ARGS ]
```

**Routing: connect** two network (switch are network) together

```bash
route
```

**Gateway**: door for the network from the internet

```bash
ip route add {NETWORK/MASK} via {GATEWAYIP}
ip route add {NETWORK/MASK} dev {DEVICE}
```

**Ping:** command for try to reach a device in the network

```bash
ping <ip>
```

### Dns

file **/etc/hosts:** file for configure dns names

```
example:
192.168.1.1 router
127.0.0.1 localhost
```

file **/etc/resolv.conf** file for configure nameserver

```
nameserver 10.255.255.254
```

file **/etc/nsswitch.conf** fie for configure the first file to check for resolve ip  (nameserver or local)

```
# cosa          # ordine in cui li cerca
passwd:         files systemd
group:          files systemd
shadow:         files systemd
gshadow:        files systemd

hosts:          files dns
networks:       files

protocols:      db files
services:       db files
ethers:         db files
rpc:            db files

netgroup:       nis
```

**nslookup:** comand for query host name from dns server

```bash
nslookup <dns-server>
```

**dig:** advanced info about dns server

```bash
dig dns server
```

### Network namespace

**Network namespace**: isolate network component in a linux system, create an independent network with his own routing table, ips, device ecc

```bash
ip netns # check all namespaces
ip netns add <name-namespace> # add a new namespace
```

```bash
ip netns exec <namespace-name> <command to exec> # execute network command in a namespace
```

### Container Network Interface

**Container Network Interface CNI;** interface that standard network configuration accross different technologies

**/opt/cni/bin** directory with network plugin binary (source code)

**/etc/cni/net.d** specify which plugin with which configuration to use

Cni plugin is responsible of provisioning ip

### Cluster Networking

Every node have his own:

- ip address
- mac address
- host name

All nodes are in the same network

Ports Opens:

- etcd: 2379
- etcd client: 2380
- kube-api 6443
- kubelet: 1025
- scheduler: 10259
- controll-manager: 10257

### Pod networking

Every pod have his own:

- ip address
- mac address
- host name

Pod should comunicate with all pod in:

- same node
- other node without nat

### Weave Cni

**1 Agent in each node**: store network information of the node and his pods, agent are bridged (link different bridge network in one)

Encapsulate packet in a new packet

**10.32.0.0/12** ip from which weave assign ips

### Flannel Cni

Flannel Cni don’t support network policy

### Calico Cni

Calico Cni  support network policy

### Service

#### Cluster Ip

**Cluster Ip**: expose the pod within the cluster in all nodes, the service has his own ip

#### Nodeport

**Nodeport**: node port expose application outside of the cluster through a port exposed by the nodes (same for all node), service has his own ip

#### Kube-proxy

**Kube-proxy**: every time a service is create, setup networking

Proxy modes:

- **ip tables**: table | service-ip | forward-to |

### Dns

#### Basic of Dns

Hierarchy: root → type (svc or pod)→ namespace →hostname→ ip

| Ip | Hostname | Namespace | Type | Root |
| --- | --- | --- | --- | --- |
| <frontend-service-ip> | frontend | web-app | svc | cluster.local |
| <frontend-service-ip> | frontend-pod | web-app | pod | cluster.local |

**Resolve dns full:** http://<hostname>.<namespace>.<type>.<root>

#### Core Dns

**Core Dns**: implementation of dns in k8s like a central server pod and exposed with service

Every pod has in **/etc/resolv.conf** the ip of the coredns nameserver

Core dns server has a **/etc/hosts** file

**/etc/coredns/Corefile** configuration file of core dns

### Ingress

**Ingress**: make application accessible with a single url, layer 7 load balancer within the cluster, with rules

#### Splitting traffic for rule

```yaml
spec:
 rules:
 - http:
   paths:
   - path: /wear
     pathType: Prefix
    backend:
     service:
      name: wear-service
      servicePort: 80
   - path: /watch
     pathType: Prefix
    backend:
     service:
        name: watch-service
      port: 80
```

#### Splitting traffic for hostname

```yaml
spec:
 rules:
 - host: wear.my-online-store.com
  http:
   paths:
   - path: /wear
    pathType: Prefix
    backend:
     service:
      name: wear-service
      servicePort: 80
 - host: watch.my-online-store.com
  http:
   paths:
   - path: /watch
     pathType: Prefix
    backend:
     service:
        name: watch-service
      port: 80
```

### Ingress controller

**Ingress controller**: load balancer, reverse proxy to application based on ingress rules

#### Deploy ingress controller

1. Deployment of ingress controller (for example nginx)
2. Service nodeport for expose ingress controller on 80 and 443
3. Config map with configuration of ingress controller
4. Service account, ClusterRole, Role, Role binding with the permission for monitor the cluster

#### Nginx rewrite

**nginx.ingress.kubernetes.io/rewrite-target:** with this annotation the request is forwarded to the backend service like specified in the rewrite-target and not like the request

example without **nginx.ingress.kubernetes.io/rewrite-target**:

`http://<ingress-service>:<ingress-port>/watch` --> `http://<watch-service>:<port>/watch`

example with “**nginx.ingress.kubernetes.io/rewrite-target: / “**

`http://<ingress-service>:<ingress-port>/watch` --> `http://<watch-service>:<port>/`

example with “**nginx.ingress.kubernetes.io/rewrite-target: /hello “**

`http://<ingress-service>:<ingress-port>/watch` --> `http://<watch-service>:<port>/`hello

### Gateway api

**Gateway api**: level 4 level 7 routing, next generation api k8s native

**Gateway class**: interface of how gateway should be implemented (by gateway controller)

```yaml
apiVersion: gateway.networking.k8s.io/v1beta1
kind: GatewayClass
metadata:
  name: nginx-gateway-class
spec:
  controllerName: nginx.org/gateway-controller # nginx gateway controller on the cluster
```

**Gateway:** implementation of gateway

```yaml
apiVersion: gateway.networking.k8s.io/v1beta1
kind: Gateway
metadata:
  name: nginx-gateway
  namespace: default
spec:
  gatewayClassName: nginx-gateway-class
  listeners:
  - name: http
    port: 80
    protocol: HTTP
```

**HTTPRoute / TCPRoute / GRPCRoute:** routing rules

```yaml
apiVersion: gateway.networking.k8s.io/v1beta1
kind: HTTPRoute
metadata:
  name: myapp-route
spec:
  parentRefs:
  - name: nginx-gateway
  rules:
  - matches:
    - path:
        value: /myapp
    backendRefs:
    - name: myapp-service
      port: 8080
```

### Gateway api vs ingress

Gateway api is more flexible and divide responsibility between developer, infrastructure maintainer and application developer

## Install a cluster the hard way

[https://github.com/kelseyhightower/kubernetes-the-hard-way](https://github.com/kelseyhightower/kubernetes-the-hard-way)

## Install a cluster with kubeadm

1. multiple nodes (virtual or physical)
2. container runtime in the host
3. kubeadm in all the nodes
4. init master
5. setup pod network
6. join worker to master node

## Helm

### Basic

**Helm Charts:** collection of k8s files

**Release**: single installation of an app with helm charts

**Revision**: version of the release (application)

**Metadata**: keep track of revision, and other data about charts deployed → saved as a secret in k8s (central versioning)

**artifact-hub**: charts repository

### Helm cli

```bash
helm --help
```

```bash
helm install [release-name] [chart-name]
helm install --values [my-values-file] [release-name][chart-name]

```

```bash
helm uninstall [release-name]
```

```bash
helm upgrade [release-name] [chart-name]
```

```bash
helm rollback [release-name] [revision number]
```

```bash
helm history [release-name]
```

### Charts Directory Structure

```
my-chart
 templates/     # directory with template files
 environments/  # different values per environment
 values.yaml    # configure values
 Chart.yaml     # chart information
 LICENSE        # chart license
 README.mc      # readme
 charts         # dependency charts
```

## Kustomize

### Basic

**Kustomize**: easy manage of multi-environment k8s config files → built in kubectl

**Base**: configuration identical for all environment

```yaml
# base
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
```

**Overlays**: overlay some properties for each environment

```yaml
# overlays/dev
spec:
 replicas: 1
 
# overlays/stg
spec:
 replicas: 2
 
# overlays/prod
spec:
 replicas: 5
```

### Folder Structure

```
k8s/
|_ base/
|_ overlays/
  |- dev/
  |- stg/
  |_ prod/
```

### Kustomize.yaml

**kustomize.yaml**: file for instruct kustomize

```yaml
# kustomize.yaml

# file managed by kustomized
resource: 
 - nginx-deployment.yaml
 - nginx-service.yaml

# what to change
commonLabels:
 company: My-company
spec: 
 replicas: 1
```

### Commands

**Kustomize build:** comand for apply transformation

```bash
kustomize build [directory-with-files]
```

Apply configuration

```bash
kustomize build [directory-with-files] | kubectl apply -f -
```

## Troubleshooting

### App failure

Check pods logs, if the name in the yaml are right, use describe command

### Control Plane failure

1. Check node status

```bash
kubectl get nodes
```

1. Check pods in kubesystem

```bash
kubectl get pods -n kube-system
```

1. check service status

```bash
service [service-name] status
service kube-apiserver status
```
