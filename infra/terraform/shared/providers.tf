terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.80"
    }
  }

  # Partial backend config: truyền thông số bucket qua file backend.hcl
  # để không hardcode tên S3 bucket cá nhân vào Git public.
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region

  # Tự động gắn tag cho mọi tài nguyên AWS do stack này tạo ra
  # (rất hữu ích khi theo dõi chi phí trên AWS Cost Explorer).
  default_tags {
    tags = {
      Project   = var.project_name
      Stack     = "shared"
      ManagedBy = "Terraform"
    }
  }
}
