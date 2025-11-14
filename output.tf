#
output "aws_secretsmanager_secret" {
  value = aws_secretsmanager_secret.smtp_credentials.id
}
#