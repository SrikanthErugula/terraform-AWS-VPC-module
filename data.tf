data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_vpc" "default" { # for peering in peering.tf 
  default = true
}

data "aws_route_table" "main" { # for peering in peering.tf
  vpc_id = data.aws_vpc.default.id
  filter {
    name   = "association.main"
    values = ["true"]
  }
}