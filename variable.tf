variable "vpc_cidr" {
  type = string
  # default = "" ikkada idhi pettakapothe adi mandatory avuthundhi
  description = "Please provide the vpc CIDR RANGE"
 }

 variable "project_name" {
   type = string

 }

 variable "environment" {
   type = string

 }

 # above both like project name and environment use enti ante common tags anevi konni
 # manaki understand purpose ki create chesukovahu....

#VPC
 variable "vpc_tags" {
    type = map
    default = {}
}

# manam local.tf lo tags pettam adhi manaki developer understad ki
# so user ki kuda valla istum vachhinatu chesukovali ante like that above vpc_tags
# so there empty ani pedithe adi optional so valla istum 

#IGW
variable "igw_tags" {
    type = map
    default = {}
}

#SUBNETS

variable "public_subnet_cidrs" {
    type = list
}

variable "public_subnet_tags" {
    type = map
    default = {}
}


variable "private_subnet_cidrs" {
    type = list
}

variable "private_subnet_tags" {
    type = map
    default = {}
}

variable "database_subnet_cidrs" {
    type = list
}

variable "database_subnet_tags" {
    type = map
    default = {}
}
#############################

# ROUTE_TABLE

variable "public_route_table_tags" {
    type = map
    default = {}
}

variable "private_route_table_tags" {
    type = map
    default = {}
}

variable "database_route_table_tags" {
    type = map
    default = {}
}


variable "eip_tags" {
    type = map
    default = {}
}

variable "nat_gateway_tags" {
    type = map
    default = {}
}

# variable "is_peering_required" {
#     type = bool
#     default = true
# }