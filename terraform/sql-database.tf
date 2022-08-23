resource "random_string" "bookings-db" {
  length           = 6
  special          = false
  upper            = false
}

resource "random_string" "bookings-db-password" {
  length           = 16
  special          = true
  upper            = true
  override_special = "!#$%*()-_=+[]{}:?"
}

resource "azurerm_mssql_server" "bookings-db" {
  name                          = "bookings-db-${random_string.bookings-db.result}"
  resource_group_name           = data.azurerm_resource_group.bookings-app.name
  location                      = data.azurerm_resource_group.bookings-app.location
  version                       = "12.0"
  administrator_login           = "bookingsapp"
  administrator_login_password  = "${random_string.bookings-db-password.result}"
  public_network_access_enabled = false
}

resource "azurerm_mssql_database" "flight" {
  name           = "Flight"
  server_id      = azurerm_mssql_server.bookings-db.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb    = 4
  sku_name       = "GP_S_Gen5_2"
  min_capacity   = "0.5"
  zone_redundant = true
  
  auto_pause_delay_in_minutes = "60"
}

resource "azurerm_mssql_database" "hotel" {
  name           = "Hotel"
  server_id      = azurerm_mssql_server.bookings-db.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb    = 4
  sku_name       = "GP_S_Gen5_2"
  min_capacity   = "0.5"
  zone_redundant = true
  
  auto_pause_delay_in_minutes = "60"
}

resource "azurerm_private_endpoint" "bookings-db" {
  name                = "bookings-db"
  resource_group_name = data.azurerm_resource_group.bookings-app.name
  location            = data.azurerm_resource_group.bookings-app.location
  subnet_id           = azurerm_subnet.db.id

  private_service_connection {
    name                           = "sqldb-private-link"
    private_connection_resource_id = azurerm_mssql_server.bookings-db.id
    is_manual_connection           = false
    subresource_names              = [ "sqlServer" ]
  }

  private_dns_zone_group {
      name                 = "sqlserver"
      private_dns_zone_ids = [ azurerm_private_dns_zone.bookings-db.id ]
  }
}

resource "azurerm_private_dns_zone" "bookings-db" {
  name                = "privatelink.database.windows.net"
  resource_group_name = data.azurerm_resource_group.bookings-app.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "bookings-db" {
  name                  = "privatelink.database.windows.net"
  private_dns_zone_name = azurerm_private_dns_zone.bookings-db.name
  virtual_network_id    = azurerm_virtual_network.bookings-app.id
  resource_group_name   = data.azurerm_resource_group.bookings-app.name
}

resource "kubernetes_secret" "connection-strings-config" {
  metadata {
    name = "connection-strings-config"
  }

  data = {
    "connectionStrings.config" = templatefile("config/connectionStrings.config.tpl", { database_fqdn = "${azurerm_mssql_server.bookings-db.fully_qualified_domain_name}", database_user = "${azurerm_mssql_server.bookings-db.administrator_login}", database_password = "${azurerm_mssql_server.bookings-db.administrator_login_password}" })
  }

}