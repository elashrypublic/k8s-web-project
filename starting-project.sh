#!/usr/bin/env bash

# ==============================================

# 🏦 Banking Platform - Auto Deployment Script

# Author: Abdelrahman El Ashry

# ==============================================

set -e

echo "======================================================="
echo "🚀 Starting Kubernetes Banking Platform Deployment..."
echo "======================================================="
echo ""

# =================================

# 1. Start Minikube Cluster

# =================================

echo "📦 Starting Minikube (3 nodes)..."
minikube start --nodes=3 -p minikube

# =================================

# 2. Enable Ingress

# =================================

echo ""
echo "🌐 Enabling Ingress Controller..."
minikube addons enable ingress

echo ""
echo ""
echo "⏳ Waiting for Ingress controller pods..."

kubectl rollout status deployment ingress-nginx-controller -n ingress-nginx --timeout=180s


# =================================

# 3. Apply Node Taints & Labels

# =================================

# Taint control-plane node to prevent scheduling of regular workloads

kubectl taint nodes minikube node-role.kubernetes.io/control-plane=true:NoSchedule

# Label worker nodes for resource allocation

kubectl label nodes minikube-m02 type=high-memory
kubectl label nodes minikube-m03 type=high-memory

# Taint worker nodes to only allow database workloads

kubectl taint nodes minikube-m02 database-only=true:NoSchedule
kubectl taint nodes minikube-m03 database-only=true:NoSchedule


# =================================

# 4. Apply Kubernetes Files (Ordered)

# =================================

echo ""
echo "📂 Applying Kubernetes manifests in order..."

# Namespace

kubectl apply -f k8s/00-namespace.yaml

# Config & Secrets

kubectl apply -f k8s/01-configmap.yaml
kubectl apply -f k8s/02-secret.yaml

# RBAC

kubectl apply -f k8s/15-serviceaccounts.yaml
kubectl apply -f k8s/16-role.yaml
kubectl apply -f k8s/17-rolebinding.yaml

# Database (Postgres)

kubectl apply -f k8s/03-postgres-statefulset.yaml
kubectl apply -f k8s/04-postgres-service.yaml

# Backend (API)

kubectl apply -f k8s/05-api-deployment.yaml
kubectl apply -f k8s/06-api-service.yaml

# Frontend (Dashboard)

kubectl apply -f k8s/07-dashboard-deployment.yaml
kubectl apply -f k8s/08-dashboard-service.yaml

# Network Policies

kubectl apply -f k8s/10-deny-all.yaml
kubectl apply -f k8s/11-allow-dns.yaml
kubectl apply -f k8s/12-allow-dashboard-NP.yaml
kubectl apply -f k8s/13-allow-api-NP.yaml
kubectl apply -f k8s/14-allow-postgres-NP.yaml

# Ingress

kubectl apply -f k8s/09-ingress.yaml

# Scaling & Logging

kubectl apply -f k8s/18-hpa.yaml
kubectl apply -f k8s/19-daemonset-fluentd.yaml

# =================================

# 5. Setup Hosts

# =================================

echo ""
echo "🌍 Configuring /etc/hosts..."

MINIKUBE_IP=$(minikube ip)

if ! grep -q "banking.local" /etc/hosts; then
echo "$MINIKUBE_IP banking.local" | sudo tee -a /etc/hosts
echo "✅ Added banking.local to /etc/hosts"
else
echo "ℹ️ banking.local already exists in /etc/hosts"
fi

# =================================

# 6. Wait for Pods

# =================================

echo ""
echo "⏳ Waiting for all pods to be ready..."

kubectl wait --for=condition=Ready pods --all -n banking --timeout=40s

# =================================

# 7. Final Status

# =================================

echo ""
echo "📊 Final Cluster Status:"
kubectl get pods -n banking -o wide

echo ""
kubectl get svc -n banking

echo ""
kubectl get ingress -n banking

echo ""
echo "======================================================="
echo "🎉 Deployment Completed Successfully!"
echo "🌐 Access your app: http://banking.local"
echo "======================================================="
