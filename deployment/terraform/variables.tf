variable "vpc_cidr" {
  description = "spring boot application vpc cidr"
  type        = string
  default     = "20.0.0.0/16"
}

variable "app_short" {
  description = "spring boot application short name"
  type        = string
  default     = "springboot-application"
}

variable "environment" {
  description = "spring boot application environment"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "tags for the vpc"
  type        = map(string)
}

variable "availability_zones" {
  description = "list of availability zones"
  type        = list(string)
  default = [
    "ap-south-1a",
    "ap-south-1b",
    "ap-south-1c"
  ]
}

variable "key_name" {
  type = string
}