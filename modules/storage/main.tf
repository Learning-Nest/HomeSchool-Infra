# Blob storage for activity pictures (educator uploads, downloaded by the mobile app when an activity loads).
#
# HOW IT IS USED
#   * The container is PRIVATE. Nothing is publicly readable: the API hands out short-lived user-delegation SAS links
#     (default one hour) in the activity response, and the app caches each file by its sha256.
#   * The API uses its user-assigned managed identity (no keys, no connection strings in any setting):
#       - Storage Blob Data Contributor  -> upload / delete / read blobs
#       - Storage Blob Delegator         -> request a user delegation key to sign the download links
#     Both roles are assigned on the account.
#   * Blob soft delete keeps a deleted or overwritten picture recoverable for `soft_delete_days`.
#   * Shared-key access is left enabled only because the azurerm provider reads account properties with it; the API never
#     uses an account key.

resource "azurerm_storage_account" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = var.replication_type
  access_tier              = "Hot"

  min_tls_version                   = "TLS1_2"
  https_traffic_only_enabled        = true
  allow_nested_items_to_be_public   = false
  default_to_oauth_authentication   = true
  cross_tenant_replication_enabled  = false

  blob_properties {
    versioning_enabled = false

    delete_retention_policy {
      days = var.soft_delete_days
    }

    container_delete_retention_policy {
      days = var.soft_delete_days
    }

    # Browsers (the educator editor shows previews straight from the signed link) need CORS; the mobile app does not.
    dynamic "cors_rule" {
      for_each = length(var.cors_allowed_origins) > 0 ? [1] : []
      content {
        allowed_origins    = var.cors_allowed_origins
        allowed_methods    = ["GET", "HEAD"]
        allowed_headers    = ["*"]
        exposed_headers    = ["Content-Length", "Content-Type", "ETag"]
        max_age_in_seconds = 3600
      }
    }
  }
}

resource "azurerm_storage_container" "images" {
  name                  = var.container_name
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = "private"
}

resource "azurerm_role_assignment" "api_blob_data_contributor" {
  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.api_principal_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "api_blob_delegator" {
  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Blob Delegator"
  principal_id         = var.api_principal_id
  principal_type       = "ServicePrincipal"
}
