# A small Linux "jump" VM inside the environment's VNet, so a developer can reach the private PostgreSQL server from a
# laptop with DBeaver's built-in SSH tunnel (no VPN client needed).
#
#   laptop (DBeaver) --SSH, port 22, only from allowed_ssh_cidrs--> jump VM --5432, inside the VNet--> PostgreSQL
#
# The database itself stays private (public access is disabled on the server). The VM runs nothing but sshd; the
# tunnel is plain SSH port forwarding. It resolves the server's private DNS name through the VNet link of the
# network module. Stop it when you are not using it:  az vm deallocate -g <rg> -n <vm name>.

resource "azurerm_subnet" "this" {
  name                 = "snet-jump"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = [var.subnet_cidr]
}

resource "azurerm_network_security_group" "this" {
  name                = "nsg-${var.name_prefix}-jump"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  # Everything else from the internet is denied by Azure's default rules.
  security_rule {
    name                       = "allow-ssh-from-operator"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = var.allowed_ssh_cidrs
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "this" {
  subnet_id                 = azurerm_subnet.this.id
  network_security_group_id = azurerm_network_security_group.this.id
}

resource "azurerm_public_ip" "this" {
  name                = "pip-${var.name_prefix}-jump"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_network_interface" "this" {
  name                = "nic-${var.name_prefix}-jump"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.this.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.this.id
  }
}

resource "azurerm_linux_virtual_machine" "this" {
  name                = "vm-${var.name_prefix}-jump"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.size
  admin_username      = var.admin_username
  tags                = var.tags

  network_interface_ids           = [azurerm_network_interface.this.id]
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  depends_on = [azurerm_subnet_network_security_group_association.this]
}
