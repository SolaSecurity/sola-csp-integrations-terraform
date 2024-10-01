locals {
  roles = ["Reader", "Security Reader"]
}

data "azuread_client_config" "current" {}

data "azuread_domains" "aad_domains" {
  only_initial = true
}

data "azuread_application_published_app_ids" "well_known" {}

data "azuread_service_principal" "msgraph" {
  client_id = data.azuread_application_published_app_ids.well_known.result["MicrosoftGraph"]
}

resource "random_string" "sola_app_postfix" {
  length  = 4
  special = false
  upper   = false
  lower   = true
  numeric = true
}

resource "azuread_application_registration" "sola_app" {
  display_name = "${var.app_name}-${random_string.sola_app_postfix.result}"
}

resource "azuread_service_principal" "sola_sp" {
  client_id   = azuread_application_registration.sola_app.client_id
  description = "Sola's integration application service principal"
}

resource "azuread_application_password" "sola_app_password" {
  application_id    = azuread_application_registration.sola_app.id
  end_date_relative = "87600h" # 10 years
}

resource "azuread_application_api_access" "graph_api_access" {
  application_id = azuread_application_registration.sola_app.id
  api_client_id  = data.azuread_application_published_app_ids.well_known.result["MicrosoftGraph"]

  scope_ids = [
    data.azuread_service_principal.msgraph.oauth2_permission_scope_ids["Directory.Read.All"],
  ]
}

resource "azurerm_role_assignment" "sola_sp_roles" {
  for_each             = toset(local.roles)
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = each.value
  principal_id         = azuread_service_principal.sola_sp.object_id
}

resource "null_resource" "open_admin_consent_url" {
  provisioner "local-exec" {
    command = <<EOT
    URL="https://portal.azure.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/CallAnAPI/appId/${azuread_service_principal.sola_sp.client_id}/isMSAApp~/false"
    if [[ "$OSTYPE" == "darwin"* ]]; then
      open $URL
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
      xdg-open $URL
    elif [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" ]]; then
      start $URL
    fi
    EOT
  }

  depends_on = [
    azurerm_role_assignment.sola_sp_roles
  ]
}
