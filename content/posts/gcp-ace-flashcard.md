---
date: '2025-04-26T14:13:56+02:00'
title: 'Gcp Ace flashcards'
tags: ['gcp','notes','flashcard']
searchable: true
---

## Projects and iam

- what is the purpose of Google Cloud Console's Resource Manager
- difference between gcloud, gsutil, bg, and cloud sdk
- difference between projects, folder, org
- what is required for an organization to be established
- project name vs project id vs project number
- difference between project id and proejct number
- what is project migration
- projects move apis
- resourcemanager.projects.update policy
- resourcemanager.projects.move policy
- organization administrator role
- organization policy administrator role
- viewer role
- browser role
- what is an principal
- differences between user account and service account
- what is a service account
- what is service account admin role
- "google managed vs user managed service account
- Predefined roles
- Custom roles
- what is the iam console
- what is access approvale feature
- gcloud auth activate-service-account
- gcloud iam roles copy <project id / org id> command
- gcloud projects get-iam-policy command
- ensure that your on-premises application can authenticate and connect to GCP APIs.
- gcloud projects list command
- gcloud services list --project <project ID>

## Billing

- what is pricing calculator
- what is the billing console
- billing console vs pricing calculator
- project billing manager vs  billing administrator
- what role can setup billing alert
- how to consolidate all projects under a single billing account
- how to consolidate  projects of different organization under a single billing account

## Logging and monitoring Google Cloud's Operation Suite

- what is a Google Cloud Monitoring Workspace
- purpose of Cloud Logging
- purpose of integration cloud monitoring with cloud logging
- logs: admin, data, system, user
- default retention period of logs
- what is a log sink
- possible log sink
- SIEMS logging
- Audit logging
- purpose of cloud monitoring
- "Metrics
- Infrastructure vs
- Application vs
- Custom vs
- External vs
- System"
- cloud monitoring alert: possible destination
- setup multi-project cloud monitoring
- what is the purpose of cloud trace
- what is the purpose of cloud debugger
- what is the purpose of cloud profiler

## Compute engine

- vm ops agent
- vm delete protection
- vm on host mainteinance
- what si the purpose of os login
- Compute OS Login
- Compute Os Admin Login
- Compute OS Login External"
- gcloud compute reset-windows-password • set username and password from rdp in console
- who manage ssh keys
- how to send all vm log to bigquery table fast and with low cost
- how to ssh in windows machine
- persistent disk and compute engine can have same name?

## Managed instance group

- what is a managed instance group
- what is a instance template
- what are automatic signal
- what is a health check
- what is the automatic restart
- what is the autohealing
- Gradual deployments: maxSurge, maxUnavailable
- Compute Storage Admin
- Compute Admin
- Compute Instance Admin
- Compute Viewer
- what are the step for increase vm’s memory
- what is the purpose of OS Config agent
- role osconfig.vulnerabilityReportViewer

## Gke

- Cluster vs Node vs Pod
- kubectl config use-context
- kubectl config view
- gcloud container clusters get-credentials my-cluster
- preemptive node gke
- node pools gke
- node labels and node selectors
- gke cluster autoscaler
- horizontal and vertical pod autoscaler
- what are gke auto upgrade
- difference between rapid, regular and stable channels
- what is gke autopilot
- what is config connector
- how to delete config connector
- difference between persistent storage local storage and filestore storage gke
- where to enalble cluster logging
- how to disable logging for a pod
- troubleshoot pod init with kubectl describe pod <pod-name>
- Statefulset vs Deamonset
- gcloud config set container/cluster <clustername>
- gcloud container cluster create <clustername>
- gcloud container node-pool create <nodepoolname>
- gcloud container cluster list"
- cluster ip vs nodeport vs loadbalancer

## Cloud run

- what is cloud run? can scale to zero?
- how to fix cold start with minimum number of instances
- how to fix cold start with pre warming

## App engine

- what is the purpose of app engine
- app engine can scale to zero?
- how do you set the app engine config?
- how many app engine app for project
- how to return to a previous version
- can you change app region after deployment?
- manual scaling vs automatic scaling vs basic scaling
- automatic scaling: min_idle_instances
- standard vs flexible

## Cloud function

- what is cloud function

## Dataflow

- what is the purpose of dataflow
- whitch services integrate with dataflow
- data pipelines are regiomal?
- dataflow == apache beam
- dataflow autoscale?

## Pub sub

- what is the purpose of pub/sub
- pub/sub == apache kafka
- "Common pattern pub/sub and dataflow for data ingestion:unstructured data (cloud storage),relational data for sql (bigquery),nosql (bigtable)"
- which type of pub/sub subscription is better for batch delivery?
- which type of pub/sub subscription is real time delivery?

## Memorystore

- what is the purpose of memorystore

## Bigtable

- what is the purpose of bigtable
- best practicies for row in bigtable: domain, timestamp, id
- how row are indexed in bigtable
- bigtable is sparse. What this means?
- Cloud logging and monitoring: resource.type=”bigtable_instance”
- use case of sensor

## Firestore

- what is the purpose of firestore and the differences with bigtable
- firestore cloud function trigger

## Bigquery

- what is the purpose of bigquery
- retrieve data on bigquery
- big query resource hierarcy:project, datasets, table
- billing model for big query storage and queries
- how to estimate bigquery size
- where do you find job error?
- quotas and flath price for cost control of bigquery
- what is the quootaExceeded error
- what is the INFORMATION_SCHEMA
- bigquery roles

## Looker

- what is the purpose of looker
- looker studio vs looker

## Cloud sql

- what is the purpose of cloud sql
- different from read replica and failover replica
- max storage cloud sql
- automatic backup: retention windows and retention time
- scheduled backup
- manual backup
- point in time recovery
- binary logging vs write ahead logging
- wbhat is the cloud sql proxy
- roles cloudsql.instances.connect

## Cloud spanner

- what is the purpose of cloud spanner
- roles/monitoring.viewer
- improve read performance of cloud spanner
- raccomendend cpu usage threshold for single-region
- raccomendend cpu usage threshold for muli-region

## Cloud storage

- normal vs nearline vs coldline vs archive cloud storage
- regional vs multi/regional vs dual region cloud storage
- what are lifecyclerules cloud storage
- what is object versioning
- gsutil versioning set on/off gs://<bucketname>
- iam policies vs acls vs signed urls gcs
- what do you need for iam policies object level in gcs
- "storage admin
- storage object admin
- storage object creator
- sotrage object viewer
- storage legacy bucket reader"
- what are trigger actions on bucket
- what service integrate with trigger action of gcs
- object upload object delete object archive object metadata upload triggers
- can retention policies be used together wht object versioning?
- integration of dataflow with cloud storage
- integration of cloud storage with dataproc
- integration of cloud storage with bigquery
- parallel composite uploads in gsutil

# Dataproc

- what is the purpose of dataproc  (spark)

# Others

- what is the purpose of marketplace
- use case of marketplace
- what is the purpose of datacatalog
- what is the metadata management of datacatalog
- what is the data discovery and search of datacatalog

# Registry

- what is the purpose of container registry
- storage object viewer container registry
- what is the purpose of artifact registry
- artifact registry viewer artifact registry reader roles

## Cloud build

- what is the purpose of cloud build
- permissiond deny error in log of cloud build

## Deployment manager

- purpose of deployment manager
- gcloud deployment-manager deployments create my-deployment —config config.yaml
- gcloud deployment-manager deployments create my-deployment —config config.yaml —preview
- gcloud deployment-manager deployments update —config config.yaml
- gcloud deployment-manager resources create
- gcloud deployment-manager resources update

## Load balancing

- what is the purpose of load balancing
- static ipv4 and ipv6 load balancing frontend
- load balancing ssl termination
- level 7 vs level 4 load balancing
- tcp/udp load balancing vs http(s) load balancing
- a vs aaaa vs cname records
- https vs internal https vs ssl proxy load balancing
- tcp proxy load balancing
- ssl proxy vs tcp proxy load balancing
- external network load balancing vs internal network load balancing vs passthrough network load balancing

## Identity aware

- what is the purpose of Cloud Identity-Aware proxy (IAP)
- service protected by Cloud Identity-Aware proxy
- auth types: Cloud Identity-Aware proxy
- defense from attacks Cloud Identity-Aware proxy

## Firewall

- Identity-based firewall rules
- how to enable logging for firewall rules
- gcloud compute firewall-rules update <rule> —enable-logging

## Vpc

- scope of vpc
- scope of subnet
- cloud vpn
- shared vpc
- vpc peering
- Private Google Access
- Private Service Connect
