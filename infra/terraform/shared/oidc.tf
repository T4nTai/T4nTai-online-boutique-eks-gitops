# 1. Đăng ký GitHub Actions làm OIDC Identity Provider trên AWS.
# Nhờ OIDC, GitHub Actions xin token tạm thời (hết hạn sau vài phút) thay vì lưu AWS Access Key tĩnh.
resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]

  # Thumbprint chuẩn của GitHub Actions OIDC endpoint (đảm bảo tương thích mọi bản provider v5).
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd",
  ]
}

# 2. Trust Policy: CHỈ cho phép duy nhất repo GitHub của bạn (var.github_repo) được assume role này.
data "aws_iam_policy_document" "github_assume_role" {
  statement {
    sid     = "AllowGitHubActionsOIDC"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repo}:*"]
    }
  }
}

# 3. IAM Role mà GitHub Actions sẽ sử dụng trong pipeline CI.
resource "aws_iam_role" "github_actions_ecr" {
  name               = "${var.project_name}-github-actions-ecr-role"
  assume_role_policy = data.aws_iam_policy_document.github_assume_role.json
}

# 4. Permissions Policy theo nguyên tắc Least Privilege (quyền tối thiểu):
# Chỉ cho phép đăng nhập ECR và push/pull đúng 11 repositories của dự án.
data "aws_iam_policy_document" "ecr_push_pull" {
  statement {
    sid       = "ECRGetAuthToken"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid    = "ECRPushPullProjectRepos"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]
    resources = [for repo in aws_ecr_repository.services : repo.arn]
  }
}

resource "aws_iam_role_policy" "github_actions_ecr" {
  name   = "${var.project_name}-ecr-push-pull"
  role   = aws_iam_role.github_actions_ecr.id
  policy = data.aws_iam_policy_document.ecr_push_pull.json
}
