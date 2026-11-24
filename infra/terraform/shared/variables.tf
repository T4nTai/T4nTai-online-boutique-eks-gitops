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

variable "github_oidc_sub" {
  description = "Chuỗi OIDC sub claim chuẩn của GitHub repo (bao gồm Owner ID và Repo ID bất biến để chống repo-resurrection)"
  type        = string
  default     = "repo:T4nTai@158046221/T4nTai-online-boutique-eks-gitops@1469623249:*"
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
