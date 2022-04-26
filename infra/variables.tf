variable "jenkins_slaves_region" {
  default     = "eu-central-1"
  type        = string
  description = "Jenkins slaves region"
}

variable "jenkins_master_region" {
  default     = "eu-central-1"
  type        = string
  description = "Jenkins master region"
}

variable "jenkins_master_instance_type" {
  default     = "t3.medium"
  type        = string
  description = "Jenkins master instance type"
}

variable "jenkins_slaves_instance_type" {
  default     = "t3.small"
  type        = string
  description = "Jenkins slaves instance type"
}

variable "environment" {
  default     = "development"
  type        = string
  description = "Gonza Environment"
}

variable "jenkins_port" {
  default     = 8080
  type        = number
  description = "Internal Jenkins port"
}

variable "gonza_office_ips" {
  description = "From public ip office permmited"
  default = [
    "190.19.144.151/32"
  ]
}

variable "jenkins_pub_key" {
  default     = "~/.ssh/id_rsa.pub"
  type        = string
  description = "Public key pair to user to connect to jenkins slave"
}

variable "jenkins_private_key" {
  default     = "~/.ssh/id_rsa"
  type        = string
  description = "Private key pair to user to connect to jenkins slave"
}

variable "jenkins_slaves_number" {
  default     = 1
  type        = number
  description = "Amount of jenkins slaves"
}

# For test perspective we use development.tak-api.com profile in route53
# defined in buidl38-development profile
variable "dns_name" {
  default     = "devops.gonza.cc"
  type        = string
  description = "Jenkins domain name"
}

# Only used in case to add new dns entry to gonza.cloud defined in
# production profile
#
#variable "domain_name" {
#  default     = "gonza.cc"
#  type        = string
#  description = "Jenkins domain name"
#}
#
#variable "production_profile" {
#  default = "gonza-production"
#  type = string
#  description = "gonza production profile"
#}
#
#variable "development_profile" {
#  default = "gonza-development"
#  type = string
#  description = "gonza development profile"
#}
