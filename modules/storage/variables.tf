variable "name" {
  description = "Storage account name: 3-24 lowercase letters and digits, globally unique."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
    error_message = "Storage account names must be 3-24 lowercase letters and digits."
  }
}

variable "resource_group_name" {
  description = "Existing resource group."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "container_name" {
  description = "Private container that holds the activity pictures. The API reads it from STORAGE_CONTAINER (default activity-images)."
  type        = string
  default     = "activity-images"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", var.container_name))
    error_message = "Container names are 3-63 lowercase letters, digits and hyphens."
  }
}

variable "replication_type" {
  description = "LRS for dev/nonprod, GRS (or ZRS) for prod. Pictures can be re-uploaded, so LRS is acceptable everywhere if cost matters."
  type        = string
  default     = "LRS"

  validation {
    condition     = contains(["LRS", "ZRS", "GRS", "RAGRS", "GZRS", "RAGZRS"], var.replication_type)
    error_message = "replication_type must be LRS, ZRS, GRS, RAGRS, GZRS or RAGZRS."
  }
}

variable "soft_delete_days" {
  description = "Days a deleted blob or container stays recoverable (1-365)."
  type        = number
  default     = 7

  validation {
    condition     = var.soft_delete_days >= 1 && var.soft_delete_days <= 365
    error_message = "soft_delete_days must be between 1 and 365."
  }
}

variable "cors_allowed_origins" {
  description = "Browser origins allowed to GET pictures (the admin console / educator editor). Empty = no CORS rule."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for o in var.cors_allowed_origins : o != "*"])
    error_message = "cors_allowed_origins must list explicit origins, never a wildcard."
  }
}

variable "api_principal_id" {
  description = "Principal (object) ID of the API's user-assigned managed identity; it receives the two Blob roles."
  type        = string
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
}
