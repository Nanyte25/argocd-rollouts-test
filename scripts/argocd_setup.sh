#!/bin/bash

# Step 1: Create a Kind Cluster using the provided kind-config.yaml
cat <<EOF > kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    extraPortMappings:
    - containerPort: 80
      hostPort: 80
      protocol: TCP
    - containerPort: 443
      hostPort: 443
      protocol: TCP
EOF

# Create the cluster with the custom configuration
kind create cluster --name argocd-cluster --config=kind-config.yaml

# Step 2: Install ArgoCD into the Kind Cluster
kubectl create namespace argocd

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Step 3: Expose the ArgoCD Server
kubectl port-forward svc/argocd-server -n argocd 8080:443 &

# Step 4: Install ArgoCD CLI
# Check if ArgoCD CLI is already installed, otherwise install it
if ! command -v argocd &> /dev/null
then
    echo "ArgoCD CLI not found, installing..."
    brew install argocd
else
    echo "ArgoCD CLI is already installed."
fi

# Step 5: Log in to the ArgoCD Server
# Retrieve the initial admin password
export ARGOCD_PWD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

argocd login localhost:8080 --username admin --password $ARGOCD_PWD --insecure

# Step 6: Change the default password (Optional, change 'newpassword' to your desired password)
argocd account update-password --account admin --current-password $ARGOCD_PWD --new-password newpassword

echo "ArgoCD setup is complete. You can access it at https://localhost:8080"
