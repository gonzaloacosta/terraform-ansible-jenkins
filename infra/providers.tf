provider "aws" {
  alias   = "region_master"
  region  = var.jenkins_master_region
  profile = "${local.preffix}-${var.environment == "development" ? "development" : "production"}"
}

provider "aws" {
  alias   = "region_slaves"
  region  = var.jenkins_slaves_region
  profile = "${local.preffix}-${var.environment == "development" ? "development" : "production"}"
}

# Uncomment in case to use gonza.cc domain
#provider "aws" {
#   alias   = "production"
#   region  = var.production_region
#   profile = var.production_profile
# }
