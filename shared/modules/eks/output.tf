output "eks" {
  value = module.eks
}

output "karpenter" {
  value = module.karpenter
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "eks_cluster" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data 
}
