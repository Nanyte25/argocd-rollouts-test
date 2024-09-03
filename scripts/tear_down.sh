#!/bin/bash

# Function to check if a namespace exists before attempting to delete it
function delete_namespace() {
    NAMESPACE=$1
    if kubectl get namespace $NAMESPACE &> /dev/null
    then
        echo "Removing $NAMESPACE Namespace..."
        kubectl delete namespace $NAMESPACE
    else
        echo "$NAMESPACE Namespace not found. Skipping deletion."
    fi
}

# Cleanup ArgoCD namespace
delete_namespace argocd

# Cleanup Argo Rollouts namespace
delete_namespace argo-rollouts

# Cleanup Demo namespace used in the rollouts example
delete_namespace demo

# Delete the Kind cluster
echo "Deleting your Kind Cluster and cleaning up..."
sleep 5
kind delete cluster --name argo-rollouts-cluster

# Confirm deletion and list remaining clusters
echo "Your Cluster has been Successfully deleted!"
kind get clusters

