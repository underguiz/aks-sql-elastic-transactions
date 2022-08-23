provider "azurerm" {
  features {}
}

provider "kubernetes" {
    host = "${azurerm_kubernetes_cluster.bookings-app.kube_config.0.host}"

    client_certificate     = "${base64decode(azurerm_kubernetes_cluster.bookings-app.kube_config.0.client_certificate)}"
    client_key             = "${base64decode(azurerm_kubernetes_cluster.bookings-app.kube_config.0.client_key)}"
    cluster_ca_certificate = "${base64decode(azurerm_kubernetes_cluster.bookings-app.kube_config.0.cluster_ca_certificate)}"
}

variable "bookings-app-rg" {
  type    = string
  default = "bookings-app"
}

output "acr_name" {
  value       = azurerm_container_registry.acr.name
  description = "ACR Name"
}

output "sql_server_fqdn" {
  value       = azurerm_mssql_server.bookings-db.fully_qualified_domain_name
  description = "SQL Server FQDN"
}

output "sql_server_password" {
  value       = nonsensitive(azurerm_mssql_server.bookings-db.administrator_login_password)
  description = "SQL Server Password"
}

data "azurerm_resource_group" "bookings-app" {
    name = var.bookings-app-rg
}
