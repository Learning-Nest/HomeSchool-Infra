variable "name_prefix" {
  description = "Prefix for resource names, for example hs-dev."
  type        = string
}

variable "resource_group_name" {
  description = "Existing resource group."
  type        = string
}

variable "location" {
  description = "Azure region (same region as the VNet)."
  type        = string
}

variable "virtual_network_name" {
  description = "Name of the environment's VNet (the jump VM gets its own subnet inside it)."
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR of the jump VM subnet. Must sit inside the VNet and not overlap the other subnets."
  type        = string
}

variable "allowed_ssh_cidrs" {
  description = "Public IP ranges allowed to SSH to the VM, for example [\"203.0.113.7/32\"] (your own address). Never 0.0.0.0/0."
  type        = list(string)

  validation {
    condition     = length(var.allowed_ssh_cidrs) > 0 && !contains(var.allowed_ssh_cidrs, "0.0.0.0/0") && !contains(var.allowed_ssh_cidrs, "*")
    error_message = "allowed_ssh_cidrs must list at least one specific address range and must not be open to the whole internet."
  }
}

variable "ssh_public_key" {
  description = "The PUBLIC half of an SSH key (ssh-rsa ... or ssh-ed25519 ...). Password logins are disabled. A public key is not a secret."
  type        = string

  validation {
    condition     = can(regex("^ssh-(rsa|ed25519) ", var.ssh_public_key))
    error_message = "ssh_public_key must be an OpenSSH public key starting with ssh-rsa or ssh-ed25519."
  }
}

variable "admin_username" {
  description = "Linux admin user."
  type        = string
  default     = "azureuser"
}

variable "size" {
  description = "VM size. A burstable B1s is plenty for forwarding a database connection."
  type        = string
  default     = "Standard_B1s"
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
}
