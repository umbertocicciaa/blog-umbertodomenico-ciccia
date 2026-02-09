---
date: '2026-02-09T18:00:00+02:00'
title: 'Computer Networks: A Comprehensive Guide'
description: "In-depth notes on computer networking: the OSI and TCP/IP models, data link and MAC layers, IP addressing, routing algorithms, transport protocols (TCP/UDP), application protocols (HTTP, DNS, SMTP, FTP), network security, NAT, DHCP, P2P systems, and more."
tags: ["networking", "tcp-ip", "osi", "routing", "http", "dns", "tcp", "udp", "security", "notes"]
categories: ["Engineering"]
searchable: true
math: true
---

## Introduction

Computer networks are the backbone of modern computing. Every time you browse a website, send an email, or stream a video, you rely on a complex stack of protocols, algorithms, and hardware working together. This post is a comprehensive guide to how computer networks work — from the physical transmission of bits to the application-layer protocols you use daily.

We will walk through the layered network models (OSI and TCP/IP), dive into each layer's responsibilities, explore routing and addressing, examine transport-layer reliability, and cover essential application-layer protocols. We will also touch on security, cloud computing, peer-to-peer systems, and distributed architectures like blockchain.

---

## 1. Network Models

### 1.1 The ISO/OSI Reference Model

The **ISO/OSI (Open Systems Interconnection)** model was created to solve the problem of interoperability between systems from different vendors. It divides network communication into **7 layers**, each with a specific responsibility:

| Layer | Name | Responsibility |
|-------|------|----------------|
| 7 | **Application** | Provides network services directly to user applications |
| 6 | **Presentation** | Data formatting, encryption, compression, and translation |
| 5 | **Session** | Manages dialog between systems (establishment, suspension, termination) |
| 4 | **Transport** | Reliable end-to-end delivery, flow control, congestion control |
| 3 | **Network** | Logical addressing (IP), routing, and accounting |
| 2 | **Data Link** | Framing, error detection, flow control, and MAC-level access |
| 1 | **Physical** | Transmission of raw bits over the physical medium |

Each layer communicates with its peer layer on the remote system and provides services to the layer above it.

### 1.2 The TCP/IP Model

The **TCP/IP model** is the practical model used on the Internet. It collapses the OSI layers into **4 layers**:

| TCP/IP Layer | Corresponding OSI Layers | Key Protocols |
|---|---|---|
| **Application** | Application + Presentation + Session | HTTP, FTP, SMTP, DNS |
| **Transport** | Transport | TCP, UDP |
| **Internet** | Network | IP, ICMP |
| **Network Access (Host-to-Network)** | Data Link + Physical | Ethernet, Wi-Fi |

> **Key difference from OSI:** TCP/IP does not distinguish between the physical and data link layers, nor does it have separate presentation and session layers. It is a simpler, more pragmatic model.

---

## 2. Protocols and Data Units

### 2.1 What is a Protocol?

A **protocol** is a set of rules governing the transfer of data between entities in different systems. Protocols define:

- **Syntax** — the structure and organization of bits (format of messages)
- **Semantics** — the meaning of each bit sequence
- **Timing** — when and at what speed data should be sent

### 2.2 Data Units at Each Layer

Each layer wraps (encapsulates) data from the layer above with its own header:

| Layer | Data Unit Name |
|---|---|
| Application | **Message** |
| Transport | **Segment** (TCP) / **Datagram** (UDP) |
| Network | **Datagram** (IP Packet) |
| Data Link | **Frame** |
| Physical | **Bits** |

### 2.3 Encapsulation

**Encapsulation** is the process where each layer receives data from the layer above, adds its own header (and sometimes a trailer), and passes the result down. At the receiving end, each layer strips its header and passes the payload upward.

```
┌─────────────────────────────────────────────┐
│ Application Data (Message)                  │
├──────────┬──────────────────────────────────┤
│ TCP Hdr  │ Application Data                 │  ← Segment
├──────────┼──────────┬───────────────────────┤
│ IP Hdr   │ TCP Hdr  │ Application Data      │  ← Datagram
├──────────┼──────────┼──────────┬────────────┤
│ Frame Hdr│ IP Hdr   │ TCP Hdr  │ App Data   │  ← Frame
└──────────┴──────────┴──────────┴────────────┘
```

---

## 3. The Data Link Layer

The data link layer is responsible for node-to-node delivery of frames over a single link.

### 3.1 Core Functions

- **Framing** — organizes raw bits into logical units called frames
- **Error detection and correction** — ensures data integrity
- **Flow control** — prevents a fast sender from overwhelming a slow receiver

### 3.2 Framing

Frames are delimited using special sequences:

- **Flag byte:** `01111110` marks the start and end of each frame
- **Bit stuffing:** during transmission, if five consecutive `1` bits appear in the data, a `0` is inserted to avoid confusion with the flag. The receiver removes the stuffed bits.

### 3.3 Error Detection

Several techniques are used to detect errors:

| Method | How it works |
|---|---|
| **Checksum** | Sum all bits in the message; include the checksum in the frame. If the receiver's computed checksum differs from the received checksum → error detected. |
| **CRC (Cyclic Redundancy Check)** | Treats data as a polynomial and divides it by a generator polynomial. If the remainder is 0 → no error. More robust than simple checksum. |

### 3.4 Flow Control

Flow control prevents the receiver's buffer from overflowing.

#### Stop-and-Wait

The simplest approach:

1. Sender transmits one frame
2. Sender starts a timer and **waits** for an ACK
3. If ACK received → send next frame
4. If timeout expires → retransmit

```
Sender                          Receiver
  │── Frame (SN=0) ──────────────►│
  │                                │
  │◄────────────── ACK (SN=0) ────│
  │                                │
  │── Frame (SN=1) ──────────────►│
  │         ✕ (lost)               │
  │     ⏱ timeout                  │
  │── Frame (SN=1) ──────────────►│  (retransmit)
  │◄────────────── ACK (SN=1) ────│
```

**Problem:** very low utilization — the sender is idle while waiting for ACKs.

#### Sliding Window Protocols

To improve utilization, sliding window protocols allow the sender to transmit **multiple frames** before receiving an ACK:

**Go-Back-N:**
- Sender window size = N; receiver window size = 1
- If a frame is lost or corrupted, the receiver discards it and all subsequent frames
- The sender retransmits the lost frame **and all frames that followed it**
- Uses **cumulative ACKs**

**Selective Repeat:**
- Sender window size = N; receiver window size = N
- The receiver buffers out-of-order frames
- Only the **specific lost frame** is retransmitted
- More efficient but requires more buffer space at the receiver

#### Piggybacking

When data flows in **both directions**, ACKs can be included ("piggybacked") inside data frames going in the opposite direction, reducing overhead.

### 3.5 The HDLC Protocol

**HDLC (High-Level Data Link Control)** is a bit-oriented protocol for the data link layer.

**Modes of operation:**

| Mode | Description |
|---|---|
| **NRM (Normal Response Mode)** | Master/slave, half-duplex. Slave can only transmit when the master permits. |
| **ARM (Asynchronous Response Mode)** | Master/slave, full-duplex. Slave does not need permission to transmit. |
| **ABM (Asynchronous Balanced Mode)** | Peer-to-peer, full-duplex. No master. Both sides can initiate. |

**Frame format:**

```
┌──────┬─────────┬─────────┬──────┬──────┬──────┐
│ Flag │ Address │ Control │ Data │  FCS │ Flag │
└──────┴─────────┴─────────┴──────┴──────┴──────┘
```

- **Flag** — `01111110`, start/end delimiter (with bit stuffing)
- **Address** — physical address of the secondary station
- **Control** — frame type: Information (I), Supervisory (S), or Unnumbered (U)
- **FCS** — Frame Check Sequence for error detection
- **Connection lifecycle:** SABM (establish) → Data transfer → DISC (disconnect)

---

## 4. The MAC Layer (Medium Access Control)

When multiple stations share the same transmission medium, a mechanism is needed to decide **who can transmit and when**. This is the job of the MAC sublayer.

### 4.1 MAC Addressing

- Every station has a unique **MAC address** that identifies it on the local network
- When a frame arrives, the station checks if the destination MAC address matches its own

### 4.2 The Collision Problem

When two or more stations transmit simultaneously on a shared medium, a **collision** occurs and the data is corrupted. MAC protocols exist to **avoid** or **resolve** collisions.

### 4.3 Static Allocation

Each station is assigned a **fixed time slot** (TDM) or frequency band (FDM):

- ✅ **No collisions**
- ❌ **Low channel utilization** — slots are wasted when a station has nothing to send
- ❌ **High delay** when many stations are connected

### 4.4 Dynamic Allocation — Controlled

Collisions are avoided through coordination:

**Round Robin (Polling):**
- Each station gets a turn to transmit; if it has nothing to send, the turn passes
- ✅ No collisions
- ❌ High overhead when many stations are idle

**Token Ring:**
- A special **token** frame circulates around the ring
- A station can only transmit when it holds the token
- After transmitting, it passes the token to the next station
- ✅ No collisions
- ❌ Low fault tolerance — if the token is lost, recovery is needed

### 4.5 Dynamic Allocation — Contention (Random Access)

Stations transmit whenever they have data, accepting that collisions may occur:

#### Pure ALOHA

- Packets are transmitted **as soon as they are generated**
- If a collision occurs, the station waits a **random** time and retransmits
- Requires an ACK for confirmation
- **Maximum throughput:**

$$S_{\max} = \frac{1}{2e} \approx 0.184 \text{ (18.4\%)}$$

#### Slotted ALOHA

- Time is divided into fixed **slots** of size equal to one frame transmission time
- Stations can only begin transmitting at the **start of a slot**
- Reduces collisions compared to Pure ALOHA
- Uses **exponential backoff**: after collision, wait a random time in $[0, 2^{\min(c, k)}]$ where $c$ is the collision count
- **Maximum throughput:**

$$S_{\max} = \frac{1}{e} \approx 0.368 \text{ (36.8\%)}$$

#### CSMA (Carrier Sense Multiple Access)

- **Listen before transmitting:** if the channel is busy, wait; if free, transmit
- Collisions can still happen due to **propagation delay** — two stations may both sense the channel as free and transmit simultaneously
- **Persistent strategies** determine behavior when the channel is busy (1-persistent, p-persistent, non-persistent)

#### CSMA/CD (Collision Detection)

- Used in **Ethernet (IEEE 802.3)**
- Stations **detect collisions during transmission** (not just after)
- When a collision is detected:
  1. Stop transmitting immediately
  2. Send a **jam signal** to notify all stations
  3. Apply **exponential backoff** before retransmitting

```
Station A                            Station B
    │── transmit ────────►               │
    │                    ◄── transmit ───│
    │        💥 COLLISION DETECTED 💥      │
    │── jam signal ──────────────────────│
    │   wait random time                 │
    │── retransmit ─────────────────────►│
```

---

## 5. The Network Layer (IP)

The network layer is responsible for **logical addressing** and **routing** packets from source to destination across multiple networks.

### 5.1 IP Datagram Format

The IPv4 datagram header contains the following key fields:

| Field | Description |
|---|---|
| **Version** | IP version (4 for IPv4) |
| **IHL (Internet Header Length)** | Length of the header (in 32-bit words) |
| **Type of Service (ToS)** | Requested QoS: high throughput, low delay, max reliability, etc. |
| **Total Length** | Total size of datagram (header + data). Minimum acceptable: 576 bytes. |
| **Identification** | Unique ID assigned by the sender for reassembly of fragmented datagrams |
| **Flags** | Control fragmentation: DF (Don't Fragment), MF (More Fragments) |
| **Fragment Offset** | Position of this fragment in the original datagram |
| **TTL (Time to Live)** | Decremented at each hop; packet is discarded when TTL = 0 |
| **Protocol** | Identifies the upper-layer protocol (TCP = 6, UDP = 17) |
| **Header Checksum** | Error detection for the header only |
| **Source / Destination Address** | 32-bit IP addresses |
| **Options + Padding** | Optional debugging info; padding to align to 32-bit boundary |

### 5.2 Fragmentation

When a datagram is larger than the **MTU (Maximum Transmission Unit)** of the next network it must cross, it is **fragmented** into smaller pieces:

- Each fragment gets a copy of the original header with updated **Total Length**, **Fragment Offset**, and **MF flag**
- **Reassembly** happens only at the final destination, using the **Identification**, **Fragment Offset**, and **Protocol** fields
- All routers must accept a minimum MTU of **576 bytes**

### 5.3 IP Addressing and Classes

IPv4 addresses are 32 bits long, traditionally divided into **classes**:

| Class | Leading bits | Network / Host bits | Range | Purpose |
|---|---|---|---|---|
| **A** | 0 | 8 net / 24 host | 0.0.0.0 – 127.255.255.255 | Large networks |
| **B** | 10 | 16 net / 16 host | 128.0.0.0 – 191.255.255.255 | Medium networks |
| **C** | 110 | 24 net / 8 host | 192.0.0.0 – 223.255.255.255 | Small networks |
| **D** | 1110 | — | 224.0.0.0 – 239.255.255.255 | Multicast |
| **E** | 1111 | — | 240.0.0.0 – 255.255.255.255 | Reserved (future use) |

**Special addresses:**
- `127.x.x.x` — loopback (localhost)
- Host bits all `0` — identifies the network itself
- Host bits all `1` — broadcast to all hosts on that network

### 5.4 Subnetting

**Subnetting** divides a network into smaller sub-networks using a **subnet mask**:

$$\text{IP Address} = \text{Network} + \text{Subnet} + \text{Host}$$

The subnet mask identifies which bits belong to the network/subnet and which belong to the host. For example, a Class C address `192.168.1.0/26` creates 4 subnets with 62 usable hosts each.

**ICMP Mask Request/Reply:** allows a system to discover the subnet mask of the network it is connected to.

### 5.5 ICMP (Internet Control Message Protocol)

ICMP is a supporting protocol for IP that carries **error messages** and **operational information**:

| Message Type | Purpose |
|---|---|
| **Echo Request / Reply** | Used by `ping` to test reachability |
| **Destination Unreachable** | Packet could not be delivered |
| **Time Exceeded** | TTL reached 0 (used by `traceroute`) |
| **Redirect** | Informs a host of a better route |
| **Mask Request / Reply** | Discover the subnet mask |

ICMP messages are encapsulated inside IP datagrams.

### 5.6 ARP (Address Resolution Protocol)

ARP translates a **logical (IP) address** into a **physical (MAC) address**:

1. Host A wants to send to Host B (knows B's IP, doesn't know B's MAC)
2. Host A broadcasts an **ARP Request**: "Who has IP X.X.X.X?"
3. Host B responds with an **ARP Reply** containing its MAC address
4. Host A caches the mapping in its **ARP table**

```
Host A                                   Host B
  │── ARP Request (broadcast) ──────────►│  "Who has 192.168.1.5?"
  │   src: MAC_A, IP_A                   │
  │   dst: FF:FF:FF:FF:FF:FF             │
  │                                      │
  │◄──────────────── ARP Reply (unicast) │  "192.168.1.5 is at MAC_B"
  │   src: MAC_B, IP_B                   │
```

---

## 6. Routing

### 6.1 Routing Tables

Every router maintains a **routing table** mapping destination networks to the next hop:

| Destination Network | Next Hop | Distance (optional) |
|---|---|---|
| 10.0.0.0/8 | 192.168.1.1 | 2 |
| 172.16.0.0/16 | 192.168.1.254 | 5 |
| 0.0.0.0/0 (default) | 192.168.1.1 | 1 |

**Static routing:** tables are configured manually by the network administrator.

**Dynamic routing:** tables are built and updated automatically via routing protocols.

**Default route:** used when no specific route matches the destination.

### 6.2 Autonomous Systems (AS)

The Internet is divided into **Autonomous Systems** — portions of the network under a single administrative authority with a unified routing policy.

- **Interior routers:** route within the same AS
- **Exterior (border) routers:** route between different ASes

### 6.3 Routing Algorithms

#### Dijkstra's Algorithm (Shortest Path First)

- Finds the **minimum-cost path** from a source node to all other nodes
- Requires **global knowledge** of the entire network topology
- Complexity: $O(V^2)$ (or $O(V \log V)$ with a priority queue)
- Incrementally adds the closest node at each step

#### Bellman-Ford Algorithm

- Computes minimum-cost paths by incrementally increasing the **number of hops**
- Only requires knowledge of **neighbors** (decentralized)
- Complexity: $O(V \cdot E)$
- Stops when no further improvements are found

### 6.4 Routing Protocols

#### Link-State Routing

- Each router floods **Link-State Packets (LSPs)** containing:
  - Router identifier
  - List of neighbors and link costs
  - Sequence number (for freshness)
- Every router builds a **complete topology database** and runs **Dijkstra's algorithm** locally
- Used in: **OSPF**, **IS-IS**

#### Distance Vector Routing

- Each router only knows the costs to its **immediate neighbors**
- Periodically shares its **distance vector** (a table of estimated costs to all destinations) with neighbors
- Neighbors update their own tables using the **Bellman-Ford equation**
- Used in: **RIP**, **BGP** (path-vector variant)

```
Router A's Distance Vector:
┌─────────────┬──────┬──────────┐
│ Destination │ Cost │ Next Hop │
├─────────────┼──────┼──────────┤
│ B           │  1   │  B       │
│ C           │  3   │  B       │
│ D           │  7   │  C       │
└─────────────┴──────┴──────────┘
```

---

## 7. The Transport Layer

The transport layer provides **end-to-end communication** between processes on different hosts.

### 7.1 Ports and Multiplexing

- Each process is identified by a **port number** (0–65535)
- **Multiplexing:** the sender gathers data from multiple application sockets, wraps each with transport headers (including source/destination ports), and sends them down
- **Demultiplexing:** the receiver uses the port numbers to deliver each segment to the correct application socket

**UDP demultiplexing:** identified by **(destination IP, destination port)** — connectionless; different senders to the same port share a socket.

**TCP demultiplexing:** identified by **(source IP, source port, destination IP, destination port)** — connection-oriented; each connection gets its own socket.

### 7.2 UDP (User Datagram Protocol)

UDP is a **minimal, connectionless** transport protocol:

- ❌ No connection setup
- ❌ No reliability guarantees
- ❌ No flow control or congestion control
- ✅ Low overhead
- ✅ Fast — suitable for real-time applications

**UDP Segment Format:**

```
┌──────────────┬──────────────┐
│ Source Port   │ Dest Port    │  (16 bits each)
├──────────────┼──────────────┤
│ UDP Length    │ Checksum     │
├──────────────┴──────────────┤
│         Application Data    │
└─────────────────────────────┘
```

- **Checksum:** computed over a **pseudo-header** (source IP, dest IP, protocol, length) + UDP header + data. Provides basic error detection.

### 7.3 TCP (Transmission Control Protocol)

TCP is a **connection-oriented, reliable** transport protocol that provides:

1. ✅ Reliable, in-order delivery
2. ✅ Flow control
3. ✅ Congestion control
4. ✅ Full-duplex communication

**TCP Segment Header:**

```
┌──────────────┬──────────────┐
│ Source Port   │ Dest Port    │
├──────────────┴──────────────┤
│       Sequence Number       │
├─────────────────────────────┤
│    Acknowledgment Number    │
├──────┬───┬──────┬───────────┤
│Offset│Res│Flags │  Window   │
├──────┴───┴──────┼───────────┤
│   Checksum      │Urgent Ptr │
├─────────────────┴───────────┤
│     Options + Padding       │
├─────────────────────────────┤
│           Data              │
└─────────────────────────────┘
```

**Key fields:**
- **Sequence Number** — byte number of the first data byte in this segment
- **Acknowledgment Number** — next byte expected from the other side
- **Window** — receiver's available buffer size (for flow control)
- **Flags** — SYN, ACK, FIN, RST, PSH, URG
- **Checksum** — covers pseudo-header + TCP header + data
- **Options** — e.g., MSS (Maximum Segment Size)

### 7.4 TCP Connection Management

#### Three-Way Handshake (Connection Establishment)

```
Client                              Server
  │                                    │  (LISTEN — passive open)
  │── SYN (seq=x) ───────────────────►│  1. Client sends SYN
  │                                    │
  │◄─────────── SYN+ACK (seq=y, ack=x+1)│  2. Server responds
  │                                    │
  │── ACK (seq=x+1, ack=y+1) ────────►│  3. Client confirms
  │                                    │
  │◄═══════ CONNECTION ESTABLISHED ═══►│
```

#### Connection Termination (Four-Way)

```
Client                              Server
  │── FIN ───────────────────────────►│  1. Client initiates close
  │◄──────────────────────── ACK ─────│  2. Server acknowledges
  │◄──────────────────────── FIN ─────│  3. Server sends its FIN
  │── ACK ───────────────────────────►│  4. Client acknowledges
  │         CONNECTION CLOSED          │
```

### 7.5 TCP Flow Control

Flow control ensures the sender does not overwhelm the receiver's buffer:

- The receiver advertises its available buffer size via the **Advertised Window (rwnd)** field
- The sender limits the amount of unacknowledged data to $\min(\text{cwnd}, \text{rwnd})$

**Sliding Window** mechanism:

- The **sender window** determines how many bytes can be sent without waiting for ACKs
- The **receiver window** shifts as data is consumed by the application

**Problem:** if the receiver's window drops to 0, the sender stops. The receiver sends a **Window Update** (or the sender uses a **probe** segment) to restart the flow.

$$\text{Throughput} \leq \frac{\text{Window Size}}{\text{RTT}}$$

### 7.6 TCP Error Recovery

- Every segment is verified via **checksum**
- If a segment is corrupted → it is silently discarded
- If a segment is not acknowledged within the **Retransmission Timeout (RTO)** → the sender retransmits it

Events that trigger retransmission:
1. **Timeout** — the RTO expires
2. **Three duplicate ACKs** — fast retransmit (see congestion control)

### 7.7 TCP Congestion Control

Congestion occurs when the network cannot handle the offered traffic, causing packet loss and increased delay.

#### Key Concepts

- **Congestion Window (cwnd):** limits the number of segments the sender can transmit
- **Allowed Window:** $W = \min(\text{cwnd}, \text{rwnd})$
- **Bottleneck:** the point in the network where congestion occurs (e.g., a router with a full buffer)

#### Symptoms of Congestion

- Packet loss (buffer overflow at routers)
- Increased round-trip times
- Timeout events

#### Slow Start

At the beginning of a connection (or after a timeout), cwnd starts small and **doubles every RTT** (exponential growth):

$$\text{cwnd} = \text{cwnd} \times 2 \quad \text{(for every ACK received)}$$

Growth continues until cwnd reaches the **slow start threshold (ssthresh)**.

#### Congestion Avoidance

Once cwnd ≥ ssthresh, growth becomes **linear** (additive increase):

$$\text{cwnd} = \text{cwnd} + 1 \quad \text{(for every RTT)}$$

#### On Timeout (Tahoe behavior)

1. Set $\text{ssthresh} = \frac{\text{cwnd}}{2}$
2. Set $\text{cwnd} = 1$ MSS
3. Restart with **Slow Start**

#### Fast Retransmit

- If the sender receives **3 duplicate ACKs** for the same segment, it retransmits the lost segment immediately **without waiting for a timeout**
- Assumption: duplicate ACKs indicate a single lost segment, not severe congestion

#### Fast Recovery (Reno behavior)

After fast retransmit:

1. Set $\text{ssthresh} = \frac{\text{cwnd}}{2}$
2. Set $\text{cwnd} = \text{ssthresh} + 3$ MSS
3. Enter **Congestion Avoidance** (skip Slow Start)

```
cwnd
  │
  │        ssthresh
  │ ─ ─ ─ ─ ┬─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─
  │         ╱│        ╱╲
  │        ╱ │       ╱  ╲  ← timeout
  │       ╱  │      ╱    ╲
  │      ╱   │     ╱      │
  │     ╱    │    ╱       │ new ssthresh
  │    ╱     │   ╱ ─ ─ ─ ─│─ ─ ─ ─ ─
  │   ╱      │  ╱         │╱
  │  ╱       │ ╱         ╱│
  │ ╱        │╱        ╱  │
  │╱  Slow   │  C.A.  ╱SS │  C.A.
  └──────────┴────────┴───┴──────────► time
```

#### TCP Variants Summary

| Variant | Features |
|---|---|
| **TCP Tahoe** | Slow Start + Congestion Avoidance + Fast Retransmit |
| **TCP Reno** | Tahoe + Fast Recovery |
| **TCP NewReno** | Reno + improved handling of multiple losses in one window |

---

## 8. Switching: Circuits vs. Packets

### 8.1 Circuit Switching

A **dedicated path** is established between sender and receiver for the entire duration of the communication:

- Resources are **reserved** (using TDM or FDM)
- ✅ Guaranteed bandwidth, constant delay
- ❌ Wasted resources when no data is being sent
- ❌ Setup time required before communication begins
- Example: traditional telephone networks

### 8.2 Packet Switching

Data is divided into **packets** that are sent independently through the network:

- Resources are used **on demand** (statistical multiplexing)
- ✅ Efficient use of bandwidth
- ✅ No setup time required
- ❌ Variable delay (queuing)
- ❌ Possible packet loss (buffer overflow)
- Example: the Internet

---

## 9. Internet Architecture

### 9.1 ISP Hierarchy

The Internet is structured in a **hierarchical** fashion:

- **Tier 1 ISPs** — global backbone providers (e.g., Cogent, Level 3), connected to all other Tier 1s
- **Tier 2 ISPs** — national/regional providers, connected to Tier 1 and peer with each other
- **Tier 3 ISPs** — local access providers (the ISPs end users connect to)

**IXP (Internet Exchange Point):** physical locations where ISPs interconnect and exchange traffic directly, reducing costs and latency.

### 9.2 Delays in a Network

| Type of Delay | Cause |
|---|---|
| **Processing delay** | Time to examine headers, check errors, determine output link |
| **Queuing delay** | Time waiting in the output buffer |
| **Transmission delay** | Time to push all bits onto the link = $\frac{L}{R}$ (packet length / link rate) |
| **Propagation delay** | Time for a bit to travel across the physical medium |

**Tools:**
- `ping` — measures round-trip time using ICMP Echo
- `traceroute` — discovers the path and per-hop delay by sending packets with increasing TTL

---

## 10. The Application Layer

### 10.1 Client-Server vs. Peer-to-Peer

**Client-Server Architecture:**
- **Server:** always-on host with a fixed (known) IP address
- **Client:** dynamic, initiates communication with the server
- Clients do not communicate directly with each other

**Peer-to-Peer (P2P) Architecture:**
- Peers communicate **directly** with each other
- No always-on server required
- Highly **scalable** — each new peer adds both demand and capacity
- Challenges: management, security, and reliability

### 10.2 HTTP (HyperText Transfer Protocol)

HTTP is the protocol for fetching web resources. It runs over **TCP** and is **stateless** (each request is independent).

**Request message format:**

```
METHOD /path/to/resource HTTP/1.1
Host: www.example.com
User-Agent: Mozilla/5.0
Accept: text/html
```

Common methods: `GET`, `POST`, `PUT`, `DELETE`, `HEAD`

**Response message format:**

```
HTTP/1.1 200 OK
Content-Type: text/html
Content-Length: 1234

<html>...</html>
```

#### Connection Types

| Type | Behavior |
|---|---|
| **Non-persistent** | A new TCP connection is opened for each request. Cost: 2 RTT + transfer time per object. |
| **Persistent** | A single TCP connection is reused for multiple requests. Reduces overhead. |

#### Cookies

HTTP is stateless, but **cookies** allow servers to maintain state across requests:
1. Server sends a `Set-Cookie` header in the response
2. Browser stores the cookie and sends it back with subsequent requests
3. Enables: sessions, personalization, tracking

#### Web Caching (Proxy Servers)

A **proxy server** (web cache) stores copies of recently requested resources:

- If the requested resource is **in the cache and fresh** → return it directly (cache hit)
- If the resource is **stale** or **not cached** → fetch from the origin server, cache it, and return
- **Conditional GET:** uses `If-Modified-Since` header; the server responds with `304 Not Modified` if unchanged

#### HTTPS

**HTTPS** is HTTP with encryption using **TLS/SSL**. It uses **public-key cryptography** to establish a secure channel, then encrypts data with symmetric keys.

### 10.3 FTP (File Transfer Protocol)

FTP transfers files between a client and a server. It is **stateful** — the server remembers the client's state (working directory, authentication).

- Uses **two TCP connections**:
  - **Control connection** (port 21): commands and responses
  - **Data connection** (port 20): actual file transfer
- Commands: `LIST`, `GET`, `PUT`, `STOR`, `RETR`
- Requires authentication (username/password)

### 10.4 Email Protocols

#### SMTP (Simple Mail Transfer Protocol)

SMTP is used to **send** email between mail servers:

- Runs over **TCP** (port 25)
- Uses a **three-phase handshake**: connection setup → message transfer → close
- Originally ASCII-only; **MIME** extensions allow multimedia attachments

**Email flow:**

```
Sender's Mail Agent (Outlook/Gmail)
        │
        ▼
Sender's Mail Server ──SMTP──► Recipient's Mail Server
                                        │
                                        ▼
                              Recipient's Mail Agent
                              (via POP3 or IMAP)
```

#### POP3 (Post Office Protocol v3)

- **Downloads and deletes** email from the server
- Simple, but no server-side message management

#### IMAP (Internet Message Access Protocol)

- **Manages email on the server** — create folders, search, mark as read
- Email stays on the server; client syncs
- More feature-rich than POP3

### 10.5 DNS (Domain Name System)

DNS translates **domain names** (e.g., `www.example.com`) into **IP addresses**.

**Hierarchical structure:**

```
                    Root (.)
                   ╱    │    ╲
              .com     .org    .it
             ╱    ╲           │
        google   example    uniroma
           │        │         │
         www      www       www
```

**Types of queries:**
- **Iterative:** each DNS server responds with the next server to query (the client does the work)
- **Recursive:** the DNS server queries on behalf of the client and returns the final answer

**DNS Caching:** resolved entries are cached for a **TTL (Time to Live)** to reduce future lookup times.

**DNS Record Types:**

| Type | Purpose |
|---|---|
| **A** | Maps hostname → IPv4 address |
| **AAAA** | Maps hostname → IPv6 address |
| **CNAME** | Alias for another hostname |
| **MX** | Mail exchange server for a domain |
| **NS** | Authoritative name server for a domain |

### 10.6 BitTorrent

BitTorrent is a **P2P file distribution protocol**:

1. A **torrent file** (or magnet link) contains metadata and the address of a **tracker**
2. The tracker keeps a list of peers participating in the swarm
3. The file is split into **chunks** (typically 256 KB each)
4. Peers download chunks from each other and simultaneously upload chunks they already have
5. **Rarest-first strategy:** peers prioritize downloading the rarest chunks first
6. **Tit-for-tat:** peers preferentially upload to those who upload to them (incentivizes sharing)

**Comparison of P2P file sharing approaches:**

| System | Discovery | Transfer | Characteristics |
|---|---|---|---|
| **Napster** | Centralized server | Direct P2P | Single point of failure |
| **Gnutella** | Decentralized flooding (with TTL) | Direct P2P | No central server; flooding can congest the network |
| **BitTorrent** | Tracker-based (or DHT) | Direct P2P | Efficient; incentivizes sharing |

### 10.7 File Distribution: Client-Server vs. P2P

**Client-Server download time:**

$$D_{CS} = \max\left(\frac{N \cdot F}{u_s},\ \frac{F}{d_{\min}}\right)$$

Where $N$ = number of clients, $F$ = file size, $u_s$ = server upload bandwidth, $d_{\min}$ = minimum client download bandwidth. **Scales linearly** with $N$.

**P2P download time:**

$$D_{P2P} = \max\left(\frac{F}{u_s},\ \frac{F}{d_{\min}},\ \frac{N \cdot F}{u_s + \sum u_i}\right)$$

Where $\sum u_i$ = total upload capacity of all peers. **Scales much better** because each new peer contributes upload capacity.

---

## 11. DHCP and NAT

### 11.1 DHCP (Dynamic Host Configuration Protocol)

DHCP **automatically assigns IP addresses** to hosts on a network:

1. **DHCP Discover** — host broadcasts a request for an IP address
2. **DHCP Offer** — server responds with an available IP
3. **DHCP Request** — host accepts the offered IP
4. **DHCP Acknowledge** — server confirms the assignment

```
Host                              DHCP Server
  │── DHCP Discover (broadcast) ─────►│
  │◄──────────────── DHCP Offer ──────│
  │── DHCP Request ──────────────────►│
  │◄──────────────── DHCP ACK ────────│
  │   Now configured with IP           │
```

### 11.2 NAT (Network Address Translation)

NAT allows multiple devices on a **local (private) network** to share a single **public IP address**:

- **Outgoing packets:** the router replaces the source private IP:port with its public IP:port
- **Incoming packets:** the router consults its **NAT table** to translate back to the correct private IP:port

**NAT Translation Table:**

| Private IP:Port | Public (Router) IP:Port |
|---|---|
| 192.168.1.10:3456 | 203.0.113.5:5001 |
| 192.168.1.20:7890 | 203.0.113.5:5002 |

**Advantages:**
- Conserves public IP addresses
- Hosts on the local network are hidden from the external network

**Disadvantages:**
- Violates the **end-to-end principle** (modifies packets in transit)
- Causes problems for protocols like P2P and SIP
- Operates at layer 3 but inspects layer 4 (port numbers)

### 11.3 Port Forwarding

When a server on the local network needs to be **reachable from the outside** (e.g., a web server):

- The router is configured to forward traffic on a specific port to a specific internal host
- The internal host must have a **static private IP**
- Example: forward port 80 on the public IP to 192.168.1.100:80

---

## 12. Network Security

### 12.1 Firewalls

A **firewall** is a combination of hardware and software that limits access to a network:

- Examines each incoming/outgoing packet against a set of **rules**
- **DMZ (Demilitarized Zone):** a network segment between the internal network and the Internet where public-facing servers reside

**Types of firewalls:**

| Type | How it works |
|---|---|
| **Packet filtering** | Inspects IP headers, ports, and protocols; decides allow/deny based on rules |
| **Application-level gateway (proxy)** | Establishes connections on behalf of internal clients; can inspect application data |

### 12.2 Common Attacks

| Attack | Description |
|---|---|
| **DoS (Denial of Service)** | Overwhelms a service with traffic to make it unavailable |
| **DDoS (Distributed DoS)** | DoS from many sources simultaneously |
| **IP Spoofing** | Forging the source IP address in packets |
| **SYN Flooding** | Sends many SYN packets without completing the three-way handshake, exhausting server resources |
| **Land Attack** | Sends a packet with the same source and destination IP/port |
| **UDP Flooding** | Floods random ports with UDP packets; server responds with ICMP "port unreachable" |
| **Smurf Attack** | Sends ICMP Echo Requests with a spoofed source to a broadcast address; all hosts reply to the victim |

**Defenses:**
- Ingress/egress filtering (block spoofed source IPs)
- Rate limiting
- SYN cookies
- Intrusion detection/prevention systems (IDS/IPS)

---

## 13. Cryptography Essentials

### 13.1 Symmetric Cryptography

The **same key** is used for encryption and decryption:

$$C = E_K(M) \quad\quad M = D_K(C)$$

| Algorithm | Description |
|---|---|
| **Caesar Cipher** | Shifts each letter by a fixed number (e.g., shift of 3: A→D). Easily broken by frequency analysis. |
| **Substitution Cipher** | Replaces each letter according to a substitution table. Vulnerable to frequency analysis. |
| **One-Time Pad** | Key is as long as the message and used only once. **Theoretically unbreakable** but impractical for most uses. |
| **DES** | 56-bit key; considered insecure today. Broken by brute force. |
| **AES** | Key sizes of 128, 192, or 256 bits with 10/12/14 rounds of permutation. Current standard. |

### 13.2 Asymmetric (Public-Key) Cryptography

Uses a **key pair**: a public key $K^+$ and a private key $K^-$:

- **Encryption:** $C = E_{K^+}(M)$
- **Decryption:** $M = D_{K^-}(C)$

The public key is shared openly; the private key is kept secret. It is computationally infeasible to derive $K^-$ from $K^+$.

**RSA Algorithm:**
1. Choose two large primes $p$ and $q$
2. Compute $n = p \times q$ and $z = (p-1)(q-1)$
3. Choose $e$ such that $\gcd(e, z) = 1$
4. Compute $d$ such that $e \cdot d \equiv 1 \pmod{z}$
5. Public key: $(n, e)$ — Private key: $(n, d)$
6. Encrypt: $C = M^e \bmod n$ — Decrypt: $M = C^d \bmod n$

### 13.3 Message Integrity and Hash Functions

A **hash function** $H$ produces a fixed-size **digest** from an arbitrary-length message:

- Used to verify that a message has not been altered in transit
- Must be **collision-resistant** — it should be computationally infeasible to find two different messages with the same hash

**MAC (Message Authentication Code):**

$$\text{MAC} = H(m + s)$$

Where $s$ is a shared secret. The receiver computes the MAC and compares it with the received value.

### 13.4 Digital Signatures

A **digital signature** proves the authenticity and integrity of a message:

1. Sender computes hash: $h = H(m)$
2. Sender encrypts hash with private key: $\text{sig} = E_{K^-}(h)$
3. Sender sends $m + \text{sig}$
4. Receiver decrypts signature with sender's public key: $h' = D_{K^+}(\text{sig})$
5. Receiver computes $H(m)$ and checks: $h' = H(m)$?

**Digital Certificates:** issued by a **Certificate Authority (CA)**, binding a public key to an entity's identity.

### 13.5 Secure Email (PEC)

**PEC (Posta Elettronica Certificata)** — Certified Email — provides:

- Proof of **sending** and **delivery**
- Legal validity equivalent to registered mail
- Uses digital signatures and timestamps

**Flow:**
1. Sender's mail client sends to the **sender's PEC provider**
2. Provider signs and timestamps the message, issues a **send receipt**
3. Message is delivered to the **recipient's PEC provider**
4. Recipient's provider issues a **delivery receipt** back to the sender
5. Both receipts have legal value

---

## 14. Cloud Computing

### 14.1 What is Cloud Computing?

Cloud computing delivers computing resources (servers, storage, databases, networking) **as a service** over the Internet.

**Key characteristics:**
1. **On-demand** — resources available when needed
2. **Broad network access** — accessible via the Internet
3. **Resource pooling** — shared infrastructure serving multiple tenants
4. **Rapid elasticity** — scale up/down automatically
5. **Measured service** — pay for what you use

### 14.2 Deployment Models

| Model | Description |
|---|---|
| **Public Cloud** | Resources shared among multiple tenants (AWS, Azure, GCP) |
| **Private Cloud** | Dedicated infrastructure for a single organization |
| **Hybrid Cloud** | Combination of public and private |

### 14.3 Service Models

| Model | What you manage | Examples |
|---|---|---|
| **IaaS** (Infrastructure as a Service) | OS, middleware, applications | EC2, GCE |
| **PaaS** (Platform as a Service) | Applications only | Heroku, App Engine |
| **SaaS** (Software as a Service) | Nothing — just use it | Gmail, Salesforce |

### 14.4 Virtualization

Virtualization is the foundation of cloud computing:

- **Hypervisor** — software that creates and manages virtual machines
- **Virtual Machine** — an emulated computer running its own OS on shared physical hardware

---

## 15. Distributed Systems

### 15.1 Distributed Hash Tables (DHT) — Chord

**Chord** is a protocol for a **peer-to-peer distributed hash table**:

- Each node and data item is assigned an **m-bit identifier** using consistent hashing
- Identifiers are arranged on a **circular ring** (modulo $2^m$)
- A key $k$ is stored on the first node whose ID is ≥ $k$ (the **successor**)

**Finger Table:**
- Each node maintains a table of $m$ entries
- Entry $i$ points to the successor of $(n + 2^i) \bmod 2^m$
- Enables lookups in $O(\log N)$ hops instead of $O(N)$

**Operations:**
- **Lookup:** route the query through the finger table, getting closer to the target at each hop
- **Node Join:** new node finds its successor, transfers relevant keys, and updates finger tables
- **Node Failure:** detected via periodic **stabilization** checks; successor lists provide redundancy

### 15.2 Blockchain

A **blockchain** is a distributed, decentralized database:

- Composed of a chain of **blocks**, each containing:
  - A set of **transactions**
  - A **hash** of the previous block (linking them together)
  - A **digital signature** (proof of integrity)
- **Immutability:** altering any block would change its hash, breaking the chain
- **Consensus:** new blocks are added via **Proof of Work** (miners solve a computational puzzle)
- **Decentralization:** every node maintains a complete copy of the blockchain

**Adding a new block:**
1. Transactions are broadcast to the network
2. Miners collect transactions and attempt to solve the proof-of-work puzzle
3. The first miner to solve it broadcasts the new block
4. Other nodes verify and add the block to their chain

---

## Conclusion

Computer networks are built on a beautifully layered architecture where each layer handles a specific concern — from the physical transmission of signals to the application protocols we interact with daily. Understanding these layers, their protocols, and how they interact is fundamental for anyone working in software engineering, cloud computing, or DevOps.

Key takeaways:

- **Layered models** (OSI, TCP/IP) provide abstraction and modularity
- **Error detection and flow control** at the data link layer ensure reliable local delivery
- **IP addressing and routing** enable global packet delivery
- **TCP** provides reliable transport with flow and congestion control
- **Application-layer protocols** (HTTP, DNS, SMTP) power the services we use every day
- **Security** through cryptography, firewalls, and digital signatures protects our data
- **Distributed systems** like DHTs and blockchains push the boundaries of decentralization

Whether you are debugging a network issue, designing a distributed system, or preparing for a certification, these fundamentals form the foundation upon which everything else is built.
