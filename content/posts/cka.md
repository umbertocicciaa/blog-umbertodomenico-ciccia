---

title: "How I Passed the CKA (Certified Kubernetes Administrator) Exam"
date: 2025-08-27
draft: false
searchable: true
slug: how-i-passed-cka
tags: ["Kubernetes", "CKA", "Certification", "DevOps", "Cloud Native"]
description: "My step-by-step study plan, practice routine, and exam-day strategy for earning the CKA."
---

I’ve just passed the **CKA**. 🎉 Here’s exactly how I prepared, what I practiced, how I set up my terminal, and the mindset I used on exam day. No spoilers, no NDA violations—just the process that worked for me.

## TL;DR

* Learn by doing: daily labs > passive videos.
* Automate muscle memory: aliases, completion, templates.
* Use `kubectl explain` + `--dry-run=client -o yaml` to avoid YAML typos.
* Be ruthless with time: solve, verify, move on, return later.

---

## My 4-Week Study Plan

### Week 1 — Core Workloads & Kubectl

* Pods, Deployments, DaemonSets, Jobs/CronJobs
* Services (ClusterIP/NodePort/LoadBalancer), Probes, ConfigMaps, Secrets
* Hands-on: create → tweak → roll back → scale

### Week 2 — Cluster Admin Basics

* Control plane components, kubelet & static Pods, kubeadm basics
* Node ops: **cordon/drain/uncordon**, taints/tolerations
* Backups (etcd snapshot/restore concepts), upgrades flow

### Week 3 — Networking & Storage

* CNI basics, NetworkPolicies, Ingress
* StorageClasses, PV/PVC, CSI, access modes, reclaim policies

### Week 4 — Security & Troubleshooting

* RBAC (Roles, ClusterRoles, Bindings), ServiceAccounts
* Scheduling (affinity/anti-affinity, topology spread), resources/limits
* Troubleshooting: events/logs, image pulls, CrashLoopBackOff, DNS

**Daily rhythm:** 60–90 min labbing + 15–30 min notes + quick review of mistakes.

---

## Practice Environment

Use a local cluster to iterate fast:

```bash
# kind
kind create cluster --name cka

# or minikube
minikube start

# verify
kubectl get nodes -o wide
kubectl get pods -A
```

Keep a **scratch directory** per task and commit small, verifiable changes.

---

## Terminal & Editor Setup (My “Speed Kit”)

```bash
# 1) Alias + namespace/context helpers
alias k=kubectl
complete -F __start_kubectl k

# namespace/context
k config get-contexts
k config use-context <ctx>
k config set-context --current --namespace=<ns>

# 2) Fast YAML scaffolding
k create deploy web --image=nginx --dry-run=client -o yaml > deploy.yaml
k create service clusterip web --tcp=80:80 --dry-run=client -o yaml >> deploy.yaml
k apply -f deploy.yaml

# 3) Default editor
export KUBE_EDITOR=vim   # or nano
```

**Pro tips**

* Prefer imperative → YAML (`--dry-run=client -o yaml`) then adjust fields.
* Use `kubectl explain <resource> --recursive | less` to discover fields and API versions.
* Verify everything: `k get ... -o wide`, `k describe ...`, `k logs ...`, `k events --watch`.

---

## My “CKA Muscle Memory” Cheat Sheet

```bash
# Namespaces
k get ns
k -n <ns> get all
k config set-context --current --namespace=<ns>

# Workloads
k create deploy app --image=nginx --replicas=3
k set image deploy/app app=nginx:1.25
k rollout status deploy/app
k rollout undo deploy/app

# Services & Ingress
k expose deploy app --port=80 --target-port=80 --type=ClusterIP
k get svc
# (Ingress usually from YAML template)

# Probes
k set probe deploy/app --readiness --get-url=http://:80/ --initial-delay-seconds=5

# Scheduling
k taint nodes node1 key=value:NoSchedule
k label node node1 disk=ssd
# affinity/anti-affinity via YAML

# Node ops
k drain node1 --ignore-daemonsets --delete-emptydir-data
k uncordon node1

# Storage
k get sc
k get pv,pvc

# NetworkPolicy (start from template, then edit)
# Troubleshooting
k describe pod <p>
k logs <p> [-c <container>]
k get events -A --sort-by=.lastTimestamp
```

---

## How I Practiced (Without Burning Out)

* **Rebuild small labs quickly.** Re-create workloads from scratch until commands feel automatic.
* **Error diary.** Every failure gets a one-line entry: *“missed namespace,” “wrong apiVersion,” “forgot selector.”* Review this list daily.
* **Time-boxed drills.** 5–10 minute sprints: *“Deploy app + Service + readiness probe.”*

---

## Exam-Day Strategy (High Level, No NDA Stuff)

1. **Read the whole task once.** Note the namespace, context, and resource names.
2. **Set context and namespace immediately.**

   ```bash
   k config use-context <context-from-task>
   k config set-context --current --namespace=<ns-from-task>
   ```

3. **Scaffold → apply → verify.** Imperative to YAML, edit, `k apply -f`, then `k get/describe/logs`.
4. **Validate early and often.** If a task expects a Service/label/annotation, *prove it exists*.
5. **Bookmark hard tasks.** Don’t stall—come back with fresh eyes.
6. **Leave time to re-verify.** A quick sweep at the end can earn easy points.

---

## Common Pitfalls I Avoided

* **Wrong namespace.** I always set it on the current context and double-checked with `k config view --minify`.
* **Mismatched selectors.** I compared Deployment labels vs. Service selectors every time.
* **Outdated apiVersion.** I used `kubectl explain` to confirm the right version (e.g., `apps/v1`).
* **Over-editing YAML.** I generated templates first to reduce indentation mistakes.
* **Heavy-handed deletes.** I avoided `--force`/`--grace-period=0` unless explicitly required.

---

## Lightweight Templates I Reused

**Deployment + Service**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
        - name: web
          image: nginx:1.25
          ports:
            - containerPort: 80
          readinessProbe:
            httpGet:
              path: /
              port: 80
---
apiVersion: v1
kind: Service
metadata:
  name: web
spec:
  type: ClusterIP
  selector:
    app: web
  ports:
    - port: 80
      targetPort: 80
```

**NetworkPolicy (deny-all, then allow from a pod label)**

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
spec:
  podSelector: {}
  policyTypes: ["Ingress","Egress"]
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-from-app
spec:
  podSelector:
    matchLabels:
      app: web
  ingress:
    - from:
        - podSelector:
            matchLabels:
              access: "true"
```

---

## Resources I Found Helpful

* The official **Kubernetes documentation** (use it constantly while practicing).
* A solid **CKA course** to structure topics and labs.
* A **practice exam/lab platform** to simulate pressure and timing.
* Your own **notes and one-liners**—the fastest reference you’ll have.

> Tip: Before the exam, review the current exam policies and allowed resources on the CNCF/LF pages to avoid surprises.

---

## Final Thoughts

CKA rewards **hands-on fluency**. If you can create, inspect, and fix Kubernetes resources quickly—while staying calm—you’re already most of the way there. Build muscle memory, keep a tight feedback loop, and treat the exam as a series of small, verifiable tasks.

If you want, I can tailor this post with your exact timeline, tools, or favorite resources—just share a few details and I’ll weave them in.
