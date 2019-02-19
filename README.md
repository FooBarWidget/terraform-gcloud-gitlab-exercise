This excerise deploys Gitlab and Gitlab Runner on Google Cloud using Terraform.

## Requirements

- Terraform
- Ansible
- Google Cloud CLI

## Usage

1. Setup config/ directory using the example files. Make sure the directory is chmod 700.
2. Create a Google Cloud project.
3. Create a Google Cloud DNS zone. Ensure that the zone name equals the `root_domain` option in config/.
4. Ensure that the root domain has these NS records:

       ns-cloud-c1.googledomains.com.
       ns-cloud-c2.googledomains.com.
       ns-cloud-c3.googledomains.com.
       ns-cloud-c4.googledomains.com.

5. Run: `gcloud auth application-default login`
6. Run: `cd gitlab && terraform apply -vars-file=../config/terraform.tfvars terraform && cd ..`
