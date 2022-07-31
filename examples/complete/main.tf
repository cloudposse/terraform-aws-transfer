provider "aws" {
  region = var.region
}

provider "awsutils" {
  region = var.region
}

module "s3_bucket" {
  source  = "cloudposse/s3-bucket/aws"
  version = "2.0.3"

  for_each = toset(["home", "extra"])

  acl                = "private"
  enabled            = true
  user_enabled       = false
  versioning_enabled = false
  force_destroy      = true

  attributes = [each.value]

  context = module.this.context
}

module "sftp" {
  source = "../.."

  sftp_users = var.sftp_users

  s3_bucket_name = module.s3_bucket["home"].bucket_id

  home_directory_mappings = {
    "extra" = {
      entry  = "/"
      target = "/${module.s3_bucket["extra"].bucket_id}/$${Transfer:UserName}"
    }
  }

  context = module.this.context
}
