resource "azurerm_user_assigned_identity" "frontend-appgw" {
  resource_group_name = data.azurerm_resource_group.bookings-app.name
  location            = data.azurerm_resource_group.bookings-app.location

  name = "frontend-appgw"
}

resource "azurerm_public_ip" "frontend-appgw" {
  name                = "frontend-appgw"
  resource_group_name = data.azurerm_resource_group.bookings-app.name
  location            = data.azurerm_resource_group.bookings-app.location
  zones               = [1, 2, 3]
  sku                 = "Standard"
  allocation_method   = "Static"
}

resource "azurerm_application_gateway" "frontend" {
  name                = "frontend-appgw"
  resource_group_name = data.azurerm_resource_group.bookings-app.name
  location            = data.azurerm_resource_group.bookings-app.location
  zones               = [1, 2, 3]
  enable_http2        = true

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [ azurerm_user_assigned_identity.frontend-appgw.id ]
  }

  autoscale_configuration {
      min_capacity = 1
      max_capacity = 3
  }

  gateway_ip_configuration {
    name      = "frontendConfig"
    subnet_id = azurerm_subnet.appgw.id
  }

  frontend_port {
    name = "frontendPort"
    port = 80
  }

  frontend_ip_configuration {
    name                          = "publicFrontendIp"
    public_ip_address_id          = azurerm_public_ip.frontend-appgw.id
  }

  frontend_ip_configuration {
    name                          = "privateFrontendIp"
    subnet_id                     = azurerm_subnet.appgw.id
    private_ip_address            = "10.254.2.10"
    private_ip_address_allocation = "Static"
  }

  http_listener {
    name                           = "frontendListener"
    frontend_ip_configuration_name = "privateFrontendIp"
    frontend_port_name             = "frontendPort"
    protocol                       = "Http"
  }

  backend_http_settings {
    name                                = "httpSettingDefault"
    cookie_based_affinity               = "Enabled"
    port                                = 80
    protocol                            = "Http"
    request_timeout                     = 180
  }

  backend_address_pool {
    name = "addressPoolDefault"
  }

  request_routing_rule {
    name                       = "apiGwRoutingRule"
    rule_type                  = "Basic"
    http_listener_name         = "frontendListener"
    backend_address_pool_name  = "addressPoolDefault"
    backend_http_settings_name = "httpSettingDefault"
    priority                   = 1
  }

  lifecycle {
    ignore_changes = all
  }

}