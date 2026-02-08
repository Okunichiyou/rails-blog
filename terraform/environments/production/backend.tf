terraform {
  backend "s3" {
    bucket  = "rails-blog-tfstate"
    key     = "production/terraform.tfstate"
    region  = "ap-northeast-1"
    encrypt = true
  }
}
