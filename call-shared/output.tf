output "svc" {
    value = module.eks-addons.traefik_service_info
}

output "dns_name" {
    value = module.eks-addons.traefik_service_load_balancer_hostname
  
}
output "zone_id" {
    value = module.eks-addons.classic_lb_zone_id
  
}