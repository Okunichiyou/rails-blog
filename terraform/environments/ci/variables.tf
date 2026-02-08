variable "github_repository" {
  description = "GitHub repository in format 'owner/repo'"
  type        = string
  default     = "Okunichiyou/rails-blog"
}

variable "terraform_state_bucket" {
  description = "S3 bucket name for Terraform state"
  type        = string
  default     = "rails-blog-tfstate"
}
