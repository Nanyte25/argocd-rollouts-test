#!/bin/bash

# Step 1: Create a Kind Cluster using the default configuration
kind create cluster --name argo-rollouts-cluster

# Step 2: Install ArgoCD into the Kind Cluster
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Step 3: Install Argo Rollouts into the Kind Cluster
kubectl create namespace argo-rollouts
kubectl apply -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml -n argo-rollouts

# Step 4: Install ArgoCD CLI
if ! command -v argocd &> /dev/null
then
    echo "ArgoCD CLI not found, installing..."
    brew install argocd
else
    echo "ArgoCD CLI is already installed."
fi

# Step 5: Install Argo Rollouts CLI
if ! command -v kubectl-argo-rollouts &> /dev/null
then
    echo "Argo Rollouts CLI not found, installing..."
    brew install argoproj/tap/kubectl-argo-rollouts
else
    echo "Argo Rollouts CLI is already installed."
fi

# Step 6: Clone the argo-rollouts-101 repository
git clone https://github.com/devopsjourney1/argo-rollouts-101.git
cd argo-rollouts-101

# Step 7: Apply the demo application manifests
kubectl create namespace demo
kubectl apply -f argo-rollouts/ -n demo

# Step 8: Expose the ArgoCD Server
kubectl port-forward svc/argocd-server -n argocd 8080:443 &

# Step 9: Log in to the ArgoCD Server
export ARGOCD_PWD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
argocd login localhost:8080 --username admin --password $ARGOCD_PWD --insecure

# Step 10: Add the demo application to ArgoCD
argocd app create rollouts-demo --repo https://github.com/devopsjourney1/argo-rollouts-101.git --path argo-rollouts --dest-server https://kubernetes.default.svc --dest-namespace demo

# Step 11: Sync the demo application to deploy it
argocd app sync rollouts-demo

echo "ArgoCD Rollouts demo setup is complete. Access ArgoCD at https://localhost:8080"
echo "You can monitor the rollouts with: kubectl argo rollouts get rollout rollouts-demo -n demo"
