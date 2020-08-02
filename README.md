# faashug-engine

OpenFaaS backend for my master's thesis project

## Deployment

### 1. Prerequisites installed and configured

* `terraform` installed, v0.12 or above
* `gcloud` installed
* `docker` installed
* `kubectl` installed
* `arkade` installed (`curl -SLsf https://dl.get-arkade.dev/ | sudo sh` on MacOS / Linux)
* `faas-cli` installed (`curl -sSL https://cli.openfaas.com | sudo -E sh` on MacOS / Linux)
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

### 5. (optional, 4. required) Configure OpenFaaS environment on the GKE cluster

Instructions below based on [official OpenFaaS documentation](https://github.com/openfaas/workshop/blob/master/lab1b.md#run-on-gke-google-kubernetes-engine)

```bash
kubectl create clusterrolebinding "cluster-admin-$(whoami)" \
--clusterrole=cluster-admin \
--user="$(gcloud config get-value core/account)"
```

Wait until command below reports success:

```bash
kubectl rollout status -n openfaas deploy/gateway
```

Get `[EXTERNAL-IP]` from running command below...

```bash
kubectl get svc -o wide gateway-external -n openfaas
```

... paste the `[EXTERNAL-IP]` value to script below and run it to log in to your OpenFaaS environment:

```bash
export OPENFAAS_URL="[EXTERNAL-IP]:8080" # Populate before running

# This command retrieves your password
PASSWORD=$(kubectl get secret -n openfaas basic-auth -o jsonpath="{.data.basic-auth-password}" | base64 --decode; echo)

# This command logs in and saves a file to ~/.openfaas/config.yml
echo -n $PASSWORD | faas-cli login --username admin --password-stdin
```

Verify configuration was successfull by getting no ERROR/TIMEOUT running:

```bash
faas-cli list
```

You can also use the same credentials to access OpenFaaS UI through web browser, using `[EXTERNAL-IP]` and credentials used above.

## Docker Images

Docker images definitions are stored in `images` folder

### long-running-logger

Container for testing long-lunning task execution. Container executes script for number of minutes passed as EXECUTION_MINUTES env (default 1 minute), logging progress each 30 seconds.

Specialized image version tags (tags with suffix like x.x.x-[SPECIALIZED_TAG_SUFFIX]):

* `x.x.x-cloudrun` - image optimized to run on Cloud Run

#### Build

```bash
docker build --no-cache -t long-running-logger images/long-running-logger
```

...or for specialized image version

```bash
docker build --no-cache -t long-running-logger-[SPECIALIZED_TAG_SUFFIX] -f images/long-running-logger/Dockerfile.[SPECIALIZED_TAG_SUFFIX] images/long-running-logger
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

`cloudrun` specialized version (access through `GET locahost:9090`):

```bash
PORT=8080 && docker run -p 9090:${PORT} -e PORT=${PORT} long-running-logger-cloudrun
```

#### Push to registry

Use [Semantic Versioning 2.0.0](https://semver.org/) for tagging new versions of the container

* (optional) `gcloud auth configure-docker`
* `docker tag long-running-logger eu.gcr.io/[PROJECT_ID]/long-running-logger:[NEW_SEMVER_TAG]` OR `docker tag long-running-logger-[SPECIALIZED_TAG_SUFFIX] eu.gcr.io/[PROJECT_ID]/long-running-logger:[NEW_SEMVER_TAG_WITH_SPECIALIZED_SUFFIX]`
* `docker push eu.gcr.io/[PROJECT_ID]/long-running-logger:[NEW_SEMVER_TAG]`
