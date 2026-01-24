---
date: '2025-04-26T14:13:56+02:00'
title: 'Gcp Ace Notes'
tags: ['gcp','notes']
searchable: false
---

## Admin

### Sdk

**gcloud** cli

**client libraries sdk** linguaggi programmazione

**bq** bigquery

**gsutil** cloud storage

### Resource hierarchy

**Projects:** contains all resources, lowest level of org

**Organization:** top level hierarchy, contains all folder, all projects

- need a cloud identity or a google woekspace account

**Folders:** logic group of projects

**Google Cloud Console's Resource Manager:**  console for  manage folder, projects and org

### Projects metadata

**Project name:**

- name of the project
- can be edited

**Project id**

- Globally unique id
- immutable
- used by gcloud commands and apis

**Project Number**

- globally unique
- cannot be chosen or modified
- used internally

**Enabling apis:**

- add apis to project for use services

#### Projects migrations

**Project migration:** project can be migrated accross different folder / org

**projects.move:** apis that facilitated the project move

- **resourcemanager.projects.update**: permission on the project being moved
- **resourcemanager.projects.move**: permission on the destination

#### Roles at org level

**Organization administrator:** admin of the org

**Organization policy administrator:** manage org policy

**VIewer:** view only access

**Browser:** read only accesso to structure and projects folders metadata

### IAM

**Principal**: entity that can be granted access to resources

- **Use accounts:**
  - Human
  - Access with password and username
  - access to cloud services
- **Service account**
  - access via keys and token
  - associated with app and vm

**Service account admin role**: create and manage service account

#### Google managed vs user managed service account

Google

- google created
- pre defined name <project-number>@<service>.gserviceaccount.com
- default permission

User

- User created
- custom name <myname>@<project-id>.iam.gserviceaccount.com
- custom permission

#### Roles

##### **Basic**

**Owner :** full access to resources

**Editors:** full access read write to most resource cannot manager roles and permission

**Viewer:** read only access

##### **Predefined**

Predefined roles for gcp service and apis

Examples:

Compute Engine Admin

Cloud Run Developer

Storage Object Viewer

##### **Custom**

Defined by user

#### Access approval

Designe an approver on the team to review and decide wheter to approve or not access request from google support team

### Pricing calculator

no log web console for predict future cost

billing console historical cost on past, pricing caluclator on the future

### Cloud billing

**Billing console:** console for manage billing

**Project billing manager**: associate a project to a billing account

**Billing administrator:** associate a project to a billing account at org level

**Billing administrator:** can setup billing allert

---

## Big Data

### Dataflow

Apache Beam (batch and stream)

handle separate data stream of different types

Integration with cloud storage, pub/sub, big query

Pipelines are single region

### Pub/sub

Google version of kafka

global scale servless message buffering

Integration with dataflow:

![Big data flow](/blog-umbertodomenico-ciccia/images/gcp-ace-notes/bigdata.png)

---

## Compute Services

### Google Compute Engine

Virtual Machine on Cloud

Setup VM

- Region, Zone
- Machine Type
  - ex e2-standard-2 (number of vcpus)
- OS
- Boot disk size
- spot or not
- Network settings
  - firewall rule
  - net tags
  - external ip
- Monitoring
  - Ops agent
- Service account
- Delete protection: protezione dalla cancellazione dell’istanza
- On Host maintenance: comportamento vm quando google manipola infrastruttura fisica

#### Remote Access

- SSH: ssh key managed by google
- Os Login: check if user has roes for ssh access
  - **Compute OS Login**: login ssh no root
  - **Compute Os Admin Login**: login ssh root
  - **Compute OS Login External User:** login ssh external of gcp no root
- RDP: ssh of windows
  - **gcloud compute reset-windows-password** : genera password per rdp
  - set user/password under remote access in compute engine

#### OS Config Agent

Agent for vulnerability scanning and access OS metadata for find vulnerabilities

**roles/osconfig.vulnerabilityReportViewer** role for view vulnerability

### Managed Instance groups

Simplify deployment and management of VM.

Auto updates, auto scaling, high avilability, load balancing

**Autoscalig signal:** signal for autoscaling → cloud monitoring metric, cpu utilization. load balancer utilization, …

**Healt check:** monitor VM statuts → should be bigger than vm boot

**Autohealing:** recreate unhealthy vm

**Automatic restart**: restart vm after a crash

#### Deployments

**Gradual**:

- maxSurge: max number of new instances that can be created
- maxUnavailable: max numer of instances that can be unavailable during update

#### Instance Template

**Blueprint for vm**: machine type, image, disk, …

#### Backup and disaster recovery

**Zonal Failure Protection**: multi-zonal deploy

**Scheduling Backup**: schedule snapshot

### Roles

**Compute Storage Admin** for creating snapshot

**Compute Admin** control over all google compute engine

**Compute Instance Admin** managing vm instances settings: os disk net …

**Compute Viewer** read only to all compute engine resource and metadata

### Kubernetes and GKE

**Cluster**: collection of nodes

**Node:** worker machine within a cluster

**Pod:** deploy unit in an node (can contain 1+ container)

#### K8s structure

- Services: expose k8s node and pods from outside of cluster
  - ClusterIP: pod to pod comunication
  - NodePort: external client to pod without balancing throught nodes
  - LoadBalancer: external client to pod with auto distribution within nodes

#### Commands

**kubectl config use-context:** switch between .kube/config config

**kubectl config view:** view current .kube/config config

**gcloud container clusters get-credentials my-cluster**: retrieve .kube/config

#### Nodes

**Preemptive node**: Spot nodes, can be reclaimed by google at any time

**Node pools:** nodes with different machine type

**Node labels:** settings label

**Node selector:** field of k8s manifest for specifie node from labels

#### Features

**Cluster Autoscaler** autoscale number of node (best practicies set min and max)

**Horizontal Pod Autoscaler** scale number of pod based of usage

**Vertical Pod Autoscaler**

**Auto-Upgrades:** auto upgrade to the next k8s version. release channel:

- Rapid channel: prioritize new features (test and dev)
- Regular channel: balance new features and stability (pre-prod)
- Stable channel: prioritize stability (on prod)

#### Config connector

manage gcp resource with kubectl and k8s (crossplane)

**delete config connector:** kubecctl not gcloud

#### Filesystem

**persistent storage** persistent ssd

**local storage** ephemeral high io

**filestore** shared

![Storage](/blog-umbertodomenico-ciccia/images/gcp-ace-notes/storage.png)

#### Cloud logging

**cluster setting**: enable logging

disable logging for a container in ingestion setting of cloud logging

#### Workloads

**StatefulSet** k8s object for mamage storing data

**DeamonSet** replicate a pod in every or select node

#### Commands

**gcloud config set container/cluster <clustername>** set default cluster in gcloud config

**gcloud container cluster create <clustername>**

**gcloud container node-pool create <nodepoolname>**

**gcloud container cluster list**

### Cloud Run

Platform servless for run stateless container. can scale to zero,automatic horizontal scaling

#### Cold start fix

- M**inimum number of instances**: setup a minimum number of instances always running
- **Pre warming**: make fake traffic for keep instance alive periodically

### App Engine

- Servless application deploying
- 1 app engine 1 project
- Regional (cant be changed)

#### Standard vs Flexible

- Standard: low cost/free can scale to zero, extreme spike traffic
- Flexible: docker container environment

#### Scaling

- **Basic scaling:** add new instances for every request. Shutdown instances when application is idle
- **Automatic scaling:** add new instances in base of applications metrics: Can setup a minimum numebr of instances running all the time
- **Manual scaling:** setup the number of instancs

#### **App Engine Versions**

- Page with all version deployed
- You can return to a previos version route all traffic to the previous

#### App settings

in yaml file

![App engine](/blog-umbertodomenico-ciccia/images/gcp-ace-notes/app_engine.png)

---

## Data governance

### Data catalog 
Repository of data

metadata management: create store and manage metadata for all gcp data resources

data discovery and search: search data accross gcp services

tagging and tag tempaltes

---

## Data storage

### Google Compute Storage

#### gsutil

      gsutil cp

      gsutil rsync

      gsutils ls

#### Storage classes

Lifecycle rule → change between classes or delete

|  | days | use cases |
| --- | --- | --- |
| standard |  | frequent |
| nearline | 30g | 1 month |
| coldline | 90g | disaster recovery |
| archive | 365 | 1+ year |

#### Location

**Regional** regionale (low latency)

**Multi-regional** multi/region HA min latecy

**Dual-region** disaster recovery

#### Versioning

verisoning object

gsutil versioning set on/off **gs://<bucketname>**

#### GCS Access

**IAM Policy**: basic predefined custom roles → **object level** requires **conditional iam policies**

**ACLS**: object level only → owner, writer, reader, object level only

**Signed Urls**: temproary access with predefined read or write

#### Roles

storage admin: full control

storage object admin: manage objects in bucket

storage object creator: upload objects in bucket

sotrage object viewer: read objects of bucket

storage legacy bucket reader: read bucket metadata and data

#### Trigger action

object upload

object delete

object metadata upload

object archived

integrate with: pub/sub, cloud function, cloud run

#### Integration with services

Dataflow: input/output

Dataproc: replace hadoop file system for dataproc (spark/hadoop)

### Cloud Spanner

Global availability global scalability global consistence relational DB

**Monitoring health: →roles/monitoring.viewer**

**raccomendend cpu usage threshold for single-region 65%**

**raccomendend cpu usage threshold for multi-region 45%**

**Improve read performance →** create secondary index

### Cloud SQL (sql db)

SQL Db (postgresql, mysql, sqlserver)

**OLTP workflow** → transactional insert,update,delete

**MAX Storage** = 64 TB

**Point in time recovery:**  restore at any paste state

MYSQL: **binary logging**

PostgreSQL: **write ahead logging**

**Read Replica:** HA async replication (same region of master)

**Failover Replica:** HA disaster recovery ****sync replication ****(different region or zone)

**Backups:**

- Automatic
  - 7 days of retention → export to cloud storage for more time
  - backup window
- Manual
- Scheduled

**Cloud SQL proxy:** connect app to db through iam based auth (encrypted) **cloudsql.instances.connect**

### Firestore (nosql db for realtime)

Fully-managed Real time nosql db

### Memorystore (caching redis/memcached)

Fully-managed in memory data store (caching layer)

Support redis and memcached

### Bigquery (datawarehousing)

fully managed sql db storage and analyctics and data warehouse

**OLAP workflow**: analysis

- sql query for retrieve data

- pay for query data retrieve
  - bq cli for preview the number of bytes to retrieve
- Job error: job explorer area

#### Cost control

- **Quotas**: se up custom query quotas per user or project → quotaERxceed error
- **Flate-rate princing:** flat monthly cost

#### BigQuery admin console

Resource utilization and jobs monitoring

INFORMATION_SCHEMA: schema for get info about jobs, datasets, table,….

#### Roles

- **bigquery admin:** full control of bigquery (project level)
- **bigquery user:** create dataset and manage jobs
- **bigquery data owner**: manage and share datasets/views
- **bigquery data editor**: modify and delete table data
- **bigquery data viewer**: read only tables
- **bigquery job user**: run jobs and queries
- **bigquery metadata viewe**r: access dataset/table metadata

### Looker

data intelligence business inteliggence data dashboard from bigquery

looker studio: free, basic data visualization

looker: paid version, customizable bi analysis, high customization

### Bigtable (nosql db for analysis)

**Service:** fully-managed nosql database

**Use case**: analytics workloads

**Payment**: dont pay for empty cells

**Row**: row key is index (best practicies: string id, reverse domain, timestamp column)

**Logging:** resource.type=”bigtable_instance”

---

## Deployments

### Container Registry

Registry for docker images

storage object viewer: roles for pull

### Artifact registry

registry fore store artifacts

artifact registry viewer artifact registry reader, pull images role

### Cloud Build

ci/cd

testing

permissions denied error

### Cloud Deployments Manager

terraform

simulating deploments —preview (plan) gcloud deployment-manager deployments create my-deployment —config config.yaml —preview

---

## Marketplace

Online store that offer ready-to-deploy solution

---

## Migrate

### **Migrate for Compute Engine (formerly Velostrata)**

---

## Networking

### VPC

![VPC Diagram](/blog-umbertodomenico-ciccia/images/gcp-ace-notes/vpc.png)

Subnet: at region leve in a vpc

vpc: at project level+

### Private Service Connect

App accessible only through an internal ip in the vpc

### Private Google Access

connect to google apis and service without external ip

### Shared Vpc

share vpc from one project to another in same org

### VPC Peering

Peerin 1-1 of 2 vpc

### Cloud VPN

vpn connection from on-prem&/vpc to cloud vpc

### Common ip

0.0.0.0/0 default route for all ip

10.0.0.0/8 reserved for private net

172.16.0.0/12  reserved for private net

192.168.0.0/16  reserved for private net

8.8.8.0/24  reserved for dns

192.0.2.0/24 reserved for docs and examples

### Firewall

Identity-based firewall rules: firewall lrule in base of service account

Logging: disabled by default → enable in logs section of the rule

### Load balancing

Distribute traffic between services

static ipv4 and ipv6 (**frontend**)

**SSL Termination** (terminate https encryption at load balancing for simplify certificates management)

![Load Balancer](/blog-umbertodomenico-ciccia/images/gcp-ace-notes/loadbalancer.png)

**A records** ipv4

**AAAA records** ipv6

**CNAME records** to another cname

## Cloud Identity-Aware proxy

grant access to vm or web app verifying the identity before log

**protect resources**: cloud run, app engine, https load balancer, google compute engine

**auth types**: oauth, jwt, google sign in, microsoft sign in

**defense**: brute force attack

![IAP](/blog-umbertodomenico-ciccia/images/gcp-ace-notes/iap.png)

---

## Observability

### Cloud Logging

Service that **store**, **analyze**, search all **logs**

integration with **cloud monitoring** for **analytics** and **automated alert**

#### Logs

**Log** info:

- Admin activity
- Data access
- System event
- User log from app

**Retention** period:

- Default period: 30 days
- Custom: custom log retention

Log sinks: export destintion for logs

![Log sink](/blog-umbertodomenico-ciccia/images/gcp-ace-notes/sink.png)

SIEMS: security logs

![Configure log sink](/blog-umbertodomenico-ciccia/images/gcp-ace-notes/configure_sink.png)

Audit Logs: access activity, user activity

### Cloud monitoring

Collect analyze visualize metrics of gcp resoruces

#### Metrics

**Infrastructure**: cpu use disk i/o, network

**Application**: repsonse time, error rate, latency, request rates

**Custom**:

**External**: multi-cloud

**System**: system load

#### Alert

Real time alert in base of metrics

**Notification**: sms email third party

#### Multi-project

Select primary project

Link projects to console

### Cloud Trace

Inspect latency and issue of app and request flow

### Cloud Debugger

debug production app without stop

### Cloud Profiler

analyze code and performance of the app
