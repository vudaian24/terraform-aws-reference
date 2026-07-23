# TODO(implementation phase): wrap s3-bucket + cloudfront modules
#
# module "bucket" {
#   source  = "terraform-aws-modules/s3-bucket/aws"
#   version = "~> 5.0"
#
#   bucket = var.name
#
#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
#
#   versioning = { enabled = true }
#   tags       = var.tags
# }
#
# module "cdn" {
#   source  = "terraform-aws-modules/cloudfront/aws"
#   version = "~> 6.0"
#
#   aliases = var.aliases
#
#   origin_access_control = {
#     s3_oac = {
#       description      = "OAC for ${var.name}"
#       origin_type      = "s3"
#       signing_behavior = "always"
#       signing_protocol = "sigv4"
#     }
#   }
#
#   origin = {
#     s3 = {
#       domain_name                = module.bucket.s3_bucket_bucket_regional_domain_name
#       origin_access_control_key  = "s3_oac"
#     }
#   }
#
#   default_cache_behavior = {
#     target_origin_id       = "s3"
#     viewer_protocol_policy = "redirect-to-https"
#     allowed_methods        = ["GET", "HEAD", "OPTIONS"]
#     cached_methods         = ["GET", "HEAD"]
#     compress               = true
#   }
#
#   custom_error_response = [
#     { error_code = 403, response_code = 200, response_page_path = "/index.html" },
#     { error_code = 404, response_code = 200, response_page_path = "/index.html" },
#   ]
#
#   viewer_certificate = var.acm_certificate_arn == null ? {
#     cloudfront_default_certificate = true
#   } : {
#     acm_certificate_arn = var.acm_certificate_arn
#     ssl_support_method  = "sni-only"
#   }
#
#   price_class = var.price_class
#   tags        = var.tags
# }
