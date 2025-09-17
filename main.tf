module "appgw" {
  source        = "./modules/appgw"
  rg_location   = module.resourcegroups.rg_location
  rg_name       = module.resourcegroups.rg_name
  fe_app_id     = module.container_app.fe_app_id
  be_app_id     = module.container_app.be_app_id
  subnet_agw_id = module.subnets.subnet_agw_id
  vnet_name     = module.vnets.vnet_name
  be_app_fqdn   = module.container_app.be_app_fqdn
  fe_app_fqdn   = module.container_app.fe_app_fqdn
}
module "container_app" {
  source      = "./modules/containerapps"
  rg_location = module.resourcegroups.rg_location
  rg_name     = module.resourcegroups.rg_name
  vnet_name   = module.vnets.vnet_name
  fe_port     = 80
  be_port     = 3001
  db_password = module.db.db_password
  db_name     = module.db.db_name
  db_server   = module.db.db_server
  db_user     = module.db.db_user
}
module "db" {
  source                     = "./modules/db"
  rg_location                = module.resourcegroups.rg_location
  rg_name                    = module.resourcegroups.rg_name
  vnet_id                    = module.vnets.vnet_id
  private_endpoint_subnet_id = module.subnets.private_endpoint_subnet_id
  db_password                = var.db_password
}
module "monitoring" {
  source      = "./modules/monitoring"
  rg_location = module.resourcegroups.rg_location
  rg_name     = module.resourcegroups.rg_name
  fe_app_id   = module.container_app.fe_app_id
  be_app_id   = module.container_app.be_app_id
  db_id       = module.db.db_id
  vnet_name   = module.vnets.vnet_name
}
module "resourcegroups" {
  source = "./modules/resourcegroups"
}
module "subnets" {
  source      = "./modules/subnets"
  rg_location = module.resourcegroups.rg_location
  rg_name     = module.resourcegroups.rg_name
  vnet_name   = module.vnets.vnet_name
}
module "vnets" {
  source      = "./modules/vnets"
  rg_location = module.resourcegroups.rg_location
  rg_name     = module.resourcegroups.rg_name
}
