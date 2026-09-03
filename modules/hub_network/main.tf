variable "resource_group_name" { type = string }
variable "location"            { type = string }
variable "hub_vnet_name"       { type = string }
variable "hub_address_space"   { type = list(string) }

resource "azurerm_virtual_network" "hub" {
  name                = var.hub_vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.hub_address_space
}

resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [cidrsubnet(var.hub_address_space[0], 8, 1)] # E.g., 10.100.1.0/24
}

output "vnet_id" {
  value = azurerm_virtual_network.hub.id
}
output "vnet_name" {
  value = azurerm_virtual_network.hub.name
}