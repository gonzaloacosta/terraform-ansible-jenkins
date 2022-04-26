locals {

  preffix = "gonza"

  profile = "${loca.preffix}-${var.environment}"

  tags = {
    Environment = var.environment,
    Team        = "Gonza DevOps",
    Component   = "Jenkins"
  }

}
