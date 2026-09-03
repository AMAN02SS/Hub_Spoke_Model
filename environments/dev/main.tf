resource "azurerm_resource_group" "network_rg" {
  name     = "rg-enterprise-network-prod"
  location = "eastus2"
}

# 1. Instantiate the Central Hub
module "central_hub" {
  source              = "../../modules/hub_network"
  resource_group_name = azurerm_resource_group.network_rg.name
  location            = azurerm_resource_group.network_rg.location
  hub_vnet_name       = "vnet-hub-prod-001"
  hub_address_space   = ["10.100.0.0/16"]
}

# 2. Instantiate Spoke A (e.g., HR Application)
module "spoke_hr_app" {
  source              = "../../modules/spoke_network"
  resource_group_name = azurerm_resource_group.network_rg.name
  location            = azurerm_resource_group.network_rg.location
  spoke_vnet_name     = "vnet-spoke-hrapp-prod"
  spoke_address_space = ["10.101.0.0/16"]
  
  # Dependency Injection from the Hub output
  hub_vnet_id         = module.central_hub.vnet_id
  hub_vnet_name       = module.central_hub.vnet_name
}

# 3. Instantiate Spoke B (e.g., Finance Application)
module "spoke_finance_app" {
  source              = "../../modules/spoke_network"
  resource_group_name = azurerm_resource_group.network_rg.name
  location            = azurerm_resource_group.network_rg.location
  spoke_vnet_name     = "vnet-spoke-finance-prod"
  spoke_address_space = ["10.102.0.0/16"]
  
  # Reuses the exact same Hub outputs
  hub_vnet_id         = module.central_hub.vnet_id
  hub_vnet_name       = module.central_hub.vnet_name
}