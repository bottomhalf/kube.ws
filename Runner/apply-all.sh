#!/bin/bash

ROOT_DIR="/root/kube.ws/emstum"  # Update this if your folder is named differently

echo "Applying Kubernetes YAMLs..."

echo "==============================="
echo "Step 1: Applying namespaces..."
echo "==============================="

find "$ROOT_DIR" -type f \( -iname "*.yaml" -o -iname "*.yml" \) \
  -iname "*namespace*" | while read ns_file; do
  echo "Applying namespace file: $ns_file"
  microk8s kubectl apply -f "$ns_file"
done

echo "==============================="
echo "Step 2: Applying PV/PVC..."
echo "==============================="

find "$ROOT_DIR" -type f \( -iname "*.yaml" -o -iname "*.yml" \) \
  \( -iname "*pv*" -o -iname "*pvc*" \) | while read pv_file; do
  echo "Applying PV/PVC file: $pv_file"
  microk8s kubectl apply -f "$pv_file"
done

echo "==============================="
echo "Step 3: Applying remaining YAMLs..."
echo "==============================="

# First get list of all YAML files
ALL_YAML_FILES=$(find "$ROOT_DIR" -type f \( -iname "*.yaml" -o -iname "*.yml" \))

# Exclude namespace and pv/pvc files
REMAINING_FILES=$(echo "$ALL_YAML_FILES" | grep -vi "namespace" | grep -vi "pvc" | grep -vi "pv")

# Now apply the remaining
echo "$REMAINING_FILES" | while read file; do
  echo "Applying remaining file: $file"
  microk8s kubectl delete -f "$file"
  microk8s kubectl apply -f "$file"
done

echo "==============================="
echo "All files applied successfully."
echo "==============================="