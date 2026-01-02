#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
#for syntax

resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
   enable_dns_hostnames = true # see below for deatiled
   # the above are required values for vpc creation
#   tags = {
#     Name = "main"
#   }

tags =  merge(
    local.common_tags, # MAP 1..# see below for deatils
    var.vpc_tags, # map 1 
    # before {} enni vunna adhi map 1 kidha ki vastai
    {
        Name = local.common_name_suffix #  map 2
    }
)
}

# here "main" or "this" ala vunttadhi usually bcz here adi okkate create chestunam

# cidr_block       = "10.0.0.0/16" ila key and value vunte adi hardcode

# {local.common_tags, # idi user kosam picchi names pedithe rules follow avakunda 
# valla name manam set chesina name tho replace avuthundhi map 2}

# {enable_dns_hostnames ---receive a public DNS hostname and whether private DNS
#hostnames can be resolved. }

# IGW
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway.html
# syntax
resource "aws_internet_gateway" "demo-main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags, # MAP 1..# see below for deatils
    var.igw_tags, # map 1 
    # before {} enni vunna adhi map 1 kidha ki vastai
    {
        Name = local.common_name_suffix #  map 2
    }
)

# so here user must be provided values emi levuu then u can run terraform cmds it willbe
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
# for syntax

# Public Subnets

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidrs[count.index] # see in notes
  availability_zone = local.az_names[count.index]
  map_public_ip_on_launch = true # see in notes

  tags = merge(
    var.public_subnet_tags,
    local.common_tags,
    {
        Name = "${local.common_name_suffix}-public-${local.az_names[count.index]}" # roboshop-dev-public-us-east-1a
    }
  )
  # {so here user must be providing values are public subnet cidrs
  # dhani kosam module lo test lo kuda define cheyali like varialble.tf lo and
  # main.tf lo declare cheyali }
}

# Pvivate Subnets

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidrs[count.index] # see in notes
  availability_zone = local.az_names[count.index]
  #map_public_ip_on_launch = true # remove chete public access radhu 

  tags = merge(
    var.private_subnet_tags,
    local.common_tags,
    {
        Name = "${local.common_name_suffix}-private-${local.az_names[count.index]}" # roboshop-dev-private-us-east-1a
    }
  )

}

# DATA BASE

resource "aws_subnet" "database" {
  count = length(var.database_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnet_cidrs[count.index] # see in notes
  availability_zone = local.az_names[count.index]
  #map_public_ip_on_launch = true # remove chete public access radhu 

  tags = merge(
    var.database_subnet_tags,
    local.common_tags,
    {
        Name = "${local.common_name_suffix}-database-${local.az_names[count.index]}" # roboshop-dev-database-us-east-1a
    }
  )

}

# Public Route Table

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.public_route_table_tags,
    local.common_tags,
    {
        Name = "${local.common_name_suffix}-public"
    }
  )
}


 #Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.private_route_table_tags,
    local.common_tags,
    {
        Name = "${local.common_name_suffix}-private"
    }
  )
}


# Database Route Table
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.database_route_table_tags,
    local.common_tags,
    {
        Name = "${local.common_name_suffix}-database"
    }
  )
}

# Public Route
resource "aws_route" "public" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.demo-main.id
}


# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip
# Syntax 

# Elastic IP
resource "aws_eip" "nat" { 
  domain   = "vpc"

  tags = merge(
    var.eip_tags,
    local.common_tags,
    {
        Name = "${local.common_name_suffix}-nat"
    }
  )
}

# NAT gateway
resource "aws_nat_gateway" "nat" { 
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id # see in notes

  tags = merge(
    var.nat_gateway_tags,
    local.common_tags,
    {
        Name = "${local.common_name_suffix}"
    }
  )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.demo-main] # see in notes
}

# NAT anedhi public lo vundali pvt vachi pub ni adigithe adhi velli tisukoni vastundhi



# Private egress route through NAT

resource "aws_route" "private" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}

# Database egress route through NAT
resource "aws_route" "database" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association


#SUBNET_ASSOCIATIONS

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs) # two times lopp cheyali so we use this
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {
  count = length(var.database_subnet_cidrs)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}