[Russian](README.ru.md)

# Infrastructure repository <!-- omit in toc -->

This repository stores the infrastructure part of the Pelmennaya project. Main code and description of the project in the repository:

[Momo Store](https://github.com/CherDag/momo-store)

# Table of contents <!-- omit in toc -->

- [Repository structure](#repository-structure)
- [Preparing infrastructure](#preparing-infrastructure)
  - [Cluster and storage](#cluster-and-storage)
  - [Preparing the cluster](#preparing-the-cluster)
- [Install ArgoCD](#install-argocd)
- [Install Grafana](#install-grafana)
- [Install Loki](#install-loki)
- [Installing Prometheus](#installing-prometheus)
- [Versioning rules](#versioning-rules)
- [Rules for making changes to the repository](#rules-for-making-changes-to-the-repository)

# Repository structure

```
.
├── chart - Helm chart app
├── kubernetes-system - Charts and manifests for additional infrastructure components
│ ├── argo
│ ├── grafana
│ ├── prometheus
│ ├── acme-issuer.yml
│ ├── README.md
│ └── sa.yml
├── manifests - manifests for manual deployment
├── terraform - IaC manifests
├── .gitlab-ci.yml
└── README.md
```

# Preparing infrastructure

## Cluster and storage

Fill in the `.s3conf` file

```bash
terraform init
terraform plan -var-file secret.tfvars
terraform apply - var-file secret.tfvars
```

## Preparing the cluster

Install the NGINX Ingress controller according to the instructions from Yandex:

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm install ingress-nginx ingress-nginx/ingress-nginx
```

Install certificate manager:

```bash
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.10.0/cert-manager.yaml
```

Create a ClusterIssuer object

```bash
kubectl apply -f acme-issuer.yml
```

The `sa.yml` manifest is required to create a service account for a static config for accessing the cluster, for example from CI / CD

# Install ArgoCD

Access to ArgoCD: https://argocd.cherkashin.org

Login/Password:

```bash
cd kubernetes-system/argocd
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -n argocd -f ingress.yml
kubectl apply -n argocd -f user.yml
kubectl apply -n argocd -f policy.yml
```
After installation, add the `momo-store` application via YAML

```yaml
project: momo store
source:
  repoURL: 'https://nexus.praktikum-services.ru/repository/06-a-cherkashin-momo-store/'
  targetRevision: x
  chart:momo-store
destination:
  server: 'https://kubernetes.default.svc'
  namespace:default
syncPolicy:
  automatic:
    prune: true
    selfHeal: true
```

Further monitoring of the application and updating is done only through Argo (either manually or in auto mode)

# Install Grafana

Access to Grafana: https://grafana.cherkashin.org

Login/Password: user/Testusr1234

```bash
cd kubernetes-system/grafana
helm install --atomic grafana ./
```

# Install Loki

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install --atomic loki grafana/loki-stack
```

Loki address to add as DataSource: `http://loki:3100`

# Installing Prometheus

Access URL: https://prometheus.cherkashin.org/

```bash
cd kubernetes-system/prometheus
helm install --atomic prometheus ./
kubectl apply -f ./admin-user.yaml
```

Prometheus address to add as DataSource: `http://prometheus:9090`

# Versioning rules

The application version is formed from the `VERSION` variable in the pipeline - `1.0.${CI_PIPELINE_ID}`

The front-end and back-end containers are built and published in separate pipelines, and each image gets a tag with the application's version number when built. After testing the image for successful launch and processing requests (Postman), the image is tagged as latest.

The images are published to the GitLab Container Registry.

# Rules for making changes to the repository

All changes must be made in a separate branch followed by MR.