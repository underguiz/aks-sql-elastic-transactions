resource "azurerm_kubernetes_cluster" "bookings-app" {
  name                = "bookings-app"
  dns_prefix          = "bookings-app"
  resource_group_name = data.azurerm_resource_group.bookings-app.name
  location            = data.azurerm_resource_group.bookings-app.location

  role_based_access_control_enabled = true

  default_node_pool {
    name                = "system"
    vm_size             = "Standard_D2as_v4"
    enable_auto_scaling = false
    node_count          = 2
    vnet_subnet_id      = azurerm_subnet.app.id
    zones               = [1, 2, 3]
  }

  network_profile {
    network_plugin     = "azure"
    service_cidr       = "172.29.100.0/24"
    dns_service_ip     = "172.29.100.10"
    docker_bridge_cidr = "172.29.101.0/24"  
  }

  ingress_application_gateway {
    gateway_id = azurerm_application_gateway.frontend.id
  }

  identity {
    type = "SystemAssigned"
  }

}

resource "azurerm_kubernetes_cluster_node_pool" "windows" {
  name                  = "win"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.bookings-app.id
  vm_size               = "Standard_D4as_v4"
  vnet_subnet_id        = azurerm_subnet.app.id
  node_count            = 3
  zones                 = [1, 2, 3]
  os_type               = "Windows"
}

resource "azurerm_role_assignment" "aks-subnet" {
  scope                = azurerm_virtual_network.bookings-app.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.bookings-app.identity.0.principal_id
}

resource "azurerm_role_assignment" "app-gw" {
  scope                = azurerm_application_gateway.frontend.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_kubernetes_cluster.bookings-app.ingress_application_gateway.0.ingress_application_gateway_identity.0.object_id
}

resource "azurerm_role_assignment" "app-gw-rg" {
  scope                = data.azurerm_resource_group.bookings-app.id
  role_definition_name = "Reader"
  principal_id         = azurerm_kubernetes_cluster.bookings-app.ingress_application_gateway.0.ingress_application_gateway_identity.0.object_id
}

resource "azurerm_role_assignment" "app-gw-network" {
  scope                = azurerm_application_gateway.frontend.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.bookings-app.ingress_application_gateway.0.ingress_application_gateway_identity.0.object_id
}

resource "azurerm_role_assignment" "app-gw-principal" {
  scope                = azurerm_application_gateway.frontend.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_kubernetes_cluster.bookings-app.identity.0.principal_id
}

resource "azurerm_role_assignment" "app-gw-rg-principal" {
  scope                = data.azurerm_resource_group.bookings-app.id
  role_definition_name = "Reader"
  principal_id         = azurerm_kubernetes_cluster.bookings-app.identity.0.principal_id
}

resource "azurerm_role_assignment" "app-gw-identity" {
  scope                = azurerm_user_assigned_identity.frontend-appgw.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_kubernetes_cluster.bookings-app.ingress_application_gateway.0.ingress_application_gateway_identity.0.object_id
}