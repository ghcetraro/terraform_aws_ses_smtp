#
resource "aws_ses_domain_identity" "main" {
  domain = var.domain
}
#
resource "aws_ses_domain_dkim" "main" {
  domain = aws_ses_domain_identity.main.domain
}
#
resource "aws_ses_domain_mail_from" "main" {
  domain           = aws_ses_domain_identity.main.domain
  mail_from_domain = "mail.${aws_ses_domain_identity.main.domain}"
}
#
data "aws_route53_zone" "zone" {
  name         = var.domain
  private_zone = false
}
#
resource "aws_route53_record" "ses_verification" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "_amazonses.${var.domain}"
  type    = "TXT"
  ttl     = 60
  records = [aws_ses_domain_identity.main.verification_token]
}
#
resource "aws_route53_record" "ses_dkim" {
  count   = 3
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "${element(aws_ses_domain_dkim.main.dkim_tokens, count.index)}._domainkey.${aws_ses_domain_identity.main.domain}"
  type    = "CNAME"
  ttl     = 60
  records = ["${element(aws_ses_domain_dkim.main.dkim_tokens, count.index)}.dkim.amazonses.com"]
}
#
resource "aws_route53_record" "ses_mail_from_mx" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "mail.${aws_ses_domain_identity.main.domain}"
  type    = "MX"
  ttl     = 60
  records = ["10 feedback-smtp.${var.region}.amazonses.com"]
}
#
resource "aws_route53_record" "ses_mail_from_spf" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "mail.${aws_ses_domain_identity.main.domain}"
  type    = "TXT"
  ttl     = 60
  records = ["v=spf1 include:amazonses.com ~all"]
}
#
resource "aws_route53_record" "ses_dmarc" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "_dmarc.${aws_ses_domain_identity.main.domain}"
  type    = "TXT"
  ttl     = 60
  records = ["v=DMARC1; p=none;"]
}
#