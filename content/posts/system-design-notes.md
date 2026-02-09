---
date: '2026-02-09T12:00:00+02:00'
title: 'System Design Fundamentals'
description: "Comprehensive notes on system design fundamentals: scaling, caching, networking, APIs, proxies, load balancing, storage, and more."
tags: ["system-design", "scalability", "caching", "load-balancing", "databases", "networking", "api", "notes"]
categories: ["Engineering"]
searchable: true
---

## Basic Application Architecture

### Developer Perspective

A typical application is composed of:

- **Build & Deploy Layer** — CI/CD pipeline
- **Server Layer** — handles incoming requests
- **Storage Layer** — persists application data (can be external)
- **Logging Storage Server** — logs all events
- **Metric Storage Server** — logs all metrics
- **Alert Server** — alerts when something goes down

### User Perspective

Users simply make requests to the server and receive responses.

---

### Scaling

- **Vertical Scaling:** add more physical resources (CPU, RAM) to a single server
- **Horizontal Scaling:** add more servers to distribute the load
- **Load Balancer:** distributes traffic between multiple servers

![Horizontal Scaling with Load Balancer](/blog-umbertodomenico-ciccia/images/system-design-notes/scaling.png)

---

## Design Requirements

### How We Handle Data

| Concern | Description |
|---|---|
| **Move data** | Data moves between servers in different parts of the world |
| **Store data** | How we persist our data |
| **Transform data** | Transforming data to answer queries or perform computations |

### Metrics for Evaluating Our Design

**Availability** — measures uptime of a system:

$$\text{Availability} = \frac{\text{uptime}}{\text{uptime} + \text{downtime}}$$

Example:

$$\frac{23 \text{ hours}}{23 \text{ hours} + 1 \text{ hour}} = 96\%$$

**SLI** — Service Level Indicator: measures performance of a system

**SLO** — Service Level Objective: target goals for SLI (e.g., 99.9% availability)

**SLA** — Service Level Agreement: contracts with customers for SLO

**Reliability** — measures the probability of a system failing

**Fault Tolerance** — measures how much our system can continue working under failure

**Redundancy** — measures how much our system is replicated

**Throughput** — measures the number of operations in a time frame:

$$\text{Throughput} = \frac{\text{operations}}{\text{time}} = \frac{\text{queries}}{\text{seconds}} = \frac{\text{bytes}}{\text{seconds}}$$

**Latency** — measures how long it takes to complete a request

---

## Networks

### Basics

| Concept | Description |
|---|---|
| **Packages** | Encapsulate data to be transferred over the network |
| **IP Address** | Virtual identification of a host |
| **MAC Address** | Physical identification of a host |
| **NAT** | Translates public IP to private within a LAN. Devices in a LAN have their own private IPs and access the internet using a single public IP |
| **Port Forwarding** | Network technique that enables external users to access specific services on a private, local network |

![NAT and Port Forwarding](/blog-umbertodomenico-ciccia/images/system-design-notes/port-forwarding.png)

**Router** — sends packages across the network

### Basic Protocols

| Protocol | Description |
|---|---|
| **HTTP** | Exchange hyper-text information |
| **SSH** | Remote connection to a host |
| **TCP** | Stateful communication, 3-way handshake, congestion handling, retransmission of lost packages |
| **UDP** | Non-stateful communication, no guarantees |

---

## API Design

### Client-Server Model

- **Client** — accesses information provided by a server
- **Server** — provides resources

![Client-Server Model](/blog-umbertodomenico-ciccia/images/system-design-notes/client-server.png)

### RPC — Remote Procedure Call

The RPC model allows a program to execute code in a different machine or address space.

![RPC Remote Procedure Call](/blog-umbertodomenico-ciccia/images/system-design-notes/rpc.png)

Key concepts:
- **Stub** — function proxy on both local and remote server
- **Marshalling** — packaging parameters into a message ready to be sent
- **Unmarshalling** — unpacking parameters from the received message

### HTTP / HTTPS

**HTTP** is the protocol for client-server communication. **TLS/SSL** encrypts traffic between client and server.

**Methods:**

| Method | Purpose |
|---|---|
| GET | Retrieve resources |
| POST | Create resources |
| PUT | Update/replace resources |
| DELETE | Remove resources |

**Status Codes:**

| Range | Meaning |
|---|---|
| 1xx | Informational |
| 2xx | Successful |
| 3xx | Redirection |
| 4xx | Client Error |
| 5xx | Server Error |

> **Cons:** HTTP is not ideal for real-time data exchange

### WebSockets

WebSockets establish a persistent, full-duplex connection between client and server — unlike REST where each request creates a new connection.

![WebSocket Communication](/blog-umbertodomenico-ciccia/images/system-design-notes/websocket.png)

**Pros:**
- Bi-directional communication
- Great for real-time data (chat, live feeds)
- Supports server push and polling

### API Paradigms

#### REST
- **Stateless** — server doesn't maintain session state
- **Pagination** — page through resources
- **Cacheable** — responses can be cached
- **Resource-identified** — resources have unique URIs, exchanged in JSON
- **Layered** — client and server are decoupled; can talk to replicas transparently

#### GraphQL
- Uses only **POST** requests
- Body contains queries for fetching data
- Less cacheable compared to REST

#### gRPC
- Typically used for **server-to-server** communication
- Implements RPC with schema-defined data
- **Faster** than REST
- Supports **bi-directional streaming**
- Uses exceptions instead of status codes
- Built on **HTTP/2**

### API Design Best Practices

**API Contract** — defines the structure of your API

**Handling API changes:**
- **Adding parameters** → make them optional
- **Removing parameters** → can break external customers

**Pagination** — limit the number of returned objects:
```
GET https://api.example.com/v1/users/:id/tweets?limit=10&offset=0
```

**HTTP Idempotency** — making the same request multiple times produces the same effect:

| Method | Idempotent? |
|---|---|
| GET | ✅ Yes |
| PUT | ✅ Yes |
| DELETE | ✅ Yes |
| POST | ⚠️ Depends on implementation |

---

## Caching

### Basics of Cache

| Term | Description |
|---|---|
| **Cache Hit** | Data is found in cache |
| **Cache Miss** | Data is not in cache or is expired |
| **Cache TTL** | Maximum time data can stay in cache |
| **Cache Stale** | Maximum age of expired data |

**Cache Hit Ratio:**

$$\text{Cache Ratio} = \frac{\text{hits}}{\text{hits} + \text{misses}}$$

### Client-Side Caching

1. Check **memory cache** first
2. Cache miss → check **disk cache**
3. Cache miss → make **network request**

### Server-Side Caching Strategies

#### Read Through

![Read Through Cache](/blog-umbertodomenico-ciccia/images/system-design-notes/cache-read-through.png)

Best for **read-heavy** systems: CDNs, social media feeds, user profiles.

#### Cache Aside (Lazy Loading)

![Cache Aside](/blog-umbertodomenico-ciccia/images/system-design-notes/cache-aside.png)

Data is stored in cache **only when needed**. Best for systems with high **read-to-write** ratio (prices, descriptions, stock status).

#### Write Around

![Write Around Cache](/blog-umbertodomenico-ciccia/images/system-design-notes/cache-write-around.png)

Only frequently accessed data resides in cache. Best for **write-heavy systems** where data is not immediately read (logging systems).

#### Write Through

![Write Through Cache](/blog-umbertodomenico-ciccia/images/system-design-notes/cache-write-through.png)

DB and cache are kept **in sync**. Best for **consistency-critical systems** — financial applications, online transaction processing.

#### Write Back

![Write Back Cache](/blog-umbertodomenico-ciccia/images/system-design-notes/cache-write-back.png)

Writes go to cache first, then **asynchronously flushed** to the database. Ideal for **write-heavy** scenarios where immediate consistency isn't critical (logging, social media feeds).

#### Strategies Summary

![Caching Strategies Summary](/blog-umbertodomenico-ciccia/images/system-design-notes/cache-summary.png)

### Cache Eviction Policies

**Eviction Policies** determine which elements are removed when the cache is full.

#### FIFO (First In, First Out)
Implemented with a **queue**. The oldest item is evicted first.

#### LRU (Least Recently Used)

![LRU Cache](/blog-umbertodomenico-ciccia/images/system-design-notes/lru-cache.png)

Uses a **Hash Map** + **Doubly Linked List**:
- Hash Map: key → pointer to a node in the linked list
- Doubly Linked List: maintains access order (head = most recently accessed)

#### LFU (Least Frequently Used)

Uses two maps and a frequency tracker:
- `key_map`: key → node
- `freq_map`: frequency → doubly linked list of nodes
- `min_freq`: integer tracking the minimum frequency

```
            key_map
    ┌────────────────────┐
    │ A → Node(freq=3)   │
    │ B → Node(freq=1)   │
    │ C → Node(freq=1)   │
    │ D → Node(freq=2)   │
    └─────────┬──────────┘
              │
              ▼
          freq_map
┌─────────────────────────────────┐
│  freq = 1 → [HEAD ⇄ C ⇄ B ⇄ TAIL] │
│              ↑MRU   ↑LRU           │
│  freq = 2 → [HEAD ⇄ D ⇄ TAIL]     │
│  freq = 3 → [HEAD ⇄ A ⇄ TAIL]     │
└─────────────────────────────────┘
  min_freq = 1
```

---

## CDN (Content Delivery Network)

**CDN Servers** are groups of static content cache servers placed **close to end users** for low latency.

### Push CDN

The origin server **pushes** data to CDN edge nodes proactively.

![Push CDN](/blog-umbertodomenico-ciccia/images/system-design-notes/push-cdn.png)

### Pull CDN

CDN edge nodes **pull** data from the origin server on cache miss.

![Pull CDN](/blog-umbertodomenico-ciccia/images/system-design-notes/pull-cdn.png)

---

## Proxies

**Proxies** are a middle layer between client and server.

![Proxy Overview](/blog-umbertodomenico-ciccia/images/system-design-notes/proxy-overview.png)

### Forward Proxy

![Forward Proxy](/blog-umbertodomenico-ciccia/images/system-design-notes/forward-proxy.png)

- **Client identity is hidden** from the server
- Proxy can **cache results** and **filter traffic**
- Protects the **client**

### Reverse Proxy

![Reverse Proxy](/blog-umbertodomenico-ciccia/images/system-design-notes/reverse-proxy.png)

- **Server identity is hidden** from the client
- Proxy forwards requests to the **correct backend server**
- Handles **SSL termination** and **caching**
- Protects the **servers**

### SSL Termination

SSL connection ends at the proxy. Internal traffic from proxy to server uses plain HTTP.

![SSL Termination](/blog-umbertodomenico-ciccia/images/system-design-notes/ssl-termination.png)

### SSL Pass Through

All traffic remains encrypted end-to-end. The proxy forwards encrypted traffic without decrypting.

---

## Load Balancer

A **load balancer** is a reverse proxy that distributes traffic to backend servers.

### Round Robin

Requests cycle through servers in order: A → B → C → A → B → C...

![Round Robin](/blog-umbertodomenico-ciccia/images/system-design-notes/round-robin.png)

### Weighted Round Robin

Same circular pattern, but servers with higher **weight** receive proportionally more traffic.

![Weighted Round Robin](/blog-umbertodomenico-ciccia/images/system-design-notes/weighted-round-robin.png)

### Least Connections

Routes new requests to the server with the **fewest active connections**.

![Least Connections](/blog-umbertodomenico-ciccia/images/system-design-notes/least-connections.png)

### User Location

Routes based on the user's **geographic location** for lowest latency.

### Regular Hashing

Same IP always maps to the same server:

$$\text{Dest-Server} = \text{Client-IP} \mod N_{\text{servers}}$$

![Regular Hashing](/blog-umbertodomenico-ciccia/images/system-design-notes/regular-hashing.png)

> **Problem:** If a server goes down, **all** hash mappings need to be recalculated.

### Consistent Hashing

Servers and keys are mapped onto a **hash ring**. Keys route clockwise to the nearest server. When a server is removed, only its keys are redistributed.

![Consistent Hashing](/blog-umbertodomenico-ciccia/images/system-design-notes/consistent-hashing.png)

### Layer 4 vs Layer 7 Load Balancing

| Type | Level | Speed | Intelligence |
|---|---|---|---|
| **Layer 4** | Transport (TCP/UDP) | Faster | Basic routing |
| **Layer 7** | Application (HTTP) | Slower | Content-aware routing |

---

## Storage

### RDBMS (Relational Databases)

**SQL** is the language to query relational databases. Data is stored in **tables** on disk.

#### B+ Tree Index

Relational databases implement indexing using **B+ Trees** for O(log n) I/O operations.

![B+ Tree](/blog-umbertodomenico-ciccia/images/system-design-notes/bplus-tree.png)

Key properties:
- Every node can have **m** children
- Each node has **m-1** values
- Data is stored **only on leaf nodes**
- Leaf level forms a **sorted linked list**
- Root/internal nodes are used to efficiently locate data on leaf nodes

#### Table Structure

![SQL Table](/blog-umbertodomenico-ciccia/images/system-design-notes/sql-table.png)

**Data Schema** defines how data is structured:

```sql
CREATE TABLE People (
    PhoneNumber int PRIMARY KEY,
    Name varchar(100)
);
```

**Foreign Keys** link two tables together. **Joins** combine tables based on conditions.

#### ACID Properties

| Property | Description |
|---|---|
| **Atomicity** | Transaction is all-or-nothing. If any step fails, the entire transaction rolls back |
| **Consistency** | Transactions only bring the DB from one consistent state to another |
| **Isolation** | Concurrent transactions execute as if running in isolation |
| **Durability** | Once committed, data persists even after system failure (stored on disk) |

### NoSQL

| Type | Description | Examples |
|---|---|---|
| **Key-Value** | Stores data as key-value pairs | Redis, Memcached, etcd |
| **Document** | Stores data as JSON documents | MongoDB |
| **Wide-Column** | Stores data in columns instead of rows | Cassandra, Google Bigtable |
| **Graph** | Stores data as relationships between objects | Neo4j |

#### BASE Properties

| Property | Description |
|---|---|
| **Basically Available** | All users can access the database concurrently |
| **Soft State** | Data can have multiple intermediate states |
| **Eventually Consistent** | Consistency is achieved once all replicas are updated |

#### Eventually Consistent vs Strict Consistency

**Eventually Consistent:** Client writes to the master node and receives ACK immediately. The master node updates slaves **asynchronously**.

![Eventually Consistent](/blog-umbertodomenico-ciccia/images/system-design-notes/eventual-consistency.png)

**Strictly Consistent:** Data is written to the master and **immediately copied** to all slaves. Client receives ACK only after all slaves confirm.

![Strict Consistency](/blog-umbertodomenico-ciccia/images/system-design-notes/strict-consistency.png)

### Replication and Sharding

#### Synchronous Replication
Master replicates data on slaves **at write time**. Used when **critical consistency** is needed.

#### Asynchronous Replication
Master replicates data on slaves **later**. Used when consistency can be **eventually** achieved.

#### Master-Master Replication
Multiple masters replicate each other and each replicates its own slaves. Ideal for **multi-region** setups with one master per region.

#### Sharding

**Sharding** divides data into partitions based on a **shard key**.

![Database Sharding](/blog-umbertodomenico-ciccia/images/system-design-notes/sharding.png)

**Use cases:** massive, high-traffic systems

- **Relational databases** — sharding is done at the application level
- **NoSQL databases** — horizontal scaling per shard

### CAP Theorem

![CAP Theorem](/blog-umbertodomenico-ciccia/images/system-design-notes/cap-theorem.png)

| Property | Description |
|---|---|
| **Consistency** | All replicas see the same data |
| **Availability** | System works under failure |
| **Partition Tolerance** | System continues operating with network partitions |

> Systems can guarantee **only two** of the three properties at the same time.
