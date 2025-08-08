---
date: '2025-08-08T23:32:20+02:00'
title: 'Building a Raspberry Pi 4 K3s Cluster'
description: "How I built a 2-node Raspberry Pi 4 cluster with K3s, deployed my homepage, and exposed it via the default ingress class."
tags: ["k3s", "kubernetes", "k8s", "devops", "homelab", "homeserver", "homepage"]
---

## Introduction

After some tinkering in my homelab, I decided to build a **2-node Raspberry Pi 4 cluster** running [K3s](https://k3s.io/) — one **master** and one **worker** — to learn Kubernetes and host my own services.  
In this post, I’ll walk you through the process: from **hardware setup** to **K3s installation** and **homepage deployment** with ingress access.

---

## Hardware Setup

Here’s the base hardware I used:

- **2× Raspberry Pi 4** (4GB RAM each)
- **Mini rack** with dual fans for cooling
- **Gigabit network switch**
- **Ethernet cables**
- **Personal PC** (used as a **proxy** to manage the cluster)
- **Raspberry Pi OS** installed on both Pis (SSH enabled)

The Raspberry Pis are connected to the switch, and my DHCP server handles:

- **Static IP assignment** for each Pi
- **Hostnames** for `rpi-master`, `rpi-worker`, and `proxy-pc`

---

## Network & SSH Configuration

With Raspberry Pi OS installed, I enabled SSH:

```bash
sudo systemctl enable ssh
sudo systemctl start ssh
````

From my proxy PC, I can connect to each Pi:

```bash
ssh pi@rpi-master.local
ssh pi@rpi-worker.local
```

---

## Installing K3s

### Master Node

On the master (`rpi-master`):

```bash
curl -sfL https://get.k3s.io | sh -
```

This starts the K3s server and generates a join token.

### Worker Node

On the worker (`rpi-worker`):

```bash
curl -sfL https://get.k3s.io | K3S_URL=https://rpi-master:6443 \
K3S_TOKEN=<your-join-token> sh -
```

You can find the join token on the master at:

```bash
sudo cat /var/lib/rancher/k3s/server/node-token
```

---

## Verifying the Cluster

From the master:

```bash
sudo k3s kubectl get nodes
```

You should see both master and worker nodes in **Ready** state.

---

## Smoke Test Deployment

To ensure everything works, I deployed a simple test pod:

```bash
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --type=ClusterIP --port=80
kubectl get svc
```

Pods and services deployed correctly — smoke test passed.

---

## Accessing the Cluster from My Proxy PC

I copied the `kubeconfig` from the master to my proxy PC:

```bash
scp pi@rpi-master:/etc/rancher/k3s/k3s.yaml ~/.kube/config
```

Then updated the server address in `~/.kube/config` to point to `rpi-master`’s LAN IP.

---

## Deploying Homepage

I deployed my **homepage** application and service:

```bash
kubectl apply -f homepage-deployment.yaml
kubectl apply -f homepage-service.yaml
```

---

## Exposing Homepage via Ingress

Using the default ingress class of K3s (Traefik).

After updating my `/etc/hosts` on my proxy PC:

```
192.168.1.50 homepage.local
```

I could access the homepage via:

- **HTTP:** `http://homepage.local`
- **HTTPS:** `https://homepage.local`

---

## Demo

![Hardware](/blog-umbertodomenico-ciccia/images/homelab/hardware.png)
![Homepage](/blog-umbertodomenico-ciccia/images/homelab/homepage.png)
![Smoketest proxy](/blog-umbertodomenico-ciccia/images/homelab/smoketest-proxy.png)
![Smoketest k3s cluster](/blog-umbertodomenico-ciccia/images/homelab/smoketestnginx.png)
![Smoketest k3s cluster](/blog-umbertodomenico-ciccia/images/homelab/smoketestnodes.png)

## Next Steps

I plan to expand the cluster’s observability:

- Deploy **Grafana**
- Deploy **Prometheus**
- Set up metrics and dashboards

---

## Conclusion

This small but mighty Raspberry Pi 4 cluster now runs K3s with ingress routing and serves my homepage over HTTPS. It’s a perfect foundation for homelab experiments and a stepping stone toward more advanced Kubernetes workloads.

If you want to check out my configuration files, head over to my [homelab-utils repo](https://github.com/umbertocicciaa/homelab-utils) *(when it’s back online!)*.

---
