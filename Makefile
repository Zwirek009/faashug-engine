### Variables ################
project_id = faashug-dev
region = europe-west3
##############################

# INFO: Remember about setting vars also in variables.tf file

# INFO: Do not change this value
tf_state_bucket_name = ${project_id}-tfstates

tfstate-bucket:
	gsutil mb -p ${project_id} -l ${region} gs://${tf_state_bucket_name} || gsutil ls gs://${tf_state_bucket_name}
	gsutil versioning set on gs://${tf_state_bucket_name}

terraform-init: tfstate-bucket
	rm -rf .terraform
	terraform init -backend-config="bucket=${tf_state_bucket_name}"

terraform-plan:
	terraform plan

terraform-apply:
	terraform apply

terraform-autoapply:
	terraform apply -auto-approve

terraform-refresh:
	terraform refresh

terraform-output:
	terraform output

# INFO: Cloud Storage tfstate bucket and buckets with objects in them would not be destroyed
terraform-destroy:
	terraform destroy