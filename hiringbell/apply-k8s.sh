#!/bin/bash

set -e  # Exit immediately on error

KUBE_CMD="microk8s kubectl"
TARGET_DIR="${1:-.}"

echo "Kubernetes manifest directory: $TARGET_DIR"
echo "==========================================="

apply_files() {
  local files=("$@")
  for file in "${files[@]}"; do
    echo "Applying: $file"
    $KUBE_CMD apply -f "$file"
  done
}

# 1️⃣ Collect all YAML files
mapfile -t ALL_YMLS < <(
  find "$TARGET_DIR" -type f \( -name "*.yml" -o -name "*.yaml" \) | sort
)

# 2️⃣ Namespace files (namespace / ns)
mapfile -t NAMESPACE_FILES < <(
  printf "%s\n" "${ALL_YMLS[@]}" |
  grep -E '(namespace|[^a-z]ns)[^/]*\.ya?ml$' || true
)

# 3️⃣ Persistent Volume files
mapfile -t PV_FILES < <(
  printf "%s\n" "${ALL_YMLS[@]}" |
  grep -E '\-pv[^/]*\.ya?ml$' || true
)

# 4️⃣ Persistent Volume Claim files
mapfile -t PVC_FILES < <(
  printf "%s\n" "${ALL_YMLS[@]}" |
  grep -E '\-pvc[^/]*\.ya?ml$' || true
)

# 5️⃣ Remaining YAML files
mapfile -t OTHER_FILES < <(
  printf "%s\n" "${ALL_YMLS[@]}" |
  grep -v -E '(namespace|[^a-z]ns)[^/]*\.ya?ml$|\-pv[^/]*\.ya?ml$|\-pvc[^/]*\.ya?ml$'
)

# ---- Apply in strict order ----

if [ ${#NAMESPACE_FILES[@]} -gt 0 ]; then
  echo "🔹 Applying Namespace manifests..."
  apply_files "${NAMESPACE_FILES[@]}"
fi

if [ ${#PV_FILES[@]} -gt 0 ]; then
  echo "🔹 Applying Persistent Volumes..."
  apply_files "${PV_FILES[@]}"
fi

if [ ${#PVC_FILES[@]} -gt 0 ]; then
  echo "🔹 Applying Persistent Volume Claims..."
  apply_files "${PVC_FILES[@]}"
fi

if [ ${#OTHER_FILES[@]} -gt 0 ]; then
  echo "🔹 Applying remaining resources..."
  apply_files "${OTHER_FILES[@]}"
fi

echo "==========================================="
echo "✅ All Kubernetes manifests applied successfully"
