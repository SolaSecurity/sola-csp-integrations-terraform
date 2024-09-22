output "credentials" {
  value = {
    "Tenant ID" : data.azuread_client_config.current.tenant_id,
    "Client ID" : data.azuread_client_config.current.client_id,
    "Client Secret" : azuread_application_password.sola_app_password.value,
    "Directory Domain" : data.azuread_domains.aad_domains.domains[0].domain_name
  }
  sensitive = true
}

output "grant_admin_consent_url" {
  value = "https://portal.azure.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/CallAnAPI/appId/${azuread_service_principal.sola_sp.client_id}/isMSAApp~/false"
}
