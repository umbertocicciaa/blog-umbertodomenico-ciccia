---
title: "End-to-End MLOps on AWS with CI/CD, GitOps, and Kubernetes"
date: '2025-05-24T18:37:56+02:00'
draft: false
searchable: true
tags: ["mlops", "aws", "sagemaker", "gitops", "kubernetes", "cicd", "terraform"]
categories: ["Cloud Computing", "DevOps", "Machine Learning"]
summary: "A complete walkthrough of building a production-grade MLOps pipeline using AWS Glue, SageMaker, Terraform, and Kubernetes — with automated CI/CD and GitOps for infrastructure and frontend deployment."
---

## MlOps

## Architecture

In this project, I built a full-stack MLOps pipeline using AWS services and modern DevOps practices, integrating CI/CD pipelines, GitOps workflows, and Kubernetes deployment. Here's a deep dive into how the whole system works, from data preprocessing to model deployment — all automated and infrastructure-as-code.

---

## 🚀 Overview

The pipeline focuses on a **linear regression model** trained on the *California Housing* dataset. It includes:

- **AWS Glue** for preprocessing
- **EventBridge & Lambda** for orchestration
- **SageMaker** for training and deployment
- **Terraform** for Infrastructure as Code
- **GitHub Actions** for CI/CD and GitOps
- **Kubernetes** (EKS) for frontend deployment
- **Streamlit** as a user-facing interface

![Demo](/blog-umbertodomenico-ciccia/images/aws-mlops/demo.jpeg)

---

## 🧱 System Architecture

### 🔄 ETL Pipeline with AWS Glue

- Raw housing data is uploaded to an S3 bucket.
- EventBridge detects the new file and triggers a Lambda function.
- Lambda starts a Glue workflow that runs a Python job to clean and transform the data.
- The processed data is saved to another S3 bucket for training.

### 🤖 MLOps with SageMaker Pipelines

- A second EventBridge rule detects the new preprocessed data and triggers a SageMaker pipeline.
- This pipeline:
  - Executes additional transformations
  - Trains a regression model using **XGBoost**
  - Registers the model in SageMaker Model Registry
  - Deploys it as a **real-time endpoint**

### 🌐 Model Serving and API

Once deployed, the model exposes a SageMaker endpoint. A lightweight REST API serves predictions via HTTP.

### 🧪 CI/CD for Frontend (Streamlit)

Every push to the `frontend/` directory:

- Builds a Docker image via GitHub Actions
- Pushes the image to Amazon ECR
- Updates a Kubernetes deployment on **EKS**
- Exposes the app via an **Ingress** controller

This enables real-time user interaction and visualization.

---

## ⚙️ Infrastructure Automation with Terraform

All AWS resources — Glue, Lambda, S3, SageMaker, IAM, EventBridge — are managed via Terraform. The infrastructure code is modular, reusable, and version-controlled.

### 🌀 GitOps for IaC

Changes pushed to the `iac/` directory:

- Trigger `terraform plan` and `terraform apply` via CI/CD
- Apply changes to the infrastructure using AWS credentials
- Enforce full GitOps compliance and reproducibility

---

## ☸️ Kubernetes Deployment for Frontend

Frontend deployment leverages Kubernetes for scalable serving:

- A **Deployment** pod runs the Dockerized Streamlit app.
- A **Service** exposes it internally.
- An **Ingress** route exposes it externally (e.g., via NGINX).

This structure allows secure, modular, and scalable user-facing components.

---

## 📈 Benefits of the Architecture

- **Scalable**: Serverless data processing and container-based serving
- **Fully automated**: CI/CD and GitOps reduce manual steps
- **Repeatable**: Terraform ensures consistent provisioning
- **User-friendly**: Streamlit frontend enables easy interaction
- **Modular**: Each stage can be reused or replaced independently

---

## 🔮 Future Work

- Add model monitoring (e.g., drift detection)
- Introduce approval gates before production deployment
- Expand to multi-model deployment patterns
- Integrate with ArgoCD for advanced GitOps

---

## 📎 References

- [AWS Glue](https://docs.aws.amazon.com/glue/)
- [Amazon SageMaker](https://docs.aws.amazon.com/sagemaker/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Streamlit](https://streamlit.io/)
- [GitOps Principles](https://opengitops.dev/)

---

If you're looking to build production-grade MLOps pipelines or want to explore automation with AWS and Kubernetes, feel free to fork the [project repository](https://github.com/umbertocicciaa/aws-mlops) or drop your questions.

Stay open. Stay automated. 🚀
