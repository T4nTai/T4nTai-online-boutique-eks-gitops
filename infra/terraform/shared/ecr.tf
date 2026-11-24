# Tạo tự động 11 ECR repositories bằng for_each thay vì lặp code 11 lần.
resource "aws_ecr_repository" "services" {
  for_each = toset(var.services)

  name                 = "${var.project_name}/${each.key}"
  image_tag_mutability = "MUTABLE"

  # Cho phép terraform destroy xóa luôn repo kể cả khi đang có image bên trong (tiện cho môi trường lab).
  force_delete = true

  # Tự động quét lỗ hổng CVE mỗi khi có image mới được push lên ECR.
  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}

# Lifecycle Policy: tự động dọn image untagged sau 1 ngày và chỉ giữ lại N image mới nhất
# để không bị phình dung lượng lưu trữ ECR.
resource "aws_ecr_lifecycle_policy" "services" {
  for_each = aws_ecr_repository.services

  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Xóa image không có tag sau 1 ngày"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 1
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Chỉ giữ lại ${var.ecr_max_image_count} image mới nhất"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = var.ecr_max_image_count
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
