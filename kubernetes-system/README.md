# Системные компоненты для кластера

## ArgoCD

## Grafana + Loki

helm install --namespace monitoring --atomic grafana ./grafana

helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install --namespace monitoring --atomic loki grafana/loki-stack

Адрес Loki: http://loki:3100

## Prometheus

helm install --namespace monitoring --atomic prometheus ./prometheus