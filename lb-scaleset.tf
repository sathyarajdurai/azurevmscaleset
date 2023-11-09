resource "azurerm_public_ip" "lb_scale_ip" {
  name                = "public_ip_webscale"
  resource_group_name = azurerm_resource_group.web_rg.name
  location            = azurerm_resource_group.web_rg.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    environment = "lab_test"
  }
}

resource "azurerm_lb" "lb_test" {
  name                = "TestLoadBalancer"
  location            = azurerm_resource_group.web_rg.location
  resource_group_name = azurerm_resource_group.web_rg.name


  frontend_ip_configuration {
    name                 = "webscale"
    public_ip_address_id = azurerm_public_ip.lb_scale_ip.id
  }
  sku = "Standard"
}

resource "azurerm_lb_backend_address_pool" "lb_backend_scale" {
  loadbalancer_id = azurerm_lb.lb_test.id
  name            = "webscaleset"
}


resource "azurerm_lb_probe" "web_lb_probe" {
  name            = "tcp-probe"
  protocol        = "Tcp"
  port            = 80
  loadbalancer_id = azurerm_lb.lb_test.id
}

resource "azurerm_lb_probe" "ssh_lb_probe" {
  name            = "ssh-probe"
  protocol        = "Tcp"
  port            = 22
  loadbalancer_id = azurerm_lb.lb_test.id
}

resource "azurerm_lb_rule" "web_lb_rule_scale" {
  name                           = "web-scale-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = azurerm_lb.lb_test.frontend_ip_configuration[0].name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.lb_backend_scale.id]
  probe_id                       = azurerm_lb_probe.web_lb_probe.id
  loadbalancer_id                = azurerm_lb.lb_test.id
}

resource "azurerm_lb_rule" "ssh_lb_rule_scale" {
  name                           = "ssh-scale-rule"
  protocol                       = "Tcp"
  frontend_port                  = 22
  backend_port                   = 22
  frontend_ip_configuration_name = azurerm_lb.lb_test.frontend_ip_configuration[0].name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.lb_backend_scale.id]
  probe_id                       = azurerm_lb_probe.ssh_lb_probe.id
  loadbalancer_id                = azurerm_lb.lb_test.id
}

resource "azurerm_lb_nat_rule" "web_nat" {
  resource_group_name            = azurerm_resource_group.web_rg.name
  loadbalancer_id                = azurerm_lb.lb_test.id
  name                           = "webnat"
  protocol                       = "Tcp"
  frontend_port_start            = 1
  frontend_port_end              = 4
  backend_port                   = 22
  backend_address_pool_id        = azurerm_lb_backend_address_pool.lb_backend_scale.id
  frontend_ip_configuration_name = "webscale"
}

