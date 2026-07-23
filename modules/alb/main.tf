# TODO(implementation phase): wrap terraform-aws-modules/alb/aws ~> 10.0
#
# module "alb" {
#   source  = "terraform-aws-modules/alb/aws"
#   version = "~> 10.0"
#
#   name    = var.name
#   vpc_id  = var.vpc_id
#   subnets = var.public_subnet_ids
#
#   security_group_ingress_rules = {
#     http = {
#       from_port   = 80
#       to_port     = 80
#       ip_protocol = "tcp"
#       cidr_ipv4   = "0.0.0.0/0"
#     }
#     https = {
#       from_port   = 443
#       to_port     = 443
#       ip_protocol = "tcp"
#       cidr_ipv4   = "0.0.0.0/0"
#     }
#   }
#   security_group_egress_rules = {
#     all = {
#       ip_protocol = "-1"
#       cidr_ipv4   = "0.0.0.0/0"
#     }
#   }
#
#   # Without a cert (no domain yet — var.certificate_arn null), port 80 must
#   # forward directly; redirecting to 443 with no https listener behind it
#   # would dead-end every request. Once a cert exists, 80 redirects and 443
#   # terminates TLS.
#   listeners = var.certificate_arn == null ? {
#     http = {
#       port     = 80
#       protocol = "HTTP"
#       forward  = { target_group_key = "app" }
#     }
#   } : {
#     http_redirect = {
#       port     = 80
#       protocol = "HTTP"
#       redirect = { port = "443", protocol = "HTTPS", status_code = "HTTP_301" }
#     }
#     https = {
#       port            = 443
#       protocol        = "HTTPS"
#       certificate_arn = var.certificate_arn
#       forward         = { target_group_key = "app" }
#     }
#   }
#
#   target_groups = {
#     app = {
#       protocol          = "HTTP"
#       port              = var.container_port
#       target_type       = "ip"
#       create_attachment = false
#
#       health_check = {
#         enabled  = true
#         path     = "/health"
#         port     = "traffic-port"
#         protocol = "HTTP"
#         matcher  = "200-299"
#       }
#     }
#   }
#
#   tags = var.tags
# }
