resource "azurerm_resource_group" "web_rg" {
  name     = local.name
  location = "West Europe"
}

resource "azurerm_virtual_network" "web_vnet" {
  name                = "${local.name}-network"
  location            = azurerm_resource_group.web_rg.location
  resource_group_name = azurerm_resource_group.web_rg.name
  address_space       = ["10.0.0.0/16"]
  
  tags = {
    environment = "lab_test"
  }
}

resource "azurerm_subnet" "web_sub" {
  name                 = "lab_subnet2"
  resource_group_name  = azurerm_resource_group.web_rg.name
  virtual_network_name = azurerm_virtual_network.web_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}



resource "azurerm_network_security_group" "web_sg" {
  name                = "VmwebSecurityGroup1"
  location            = azurerm_resource_group.web_rg.location
  resource_group_name = azurerm_resource_group.web_rg.name

  security_rule {
    name                       = "ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range   = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "http"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range   = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "lab_test"
  }
}

# resource "azurerm_network_interface_security_group_association" "example" {
#   network_interface_id      = azurerm_network_interface.web_nic.id
#   network_security_group_id = azurerm_network_security_group.web_sg.id
# }

