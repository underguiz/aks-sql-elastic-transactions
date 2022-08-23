resource "azurerm_virtual_network" "bookings-app" {
  name                = "bookings-app"
  resource_group_name = data.azurerm_resource_group.bookings-app.name 
  location            = data.azurerm_resource_group.bookings-app.location
  address_space       = ["10.254.0.0/16"]
}

resource "azurerm_subnet" "app" {
  name                 = "app"
  resource_group_name  = data.azurerm_resource_group.bookings-app.name 
  virtual_network_name = azurerm_virtual_network.bookings-app.name
  address_prefixes     = ["10.254.0.0/24"]
}

resource "azurerm_subnet" "db" {
  name                 = "db"
  resource_group_name  = data.azurerm_resource_group.bookings-app.name 
  virtual_network_name = azurerm_virtual_network.bookings-app.name
  address_prefixes     = ["10.254.1.0/24"]
}

resource "azurerm_subnet" "appgw" {
  name                 = "appgw"
  resource_group_name  = data.azurerm_resource_group.bookings-app.name 
  virtual_network_name = azurerm_virtual_network.bookings-app.name
  address_prefixes     = ["10.254.2.0/24"]
}