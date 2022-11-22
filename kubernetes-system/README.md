# Системные компоненты для кластера

## ArgoCD

```bash
cd argocd
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -n argocd -f ingress.yml
kubectl apply -n argocd -f user.yml
kubectl apply -n argocd -f policy.yml
```

## Grafana + Loki

```bash
helm install --atomic grafana ./grafana
```

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install --atomic loki grafana/loki-stack
```

Loki DataSource URL: `http://loki:3100`

## Prometheus

```bash
helm install --atomic prometheus ./prometheus
kubectl apply -f ./prometheus/admin-user.yaml
```

Prometheus DataSource URL: `http://prometheus:9090`