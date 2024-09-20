output "eks" {
  value = module.eks
}

output "karpenter" {
  value = module.karpenter
}

output "eks_cluster" {
  value = module.eks.cluster_name
}
output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}
