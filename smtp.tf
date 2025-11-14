#
resource "aws_iam_user" "smtp_user" {
  name = "${var.project}-smtp-user-${var.environment}"
}
#
resource "aws_iam_policy" "smtp_send_only" {
  name = "${var.project}-smtp-send-${var.environment}"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ses:SendRawEmail",
          "ses:SendEmail"
        ],
        Resource = ["*"]
        Condition = {
          IpAddress = {
            "aws:SourceIp" = var.cluster_ip
          }
        }
      }
    ]
  })
}
#
resource "aws_iam_user_policy_attachment" "smtp_user_custom" {
  user       = aws_iam_user.smtp_user.name
  policy_arn = aws_iam_policy.smtp_send_only.arn
}
#
resource "aws_iam_access_key" "smtp_user" {
  user = aws_iam_user.smtp_user.name
}
#
resource "aws_secretsmanager_secret" "smtp_credentials" {
  name = "smtp-credentials-${var.environment}"
  #
}
#
resource "null_resource" "decoder" {
  #
  triggers = {
    input_key    = aws_iam_access_key.smtp_user.secret
    input_region = var.region
    always_run   = "${timestamp()}"
  }
  #
  provisioner "local-exec" {
    command = "python3 ./scritps/decoder.py ${self.triggers.input_key} ${self.triggers.input_region} > ${path.module}/tmp/decoded_output.txt"
  }
  #
  depends_on = [aws_iam_access_key.smtp_user]
}
#
data "local_file" "pass" {
  filename = "${path.module}/tmp/decoded_output.txt"
  #
  depends_on = [null_resource.decoder]
}
#
resource "aws_secretsmanager_secret_version" "smtp_credentials" {
  secret_id = aws_secretsmanager_secret.smtp_credentials.id
  secret_string = jsonencode({
    AWS_ACCESS_KEY_ID     = aws_iam_access_key.smtp_user.id
    AWS_SECRET_ACCESS_KEY = aws_iam_access_key.smtp_user.secret
    smtp_username         = aws_iam_access_key.smtp_user.id
    smtp_password         = data.local_file.pass.content
    smtp_server           = var.smtp
    smtp_port             = 587
    region                = var.region
  })
  #
  depends_on = [
    null_resource.decoder,
    data.local_file.pass
  ]
}
#