data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_vpc" "default" { # for peering in peering.tf 
  default = true
}


# # Data source to find the default route table associated with the specific VPC

# data "aws_route_table" "main" {
#   vpc_id = data.aws_vpc.example.id

#   filter {
#     name   = "association.main"
#     values = ["true"]
#   }
# }

# the above is syntax for below code 


data "aws_route_table" "main" { # for peering in peering.tf
  vpc_id = data.aws_vpc.default.id
  filter {
    name   = "association.main"
    values = ["true"]
  }
}