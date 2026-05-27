# Redis Helm Chart

This Helm chart deploys **Redis 7.2.4** on Kubernetes with the following components:

- `Deployment` — Redis server pod
- `Service` — ClusterIP on port **7822** (mapped to Redis container port 6379)
- `ConfigMap` — Non-sensitive Redis tuning parameters
- `Secret` — Redis password (base64-encoded automatically by Helm)
- `HorizontalPodAutoscaler` — Auto-scales between 1–5 replicas based on CPU/Memory

## Directory Structure

```
redis/
├── Chart.yaml
├── values.yaml
└── templates/
    ├── _helpers.tpl
    ├── deployment.yaml
    ├── service.yaml
    ├── configmap.yaml
    ├── secret.yaml
    ├── hpa.yaml
    └── tests/
        └── test-connection.yaml
```

## Prerequisites

- Kubernetes 1.23+
- Helm 3.10+
- Metrics Server installed (required for HPA)

## Installation

### 1. Install with default values

```bash
helm install redis ./redis --namespace hiringbell --create-namespace
```

### 2. Install with a custom password

```bash
helm install redis ./redis \
  --namespace hiringbell \
  --create-namespace \
  --set secret.REDIS_PASSWORD="my-super-secret-password"
```

### 3. Install with a custom values file

```bash
helm install redis ./redis -f my-values.yaml --namespace hiringbell
```

## Upgrade

```bash
helm upgrade redis ./redis --namespace hiringbell --set secret.REDIS_PASSWORD="new-password"
```

## Verify Deployment

```bash
# Check pods
kubectl get pods -n hiringbell -l app.kubernetes.io/name=redis

# Check service (port 7822)
kubectl get svc -n hiringbell redis

# Run Helm connection test
helm test redis -n hiringbell

# Connect manually from inside the cluster
kubectl run redis-client --rm -it --image redis:7.2.4-alpine -- \
  redis-cli -h redis -p 7822 -a <your-password> ping
```

## Uninstall

```bash
helm uninstall redis --namespace hiringbell
```

## Configuration Reference

| Key | Default | Description |
|-----|---------|-------------|
| `image.tag` | `7.2.4-alpine` | Redis image tag |
| `service.port` | `7822` | Service port exposed inside the cluster |
| `service.targetPort` | `6379` | Redis container port |
| `secret.REDIS_PASSWORD` | `changeme-strong-password` | Redis auth password |
| `config.REDIS_MAXMEMORY` | `256mb` | Max memory Redis can use |
| `config.REDIS_MAXMEMORY_POLICY` | `allkeys-lru` | Eviction policy |
| `autoscaling.enabled` | `true` | Enable HPA |
| `autoscaling.minReplicas` | `1` | Min replicas |
| `autoscaling.maxReplicas` | `5` | Max replicas |
| `autoscaling.targetCPUUtilizationPercentage` | `70` | CPU threshold for scaling |
| `resources.requests.memory` | `128Mi` | Memory request |
| `resources.limits.memory` | `512Mi` | Memory limit |

## Security Notes

> ⚠️ **Never commit `values.yaml` with real passwords to source control.**
> Use `--set secret.REDIS_PASSWORD=...` at deploy time, or use an external secrets manager (e.g., HashiCorp Vault, AWS Secrets Manager, Sealed Secrets).
