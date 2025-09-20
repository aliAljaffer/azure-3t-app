output "agw_ips" {
  value = module.appgw.agw_ip
}

output "websites" {
  value = [module.appservice.fe_app_fqdn, module.appservice.be_app_fqdn]
}
