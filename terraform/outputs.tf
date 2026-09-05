output "static_website_url" {
  description = "URL der statischen Website"
  value       = azurerm_storage_account.website.primary_web_endpoint
}