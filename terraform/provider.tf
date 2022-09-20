provider "aws" {
  region = "ap-northeast-1"

  default_tags {
    tags = {
      managed_by = var.app_name
    }
  }
}
