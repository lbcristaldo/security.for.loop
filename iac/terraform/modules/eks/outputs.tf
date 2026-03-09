output "cluster_id" {
  value = aws_eks_cluster.main.id
}

output "cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "cluster_security_group_id" {
  value = aws_security_group.eks_cluster.id
}

output "kubeconfig_certificate_authority_data" {
  value = aws_eks_cluster.main.certificate_authority[0].data
}

output "cluster_arn" {
  value = aws_eks_cluster.main.arn
}
