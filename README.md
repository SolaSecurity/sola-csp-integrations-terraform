# ![Sola Logo](sola.png) Sola's CSP Integrations Terraform ![Sola Logo](sola.png)


### Sola's AWS integration managed via Terraform

_(`role_name` is optional)_
```hcl-terraform
module "sola-aws-integration" {
  source = "github.com/SolaSecurity/sola-csp-integrations-terraform/aws"

  role_external_id     = "EXTERNAL_ID"
  sola_organization_id = "SOLA_AWS_ACCOUNT_ID"
  role_name            = "ROLE_NAME"
}

output "role_arn" {
  value = module.sola-aws-integration.sola_aws_integration_role_arn
}
```


### Sola's GCP integration managed via Terraform

_(`service_account_name` is optional)_
```hcl-terraform
module "sola-gcp-integration" {
  source = "github.com/SolaSecurity/sola-csp-integrations-terraform/gcp"

  project_id           = "PROJECT_ID"
  service_account_name = "SERVICE_ACCOUNT_NAME"
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

  depends_on = [module.sola-gcp-integration]
}
```


### Sola's Azure integration managed via Terraform

_(`app_name` is optional)_
```hcl-terraform
module "sola-azure-integration" {
  source = "github.com/SolaSecurity/sola-csp-integrations-terraform/azure"

  subscription_id = "SUBSCRIPTION_ID"
  app_name        = "APPLICATION_NAME"
}

output "credentials" {
  value     = module.sola-azure-integration.credentials
  sensitive = true
}

resource "null_resource" "print_credentials" {
  provisioner "local-exec" {
    command = <<EOT
    terraform output -json credentials > credentials.json
    cat credentials.json | sed -E 's/[{"}]//g; s/,/\n/g; s/:/: /'
    EOT
  }

  depends_on = [module.sola-azure-integration]
}
```

### Sola's Microsoft Entra ID integration managed via Terraform

_(`app_name` is optional)_
```hcl-terraform
module "sola-ms-entra-id-integration" {
  source = "github.com/SolaSecurity/sola-csp-integrations-terraform/entra_id"
}

output "credentials" {
  value     = module.sola-ms-entra-id-integration.credentials
  sensitive = true
}

output "grant_admin_consent_url" {
  value     = module.sola-ms-entra-id-integration.grant_admin_consent_url
  sensitive = true
}

resource "null_resource" "print_credentials" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "terraform output -json credentials > credentials.json && cat credentials.json | sed -E 's/[{\"}]//g; s/,/\\n/g; s/:/: /'"
  }
  depends_on = [module.sola-ms-entra-id-integration]
}
```
