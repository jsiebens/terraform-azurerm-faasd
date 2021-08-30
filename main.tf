locals {
  generate_password   = var.basic_auth_password == null || var.basic_auth_password == ""
  basic_auth_user     = var.basic_auth_user
  basic_auth_password = local.generate_password ? random_password.faasd[0].result : var.basic_auth_password

  user_data_vars = {
    basic_auth_user     = local.basic_auth_user
    basic_auth_password = local.basic_auth_password
    domain              = var.domain
    email               = var.email
  }
}

resource "random_password" "faasd" {
  count   = local.generate_password ? 1 : 0
  length  = 16
  special = false
}

resource "azurerm_public_ip" "faasd" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  tags                = var.tags
}

resource "azurerm_network_interface" "faasd" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.faasd.id
  }
  tags = var.tags
}

resource "azurerm_network_security_group" "faasd" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "AllowFaasdSSH"
    priority                   = 1001
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "22"
    destination_address_prefix = azurerm_network_interface.faasd.private_ip_address
  }

  dynamic "security_rule" {
    for_each = var.domain == "" ? [1] : []
    content {
      access                     = "Allow"
      direction                  = "Inbound"
      name                       = "AllowFaasdHTTP"
      priority                   = 1002
      protocol                   = "Tcp"
      source_port_range          = "*"
      source_address_prefix      = "*"
      destination_port_range     = 8080
      destination_address_prefix = azurerm_network_interface.faasd.private_ip_address
    }
  }
  dynamic "security_rule" {
    for_each = var.domain == "" ? [] : [1]
    content {
      access                     = "Allow"
      direction                  = "Inbound"
      name                       = "AllowFaasdHTTP"
      priority                   = 1002
      protocol                   = "Tcp"
      source_port_range          = "*"
      source_address_prefix      = "*"
      destination_port_range     = 80
      destination_address_prefix = azurerm_network_interface.faasd.private_ip_address
    }
  }
  dynamic "security_rule" {
    for_each = var.domain == "" ? [] : [1]
    content {
      access                     = "Allow"
      direction                  = "Inbound"
      name                       = "AllowFaasdHTTPS"
      priority                   = 1003
      protocol                   = "Tcp"
      source_port_range          = "*"
      source_address_prefix      = "*"
      destination_port_range     = 443
      destination_address_prefix = azurerm_network_interface.faasd.private_ip_address
    }
  }
}

resource "azurerm_network_interface_security_group_association" "faasd" {
  network_interface_id      = azurerm_network_interface.faasd.id
  network_security_group_id = azurerm_network_security_group.faasd.id
}

resource "azurerm_linux_virtual_machine" "faasd" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.size
  admin_username      = var.admin_username

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.public_key
  }

  custom_data = base64encode(templatefile("${path.module}/templates/startup.sh", local.user_data_vars))

  network_interface_ids = [
    azurerm_network_interface.faasd.id
  ]

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  tags = var.tags
}
