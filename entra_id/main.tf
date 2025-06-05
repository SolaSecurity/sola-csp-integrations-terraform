resource "random_string" "sola_app_postfix" {
  length  = 4
  special = false
  upper   = false
  lower   = true
  numeric = true
}

resource "azuread_application_registration" "sola_app" {
  display_name = "${var.app_name}-${random_string.sola_app_postfix.result}"
  
  lifecycle {
    create_before_destroy = false
  }
}

resource "azuread_service_principal" "sola_sp" {
  client_id   = azuread_application_registration.sola_app.client_id
  description = "Sola's integration application service principal"
  
  depends_on = [azuread_application_api_access.graph_api_access]
}

resource "azuread_application_password" "sola_app_password" {
  application_id = azuread_application_registration.sola_app.id
  end_date       = timeadd(timestamp(), "87600h") # 10 years
  
  depends_on = [azuread_application_api_access.graph_api_access]
}

resource "azuread_application_api_access" "graph_api_access" {
  application_id = azuread_application_registration.sola_app.id
  api_client_id  = data.azuread_application_published_app_ids.well_known.result["MicrosoftGraph"]

  role_ids = [
    data.azuread_service_principal.msgraph.app_role_ids["Application.Read.All"],
    data.azuread_service_principal.msgraph.app_role_ids["AuditLog.Read.All"],
    data.azuread_service_principal.msgraph.app_role_ids["Directory.Read.All"],
    data.azuread_service_principal.msgraph.app_role_ids["Domain.Read.All"],
    data.azuread_service_principal.msgraph.app_role_ids["Group.Read.All"],
    data.azuread_service_principal.msgraph.app_role_ids["IdentityProvider.Read.All"],
    data.azuread_service_principal.msgraph.app_role_ids["Policy.Read.All"],
    data.azuread_service_principal.msgraph.app_role_ids["User.Read.All"]
  ]
}

resource "null_resource" "open_admin_consent_url" {
  provisioner "local-exec" {
    command = <<EOT
    URL="https://portal.azure.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/CallAnAPI/appId/${azuread_service_principal.sola_sp.client_id}/isMSAApp~/false"
    sleep 10 # Wait for the graph api access to be updated
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
    azuread_application_api_access.graph_api_access
  ]
}
