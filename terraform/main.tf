# Aktuelle Azure-Login-Daten
data "azurerm_client_config" "current" {}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

# Storage Account mit Static Website
resource "azurerm_storage_account" "website" {
  name                     = "cloudprojektwebsite"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  https_traffic_only_enabled    = true
  min_tls_version               = "TLS1_2"
  public_network_access_enabled = true

  static_website {
    index_document = "index.html"
  }
}

# Upload der index.html in den Static-Website-Container
resource "azurerm_storage_blob" "index" {
  name                   = "index.html"
  storage_account_name   = azurerm_storage_account.website.name
  storage_container_name = "$web"
  type                   = "Block"
  source                 = "../website/index.html"
  content_type           = "text/html"
}

# HINWEIS:
# Azure Front Door ist Bestandteil der konzeptionellen Zielarchitektur.
# Die praktische Bereitstellung war im verwendeten Azure-for-Students-
# Abonnement nicht möglich (403 Forbidden).
# Die theoretische Terraform-Implementierung bleibt daher dokumentiert
# und wurde mit dem Tutor abgestimmt.

# resource "azurerm_cdn_frontdoor_profile" "main" {
#   name                = "cloud-projekt-fd"
#   resource_group_name = azurerm_resource_group.main.name
#   sku_name            = "Standard_AzureFrontDoor"
# }

# resource "azurerm_cdn_frontdoor_endpoint" "main" {
#   name                     = "cloud-projekt-endpoint"
#   cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id
# }

# resource "azurerm_cdn_frontdoor_origin_group" "main" {
#   name                     = "cloud-projekt-origin-group"
#   cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id

#   load_balancing {}
# }

# resource "azurerm_cdn_frontdoor_origin" "main" {
#   name                          = "cloud-projekt-origin"
#   cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.main.id
#   enabled                       = true
#   host_name                     = azurerm_storage_account.website.primary_web_host

#   certificate_name_check_enabled = true
# }

# resource "azurerm_cdn_frontdoor_route" "main" {
#   name                          = "cloud-projekt-route"
#   cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.main.id
#   cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.main.id
#   cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.main.id]

#   supported_protocols    = ["Https"]
#   patterns_to_match      = ["/*"]
#   forwarding_protocol    = "HttpsOnly"
#   https_redirect_enabled = true
#   enabled                = true
# }