terraform {
  backend "s3" {
    bucket = "gonza-development-terraform-backend"
    region = "eu-north-1"
  }
}
