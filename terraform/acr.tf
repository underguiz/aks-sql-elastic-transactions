resource "random_string" "acr" {
  length           = 6
  special          = false
  upper            = false
}

resource "azurerm_container_registry" "acr" {
  name                          = "mstdtcbookings${random_string.acr.result}"
  resource_group_name           = data.azurerm_resource_group.bookings-app.name 
  location                      = data.azurerm_resource_group.bookings-app.location
  sku                           = "Standard"
  public_network_access_enabled = true
  admin_enabled                 = true
}

resource "azurerm_role_assignment" "aks-acr" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_kubernetes_cluster.bookings-app.kubelet_identity.0.object_id
}