# Системные компоненты для кластера

## ArgoCD

## Grafana + Loki

helm install --atomic grafana ./grafana

helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install --atomic loki grafana/loki-stack

Адрес Loki: http://loki:3100

## Prometheus

helm install --atomic prometheus ./prometheus
kubectl apply -f ./prometheus/admin-user.yaml