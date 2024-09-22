output "sola_aws_integration_role_name" {
  value = aws_iam_role.sola_access_role.name
}

output "sola_aws_integration_role_arn" {
  value = aws_iam_role.sola_access_role.arn
}
