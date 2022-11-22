[English](README.en.md)

# Репозиторий инфраструктуры <!-- omit in toc -->

В данном репозитории хранится инфраструктурная часть проекта "Пельменная". Основной код и описание проекта в репозитории:

[Momo Store](https://gitlab.praktikum-services.ru/a.cherkashin/momo-store)

# Оглавление <!-- omit in toc -->

- [Cтруктура репозитория](#cтруктура-репозитория)
- [Подготовка инфраструктуры](#подготовка-инфраструктуры)
  - [Кластер и хранилище](#кластер-и-хранилище)
  - [Подготовка кластера](#подготовка-кластера)
- [Установка ArgoCD](#установка-argocd)
- [Установка Grafana](#установка-grafana)
- [Установка Loki](#установка-loki)
- [Установка Prometheus](#установка-prometheus)
- [Правила версионирования](#правила-версионирования)
- [Правила внесения изменений в репозиторий](#правила-внесения-изменений-в-репозиторий)

# Cтруктура репозитория

```
.
├── chart                  - Helm чарт приложения
├── kubernetes-system      - Чарты и манифесты для дополнительных компонентов инфраструктуры
│   ├── argo
│   ├── grafana
│   ├── prometheus
│   ├── acme-issuer.yml
│   ├── README.md
│   └── sa.yml
├── manifests               - манифесты для развертывания вручную
├── terraform               - манифесты IaC
├── .gitlab-ci.yml
└── README.md
```

# Подготовка инфраструктуры

## Кластер и хранилище

Заполнить файл `.s3conf`

```bash
terraform init
terraform plan -var-file secret.tfvars
terraform apply - var-file secret.tfvars
```

## Подготовка кластера

Установить Ingress-контроллер NGINX по инфтрукции от Яндекс:

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm install ingress-nginx ingress-nginx/ingress-nginx
```

Установить менеджер сертификатов:

```bash
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.10.0/cert-manager.yaml
```

Создать объект ClusterIssuer

```bash
kubectl apply -f acme-issuer.yml
```

Манифест `sa.yml` необходим для создания сервисного аккуанта для последующего формирования статического конфига для доступа к кластеру, например из CI/CD

# Установка ArgoCD

Доступ в ArgoCD: https://argocd.cherkashin.org

Login/Password: 

```bash
cd kubernetes-system/argocd
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -n argocd -f ingress.yml
kubectl apply -n argocd -f user.yml
kubectl apply -n argocd -f policy.yml
```
После установки добавить приложение `momo-store` через YAML

```yaml
project: momo-store
source:
  repoURL: 'https://nexus.praktikum-services.ru/repository/06-a-cherkashin-momo-store/'
  targetRevision: x
  chart: momo-store
destination:
  server: 'https://kubernetes.default.svc'
  namespace: default
syncPolicy:
  automated:
    prune: true
    selfHeal: true
```

Дальнейший мониторинг приложения и обновление производится только через Argo (либо вручную, либо в авторежиме)

# Установка Grafana

Доступ в Grafana: https://grafana.cherkashin.org

Login/Password: user/Testusr1234

```bash
cd kubernetes-system/grafana
helm install --atomic grafana ./
```

# Установка Loki

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install --atomic loki grafana/loki-stack
```

Адрес Loki для добавления в качестве DataSource: `http://loki:3100`

# Установка Prometheus

URL для доступа: https://prometheus.cherkashin.org/

```bash
cd kubernetes-system/prometheus
helm install --atomic prometheus ./
kubectl apply -f ./admin-user.yaml
```

Адрес Prometheus для добавления в качестве DataSource: `http://prometheus:9090`

# Правила версионирования

Версия приложения формируется из переменной `VERSION` в пайплайне - `1.0.${CI_PIPELINE_ID}`

Контейнеры фронтенда и бэкенда собираются и публикуются в отдельных пайплайнах, при сборке каждый образ получает тег с номером версии приложения. После тестирования образа на успешный запуск и отработку запросов (Postman), образ тегируется как latest.

Образы публикуются в GitLab Container Registry.

# Правила внесения изменений в репозиторий

Все изменения должны производиться в отдельном бранче с последующим MR.
