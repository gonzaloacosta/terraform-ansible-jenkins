resource "aws_acm_certificate" "jenkins_lb_https" {
  provider          = aws.region_master
  domain_name       = join(".", ["jenkins", data.aws_route53_zone.dns.name])
  validation_method = "DNS"
  tags              = merge(local.tags, { Name = "${local.preffix}-jenkins-acm" })
}

resource "aws_acm_certificate_validation" "cert" {
  for_each                = aws_route53_record.cert_validation
  provider                = aws.region_master
  certificate_arn         = aws_acm_certificate.jenkins_lb_https.arn
  validation_record_fqdns = [aws_route53_record.cert_validation[each.key].fqdn]
}

