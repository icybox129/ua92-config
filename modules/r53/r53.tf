data "aws_route53_zone" "primary" {
  zone_id = "Z05213995IQENL3CFKUC"
}

resource "aws_route53_record" "wp" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "wp.icybox.co.uk"
  type    = "A"
  ttl     = "60"
  records = [var.public_ip]

}