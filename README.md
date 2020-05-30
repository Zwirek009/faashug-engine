# faashug-engine

OpenFaaS backend for my master's thesis project

## Deployment

### 1. Prerequisites installed and configured

* `terraform` installed, v0.12 or above
* `gcloud` installed
* Project with billing on GCP created
* Project set as current/default in `gcloud` (verify using `gcloud config list`)

### 2. Authorize `terraform`` to use your account GCP credentials

```bash
gcloud auth application-default login
export GOOGLE_APPLICATION_CREDENTIALS=~/.config/gcloud/legacy_credentials/[YOUR_GCP_ACCOUNT_MAIL]/adc.json
```

### 3. Apply changes to GCP

* (optional) Modify variables in `variables.tf` and `Makefile`
* (first use setup) Run `make terraform-init`
* Use Makefile (eg. `make terraform-apply`) to do actions instead of bare metal `terraform` actions
