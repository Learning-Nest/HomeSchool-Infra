output "id" {
  description = "Storage account resource ID."
  value       = azurerm_storage_account.this.id
}

output "name" {
  description = "Storage account name."
  value       = azurerm_storage_account.this.name
}

output "blob_endpoint" {
  description = "Blob service URL without a trailing slash, e.g. https://sthsdevx7k2.blob.core.windows.net (the API's STORAGE_ACCOUNT_URL)."
  value       = trimsuffix(azurerm_storage_account.this.primary_blob_endpoint, "/")
}

output "container_name" {
  description = "Private container for activity pictures (the API's STORAGE_CONTAINER)."
  value       = azurerm_storage_container.images.name
}
