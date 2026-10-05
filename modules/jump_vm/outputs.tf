output "public_ip" {
  description = "Public IP address to put in DBeaver's SSH tab."
  value       = azurerm_public_ip.this.ip_address
}

output "admin_username" {
  description = "SSH user name."
  value       = var.admin_username
}

output "vm_name" {
  description = "VM name, for az vm start / deallocate."
  value       = azurerm_linux_virtual_machine.this.name
}
