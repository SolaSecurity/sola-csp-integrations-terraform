# ![Sola Logo](sola.png) Sola's CPS Integrations Terraform ![Sola Logo](sola.png)


### Sola's AWS integration managed via Terraform

_(`role_name` is optional)_
```hcl-terraform
module "sola-aws-integration" {
  source               = "github.com/SolaSecurity/sola-cps-integrations-terraform/aws"
  role_name            = "ROLE_NAME"
  role_external_id     = "EXTERNAL_ID"
  sola_organization_id = "SOLA_AWS_ACCOUNT_ID"
}

output "role_arn" {
  value = module.sola-aws-integration.sola_aws_integration_role_arn
}
```


### Sola's GCP integration managed via Terraform

_(`service_account_name` is optional)_
```hcl-terraform
module "sola-gcp-integration" {
  source     = "github.com/SolaSecurity/sola-cps-integrations-terraform/gcp"
  service_account_name = "SERVICE_ACCOUNT_NAME"
  project_id           = "PROJECT_ID"
}

output "private_key" {
  value     = module.sola-gcp-integration.private_key
  sensitive = true
}

resource "null_resource" "save_key" {
  provisioner "local-exec" {
    command = <<EOT
    terraform output -json private_key > private_key.json
    cat private_key.json
    EOT
  }
}
```


### Sola's Azure integration managed via Terraform

_(`app_name` is optional)_
```hcl-terraform
module "sola-azure-integration" {
  source          = "github.com/SolaSecurity/sola-cps-integrations-terraform/azure"
  app_name        = "APPLICATION_NAME"
  subscription_id = "SUBSCRIPTION_ID"
}

output "credentials" {
  value     = module.sola-azure-integration.credentials
  sensitive = true
}

output "grant_admin_consent_url" {
  value = module.sola-azure-integration.grant_admin_consent_url
}

resource "null_resource" "print_credentials" {
  provisioner "local-exec" {
    command = <<EOT
    terraform output -json credentials > credentials.json
    cat credentials.json | sed -E 's/[{"}]//g; s/,/\n/g; s/:/: /'
    echo "\nMake sure you granted admin consent:\n$(terraform output -raw grant_admin_consent_url)"
    EOT
  }
}
```
