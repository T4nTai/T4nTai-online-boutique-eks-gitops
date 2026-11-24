data "aws_caller_identity" "current" {}

output "aws_account_id" {
  description = "AWS Account ID hiện tại"
  value       = data.aws_caller_identity.current.account_id
}

output "github_actions_role_arn" {
  description = "ARN của IAM Role để dán vào GitHub Actions (Lab 3)"
  value       = aws_iam_role.github_actions_ecr.arn
}

output "ecr_repository_urls" {
  description = "Danh sách URL của 11 Amazon ECR repositories"
  value       = { for name, repo in aws_ecr_repository.services : name => repo.repository_url }
}
