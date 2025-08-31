variable "cidr_block" {
  description = "value of the cidr block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "AZs in this region to use"
  default     = ["ca-central-1a", "ca-central-1b"]
  type        = list(string)
}

variable "subnet_cidrs_public" {
  description = "Subnet CIDRs for public subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  type        = list(string)
}

variable "subnet_cidrs_private" {
  description = "Subnet CIDRs for public subnets"
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
  type        = list(string)
}

variable "username" {
  description = "value of the username"
  type        = string
}
