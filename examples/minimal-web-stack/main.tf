# TODO(implementation phase, after modules/* and envs/dev are wired):
# mirror envs/dev's wiring here but with every module `source` pointed at the
# public registry directly, e.g.:
#
# module "vpc" {
#   source  = "terraform-aws-modules/vpc/aws"
#   version = "~> 6.0"
#   ...
# }
