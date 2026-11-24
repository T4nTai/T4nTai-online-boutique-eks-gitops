variable "aws_region" {
  description = "AWS region triển khai hạ tầng"
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "Tên dự án dùng làm prefix đặt tên tài nguyên"
  type        = string
  default     = "online-boutique"
}

variable "github_repo" {
  description = "GitHub repository được phép assume IAM Role qua OIDC (định dạng owner/repo)"
  type        = string
  default     = "T4nTai/T4nTai-online-boutique-eks-gitops"
}

variable "services" {
  description = "Danh sách 11 microservices cần tạo Amazon ECR repository"
  type        = list(string)
  default = [
    "adservice",
    "cartservice",
    "checkoutservice",
    "currencyservice",
    "emailservice",
    "frontend",
    "loadgenerator",
    "paymentservice",
    "productcatalogservice",
    "recommendationservice",
    "shippingservice",
  ]
}

variable "ecr_max_image_count" {
  description = "Số lượng image tối đa giữ lại cho mỗi service để tiết kiệm chi phí lưu trữ ECR"
  type        = number
  default     = 5
}
