# 🏦 Banking Platform on Kubernetes

A **production-style three-tier banking application** deployed on Kubernetes, demonstrating real-world DevOps and cloud-native practices including **scalability, security, networking, and observability**.

---

## 📌 Project Overview

This project simulates a real banking system where users can:

* Open accounts
* View balances
* Transfer money
* Monitor transactions in real time

The application is fully containerized and deployed on a **multi-node Kubernetes cluster** using industry best practices.

---

## 🏗️ Architecture

The system follows a **three-tier architecture**:

1. **Frontend (Dashboard)**

   * Technology: HTML + Nginx
   * Role: Displays accounts, balances, and transactions

2. **Backend (Banking API)**

   * Technology: Node.js + Express
   * Role: Handles business logic and communicates with the database

3. **Database (PostgreSQL)**

   * Technology: PostgreSQL 15
   * Role: Stores all persistent data

---

## 🌐 Traffic Flow

```text
User → Ingress → Dashboard → API → PostgreSQL
```

* `banking.local/` → Dashboard
* `banking.local/api/*` → Banking API
* API communicates with PostgreSQL via internal service

---

## ⚙️ Kubernetes Components

| Resource      | Description                   |
| ------------- | ----------------------------- |
| Namespace     | Logical isolation (`banking`) |
| ConfigMap     | Non-sensitive configuration   |
| Secret        | Sensitive data (DB password)  |
| Deployment    | API (2 replicas) & Dashboard  |
| StatefulSet   | PostgreSQL database           |
| Services      | Internal communication        |
| Ingress       | External access routing       |
| NetworkPolicy | Secure traffic control        |
| RBAC          | Access control                |
| HPA           | Auto scaling                  |
| DaemonSet     | Fluentd logging               |
| PVC           | Persistent storage            |

---

## 🚀 Features Implemented

### ✅ High Availability

* API deployed with multiple replicas
* Load balancing via Kubernetes Service

### ✅ Scalability

* Horizontal Pod Autoscaler (HPA)
* CPU-based scaling (2 → 10 replicas)

### ✅ Data Persistence

* PostgreSQL StatefulSet with Persistent Volume Claims
* Data survives pod restarts

### ✅ Security

* NetworkPolicy (deny-all + allow rules)
* RBAC (least privilege access)
* Secrets for sensitive data
* Pods run as non-root (best practice)

### ✅ Node Isolation

* Dedicated database node using:

  * Node labels
  * Taints & tolerations

### ✅ Observability

* Fluentd DaemonSet collects logs from all nodes

### ✅ Zero Downtime Deployment

* Rolling updates
* Rollback support

---

## 🧠 Networking Design

| Source     | Destination | Allowed |
| ---------- | ----------- | ------- |
| Dashboard  | API         | ✅       |
| API        | Database    | ✅       |
| Dashboard  | Database    | ❌       |
| External   | Ingress     | ✅       |
| All others | Blocked     | ❌       |

---

## 🐳 Docker Images

Images are built and pushed to Docker Hub:

```bash
docker build -t <your-username>/banking-api:v1.0 ./banking-api
docker push <your-username>/banking-api:v1.0

docker build -t <your-username>/banking-dashboard:v1.0 ./banking-dashboard
docker push <your-username>/banking-dashboard:v1.0
```

---

## ⚡ Deployment Steps

### 1. Start Kubernetes Cluster

```bash
minikube start --nodes=3
minikube addons enable ingress
```

---

### 2. Apply Kubernetes Resources

```bash
kubectl apply -f k8s/
```

---

### 3. Configure Hosts

```bash
minikube ip
```

Add to `/etc/hosts`:

```text
<MINIKUBE_IP> banking.local
```

---

### 4. Access the Application

```text
http://banking.local
```

---

## 🧪 Testing

### API Health

```bash
curl http://banking.local/api/health
```

### Database Persistence

```bash
kubectl delete pod postgres-db-0 -n banking
```

✔ Data remains intact after restart

---

### Rolling Update

```bash
kubectl set image deployment/banking-api banking-api=<image:v1.1> -n banking
kubectl rollout status deployment/banking-api -n banking
```

### Rollback

```bash
kubectl rollout undo deployment/banking-api -n banking
```

---

## 📊 Monitoring

```bash
kubectl get pods -n banking
kubectl get hpa -n banking
kubectl get netpol -n banking
kubectl get daemonset -n banking
```

---

## 🔒 Security Implementation

* **Deny-All NetworkPolicy**
* Explicit allow rules
* ServiceAccount + RBAC
* Secret management
* Non-root containers

---

## 📁 Project Structure

```text
k8s/
├── 00-namespace.yaml
├── 01-configmap.yaml
├── 02-secret.yaml
├── 03-postgres-statefulset.yaml
├── 04-postgres-service.yaml
├── 05-api-deployment.yaml
├── 06-api-service.yaml
├── 07-dashboard-deployment.yaml
├── 08-dashboard-service.yaml
├── 09-ingress.yaml
├── 10-network-policy.yaml
├── 11-serviceaccounts.yaml
├── 12-role.yaml
├── 13-rolebinding.yaml
├── 14-hpa.yaml
├── 15-daemonset-fluentd.yaml
├── 16-fluentd-config.yaml
```
---

## 🏆 Key Learnings

* Kubernetes architecture & object relationships
* Networking (Ingress, Services, NetworkPolicy)
* Stateful workloads (StatefulSet)
* Security best practices (RBAC, Secrets)
* Scaling & high availability
* Debugging real production issues

---

## 👨‍💻 Author

**Abdelrahman El Ashry**
DevOps Engineer | Kubernetes Enthusiast

---

## 🚀 Future Improvements

* TLS/HTTPS with cert-manager
* CI/CD pipeline (GitHub Actions)
* Helm chart packaging
* Prometheus & Grafana monitoring

---

## ⭐ Final Note

This project represents a **real-world Kubernetes deployment** using production-grade practices.
It demonstrates the ability to design, deploy, secure, and scale a full application stack in Kubernetes.

---
