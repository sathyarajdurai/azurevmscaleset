resource "azurerm_linux_virtual_machine_scale_set" "web_scale_set" {
  name                = "${local.name}-set"
  resource_group_name = azurerm_resource_group.web_rg.name
  location            = azurerm_resource_group.web_rg.location
  sku                 = "Standard_DS1_V2"
  instances           = 2
  admin_username      = "adminuser"

  admin_ssh_key {
    username   = "adminuser"
    public_key = data.azurerm_ssh_public_key.vm_key.public_key
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "example"
    primary = true
    network_security_group_id = azurerm_network_security_group.web_sg.id

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.web_sub.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.lb_backend_scale.id]
    }
  }
}

# resource "azurerm_public_ip" "web_scale_ip" {
#   name                = "public_ip_webscale"
#   resource_group_name = azurerm_resource_group.web_rg.name
#   location            = azurerm_resource_group.web_rg.location
#   allocation_method   = "Static"

#   tags = {
#     environment = "lab_test"
#   }
# }