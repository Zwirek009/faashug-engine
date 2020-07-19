# faashug-engine

OpenFaaS backend for my master's thesis project

## Deployment

### 1. Prerequisites installed and configured

* `terraform` installed, v0.12 or above
* `gcloud` installed
* `docker` installed
* `kubectl` installed
* Project with billing on GCP created
* Project set as current/default in `gcloud` (verify using `gcloud config list`)

### 2. Authorize terraform to use your account GCP credentials

```bash
gcloud auth application-default login
```

### 3. Apply changes to GCP

* (optional) Modify variables in `variables.tf` and `Makefile`
* (first use setup) Run `make terraform-init`
* Use Makefile (eg. `make terraform-apply`) to do actions instead of bare metal `terraform` actions

### 4. (optional) Configure kubectl to use GKE zonal cluster

Update command below using with your terraform outputs (eg. run `make terraform-output` to get them).

```bash
gcloud container clusters get-credentials [PROJECT_ID]-gke --zone=[ZONE]
```

## Docker Images

Docker images definitions are stored in `images` folder

### long-running-logger

Container for testing long-lunning task execution. Container executes script for number of minutes passed as EXECUTION_MINUTES env (default 1 minute), logging progress each 30 seconds.

#### Build

```bash
docker build --no-cache -t long-running-logger images/long-running-logger
```

#### Run locally

Using default execution time (default 1 minute):
```bash
docker run -t long-running-logger
```

Using custom execution time (2 minutes on example below):
```bash
docker run -t --env EXECUTION_MINUTES=2 long-running-logger
```

#### Push to registry

Use [Semantic Versioning 2.0.0](https://semver.org/) for tagging new versions of the container

* (optional) `gcloud auth configure-docker`
* `docker tag long-running-logger eu.gcr.io/[PROJECT_ID]/long-running-logger:[NEW_SEMVER_TAG]`
* `docker push eu.gcr.io/[PROJECT_ID]/long-running-logger:[NEW_SEMVER_TAG]`
