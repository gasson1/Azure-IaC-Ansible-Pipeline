# 1. Konfiguracja dostawcy Azure
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# 2. Główna grupa zasobów
resource "azurerm_resource_group" "rg" {
  name     = "rg-dyplom-prod"
  location = "westeurope"
}

# 3. Sieć wirtualna (VNet)
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-dyplom"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# 4. Podsieć 1: Warstwa Web (Frontend)
resource "azurerm_subnet" "web_subnet" {
  name                 = "snet-web"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# 5. Podsieć 2: Warstwa Bazy Danych (Backend)
resource "azurerm_subnet" "db_subnet" {
  name                 = "snet-db"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# 6. Publiczny adres IP dla serwera Web
resource "azurerm_public_ip" "web_pip" {
  name                = "pip-web"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# 7. Reguły bezpieczeństwa (NSG) dla serwera Web (Otwarte porty 22 SSH i 80 HTTP)
resource "azurerm_network_security_group" "web_nsg" {
  name                = "nsg-web"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# 8. Karta sieciowa dla VM Web
resource "azurerm_network_interface" "web_nic" {
  name                = "nic-web"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.web_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.web_pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "web_nic_assoc" {
  network_interface_id      = azurerm_network_interface.web_nic.id
  network_security_group_id = azurerm_network_security_group.web_nsg.id
}

# 9. Maszyna wirtualna Web (Ubuntu 22.04 LTS)
resource "azurerm_linux_virtual_machine" "web_vm" {
  name                            = "vm-web"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  size                            = "Standard_B1s" # Najtańsza opcja pasująca do darmowej subskrypcji
  admin_username                  = "azureuser"
  admin_password                  = "Student123456!" # Pamiętaj to hasło
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.web_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

# 10. Karta sieciowa dla VM Bazy Danych
resource "azurerm_network_interface" "db_nic" {
  name                = "nic-db"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.db_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# 11. Maszyna wirtualna Bazy Danych (Ubuntu 22.04 LTS)
resource "azurerm_linux_virtual_machine" "db_vm" {
  name                            = "vm-db"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  size                            = "Standard_B1s"
  admin_username                  = "azureuser"
  admin_password                  = "Student123456!"
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.db_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

# Wyświetlenie publicznego adresu IP serwera Web po zakończeniu wdrożenia
output "web_public_ip" {
  value       = azurerm_public_ip.web_pip.ip_address
  description = "Publiczny adres IP serwera Web"
}

output "db_private_ip" {
  value       = azurerm_network_interface.db_nic.private_ip_address
  description = "Prywatny adres IP serwera Bazy Danych"
}