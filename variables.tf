variable "vpc_cidr" {
    type = string
    default = "10.0.0.0/16" # user can override

}

variable "enable_dns_hostnames" {
  type = bool
  default = true
}

variable "common_tags" { #commonly we can use tags this we ca orerider
    type = map
    default = {} #optional
           
}

variable "vpc_tags" {
    type = map
    default = {}

}
variable "project_name" {
  type = string # mandatory
}

variable "environment" {
  type = string # mandatory
}

variable "igw_tags" {
    type = map
    default = {}
}
# public variable delaration

 variable "public_subnets_cidr" {
  type = list 
  validation {
    condition = length(var.public_subnets_cidr) ==2
    error_message = "please give two public valid cidr"
  } 
 }
 variable "public_subnets_tags" {
  default = {}
 }

# private variable delaration

 variable "private_subnets_cidr" {
  type = list 
  validation {
    condition = length(var.private_subnets_cidr) ==2
    error_message = "please give two private valid cidr"
  } 
 }
 variable "private_subnets_tags" {
  default = {}
 }
# database variable delaration

  variable "database_subnets_cidr" {
  type = list 
  validation {
    condition = length(var.database_subnets_cidr) ==2
    error_message = "please give two database valid cidr"
  } 
 }
 variable "database_subnets_tags" {
  default = {}
 }
 variable "nat_gateway_tags" {
  default = {}
}

variable "public_route_table_tags" {
  default = {}
}

variable "private_route_table_tags" {
  default = {}  
}
variable "database_route_table_tags" {
  default = {} 
}



variable "is_peering_required" {
  type = bool
  default = false
}

variable "acceptor_vpc_id" {
  type = string
  default = ""
}

variable "vpc_peering_tags" {
  default = {}
}