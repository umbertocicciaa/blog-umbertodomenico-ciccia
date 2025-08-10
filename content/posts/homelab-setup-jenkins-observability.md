---
title: "My Raspberry Pi K3s Adventure: Installing Jenkins, Grafana & Prometheus with Helm"
date: 2025-08-10T16:20:00+02:00
author: "Umberto Domenico Ciccia"
tags: ["raspberry-pi", "k3s", "jenkins", "grafana", "prometheus", "helm", "devops", "homelab"]
description: "A hands-on story of how I installed Jenkins, Grafana, and Prometheus on my Raspberry Pi K3s cluster using Helm — with all the wins, struggles, and lessons learned."
---

## 🚀 Why I Started This Project

You know that feeling when you’ve just unboxed a couple of Raspberry Pi boards and your mind races with all the possibilities? That was me.  
Two Raspberry Pi 4s, a mini rack, and a network switch were staring at me, and the idea hit:  
**“Let’s build a K3s cluster, and on top of it run Jenkins, Grafana, and Prometheus.”**  

Not for production — but for learning, for fun, and for the sheer thrill of watching tiny computers act like a mini data center.

---

## 🛠️ The Cluster Setup

First things first, I set up **K3s** on my Raspberry Pi nodes. I used one Pi as the master and the other as a worker node.

## 🔧 Installing Jenkins with Helm (The Persistent, Ingress-Ready Way)

When I started setting up Jenkins, I didn’t want to just spin it up temporarily — I wanted **real persistence** for my jobs and configurations, proper **RBAC** with a Service Account, and an **Ingress** so I could access it without endless port-forwards.

So I followed the official [Jenkins Kubernetes documentation](https://www.jenkins.io/doc/book/installing/kubernetes/) step-by-step, adapting it for my Raspberry Pi K3s environment.

### Step 1 — Create a PersistentVolume

I created a local path PV on my master node so Jenkins could store all its data:

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: jenkins-pv
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /data/jenkins
````

Applied it with:

```bash
kubectl apply -f jenkins-pv.yaml
```

in `values.yaml`:

```yaml
persitance:
  storageClass: jenkins-pv
```

*(Lesson learned: local PVs on Raspberry Pi mean “don’t wipe that SD card” unless you enjoy starting over.)*

---

### Step 2 — Create a Service Account

Jenkins needs proper permissions to manage pods and builds inside the cluster.

```yaml
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: jenkins
  namespace: jenkins
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: jenkins
rules:
- apiGroups:
  - '*'
  resources:
  - statefulsets
  - services
  - replicationcontrollers
  - replicasets
  - podtemplates
  - podsecuritypolicies
  - pods
  - pods/log
  - pods/exec
  - podpreset
  - poddisruptionbudget
  - persistentvolumes
  - persistentvolumeclaims
  - jobs
  - endpoints
  - deployments
  - deployments/scale
  - daemonsets
  - cronjobs
  - configmaps
  - namespaces
  - events
  - secrets
  verbs:
  - create
  - get
  - watch
  - delete
  - list
  - patch
  - update
- apiGroups:
  - ""
  resources:
  - nodes
  verbs:
  - get
  - list
  - watch
  - update
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: jenkins
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: jenkins
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: system:serviceaccounts:jenkins
```

```bash
kubectl apply -f jenkins-sa.yaml
```

in `values.yaml`:

```yaml
serviceAccount:
  create: false
  name: jenkins
```

---

### Step 3 — Customize Helm Values for Ingress

I didn’t want to rely on `kubectl port-forward` forever, so I enabled an Ingress in my Helm values file.

`values.yaml`:

```yaml
  controller:  
    jenkinsUriPrefix: "/jenkins"
  ingress:
    enabled: true
    paths:
      - path: "/jenkins"
        pathType: "Prefix"
        backend:
          service:
            name: "jenkins"
            port:
              number: 8080
    apiVersion: "networking.k8s.io/v1"
    ingressClassName: traefik
```

---

### Step 4 — Install Jenkins via Helm

```bash
helm repo add jenkins https://charts.jenkins.io
helm repo update
helm install jenkins jenkins/jenkins -f values.yaml
```

---

### Step 5 — Access Jenkins

Since I had Ingress enabled, I just updated my local `/etc/hosts`:

```
<MASTER_NODE_IP>  jenkins.local
```

Now Jenkins is available at:

```
http://jenkins.local
```

Get the admin password:

```bash
kubectl exec --namespace jenkins -it svc/jenkins -c jenkins \
  -- /bin/cat /run/secrets/additional/chart-admin-password
```

---

💡 **What I Learned:**

* The “quick install” is fine for demos, but taking the time to set up PV, RBAC, and Ingress makes your deployment feel *real*.
* On Raspberry Pis, **persistence is precious** — one SD card failure can wipe out your CI/CD brain.
* Ingress saved me from juggling `kubectl port-forward` commands and made Jenkins feel like part of a real infrastructure.

---

## 📊 Installing Prometheus & Grafana

Prometheus and Grafana are best friends — metrics and visualization.

### Add repo

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

### Install Prometheus

```bash
helm install prometheus prometheus-community/prometheus --namespace monitoring --create-namespace
```

### Install Grafana

```bash
helm install grafana grafana/grafana --namespace monitoring
```

### Access Grafana

Get admin password:

```bash
kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode
```

Forward port:

```bash
kubectl port-forward svc/grafana 3000:3000 -n monitoring
```

Open: `http://localhost:3000`

---

## 🧠 The Challenges I Faced

1. **ARM Compatibility:** Some container images just *don’t* have ARM builds. I had to check chart values and override image tags for ARM64 versions.
2. **Resource Limits:** 4GB Pi RAM is not a lot — tweaking memory requests/limits in Helm values was necessary to avoid OOM kills.
3. **Networking:** A single misconfigured `LoadBalancer` service in K3s can stall everything. Switching to `NodePort` during testing helped.
4. **Pod Start Time:** On Pis, be ready for *minutes* of startup time for heavier apps like Jenkins.

---

## 🌱 What I Learned

* **Helm is magic** — one command and you’ve got a whole app running in Kubernetes.
* **Small hardware teaches big discipline** — limited resources force you to think about efficiency.
* **Metrics are addictive** — once Grafana dashboards light up with Prometheus data, you want to monitor everything.

---

## 🎯 Final Thoughts

Was it overkill to run Jenkins, Prometheus, and Grafana on Raspberry Pis?
Absolutely.

Did I learn more in a weekend than in a month of theory?
**Also absolutely.**

If you’ve got some Raspberry Pis gathering dust, set them free — make them work, make them struggle, make *yourself* debug at 2AM because a pod won’t start. That’s where the magic happens.

---

💬 *Have you tried something similar? Share your Raspberry Pi Kubernetes war stories with me.*
