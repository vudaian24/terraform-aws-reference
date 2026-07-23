module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 10.0"

  name    = var.name
  vpc_id  = var.vpc_id
  subnets = var.public_subnet_ids

  security_group_ingress_rules = {
    http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
    https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  # Without a cert (no domain yet — var.certificate_arn null), port 80 must
  # forward directly; redirecting to 443 with no https listener behind it
  # would dead-end every request. Once a cert exists, 80 redirects and 443
  # terminates TLS.
  #
  # Can't ternary between `{ http = {forward=...} }` and `{ http = {redirect=...},
  # https = {...} }` directly — Terraform rejects a conditional whose two
  # branches are object literals with different attribute keys ("Inconsistent
  # conditional result types"). Instead: one always-present "http" object
  # whose forward/redirect sub-attributes are null-or-object per branch (null
  # unifies fine against any single type), and a separately-null-able "https"
  # entry, then filter out whichever came out null before handing the map to
  # the module.
  listeners = {
    for k, v in {
      http = {
        port     = 80
        protocol = "HTTP"
        forward  = var.certificate_arn == null ? { target_group_key = "app" } : null
        redirect = var.certificate_arn == null ? null : { port = "443", protocol = "HTTPS", status_code = "HTTP_301" }
      }
      https = var.certificate_arn == null ? null : {
        port            = 443
        protocol        = "HTTPS"
        certificate_arn = var.certificate_arn
        forward         = { target_group_key = "app" }
      }
    } : k => v if v != null
  }

  target_groups = {
    app = {
      protocol          = "HTTP"
      port              = var.container_port
      target_type       = "ip"
      create_attachment = false

      health_check = {
        enabled  = true
        path     = "/health"
        port     = "traffic-port"
        protocol = "HTTP"
        matcher  = "200-299"
      }
    }
  }

  tags = var.tags
}
