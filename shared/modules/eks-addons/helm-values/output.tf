# Output the service details, such as the load balancer IP
output "traefik_service_info" {
  value = data.kubernetes_service.traefik_service
}


# Output the load balancer hostname
output "traefik_service_load_balancer_hostname" {
  value = data.kubernetes_service.traefik_service.status[0].load_balancer[0].ingress[0].hostname
}


output "classic_lb_zone_id" {
  value = data.aws_elb.my_classic_lb.zone_id
}