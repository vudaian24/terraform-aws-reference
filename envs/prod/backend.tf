# Partial backend configuration — real values (bucket name, region) come from
# `backend.hcl` (gitignored) at `terraform init -backend-config=backend.hcl`.
# See backend.hcl.example and ../../bootstrap/README.md.
terraform {
  backend "s3" {
    key          = "envs/prod/terraform.tfstate"
    use_lockfile = true
    encrypt      = true
  }
}
