---
title: "How to Develop a Jenkins Pipeline with a Custom Agent Pod Template from an External Repository"
date: 2025-07-31
description: Learn how to configure a Jenkins pipeline using a custom Kubernetes agent pod template stored in a separate Git repository.
tags: ["jenkins", "kubernetes", "ci/cd", "devops"]
---

Jenkins pipelines running on Kubernetes offer powerful customization using pod templates. In this post, you’ll learn how to define a custom Kubernetes agent pod in a YAML template located in a **different Git repository**, and then use that in your Jenkins pipeline.

---

## 🧱 Requirements

- Jenkins with the **Kubernetes plugin**
- A Git repo hosting your **custom pod template YAML**
- Access to a Kubernetes cluster (like EKS, GKE, or Minikube)
- Git credentials stored in Jenkins (e.g., via `credentialsId`)

---

## 📁 Repository Structure

We assume you have two Git repositories:

### 1. **Pipeline Repository**

Contains your `Jenkinsfile` or pipeline script.

```bash
repo-pipeline/
└── Jenkinsfile
```

### 2. **Pod Template Repository**

Contains your custom Kubernetes pod template YAML.

```bash
repo-pod-template/
└── my-agent-pod.yaml
```

---

## 🚀 Step-by-Step Guide

### 1. Store Your Pod Template in a Separate Repo

Create a YAML file (e.g., `my-agent-pod.yaml`) in your pod template repository. Example:

```yaml
apiVersion: v1
kind: Pod
spec:
  containers:
    - name: jnlp
      image: jenkins/inbound-agent:latest
    - name: custom
      image: your-custom-image:latest
      command: ["cat"]
      tty: true
```

### 2. Configure Jenkins Credentials

Add your Git credentials to Jenkins (e.g., via the Credentials Manager) and note the `credentialsId`.

### 3. Reference the Pod Template in Your Jenkinsfile

Use a pipeline script to fetch the pod template from the external repo and use it as the agent. Example:

```groovy
pipeline {
  agent {
    kubernetes {
      yamlFile 'my-agent-pod.yaml'
      // Optionally, specify a defaultContainer
      defaultContainer 'custom'
    }
  }
  stages {
    stage('Clone Pod Template') {
      steps {
        git url: 'https://github.com/your-org/repo-pod-template.git', credentialsId: 'your-credentials-id'
      }
    }
    stage('Run Steps') {
      steps {
        container('custom') {
          sh 'echo Hello from custom agent!'
        }
      }
    }
  }
}
```

**Note:** The `yamlFile` parameter expects the YAML file to be present in the workspace. The pipeline first clones the pod template repo, then uses the YAML for the agent definition.

---

## 📝 Tips

- Make sure your Jenkins Kubernetes plugin is up to date.
- Use version control for your pod templates to track changes.
- Secure your credentials and limit access as needed.

---

## 🎯 Conclusion

By storing your custom agent pod definition in a separate repository, you can reuse and version your templates across multiple pipelines, improving maintainability and collaboration.
