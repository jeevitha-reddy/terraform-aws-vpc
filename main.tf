resource "aws_vpc" "main" { # get sysntax from terraform
  cidr_block       = var.vpc_cidr 
  enable_dns_hostnames = var.enable_dns_hostnames #Whether or not the VPC has DNS hostname support
  tags = merge(
    var.common_tags,
    var.vpc_tags,
    {
        Name = local.name #declared in local.tf you can reference the local multiple times
    }
    )
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

 tags = merge(
    var.common_tags,
    var.igw_tags,
    {
        Name = local.name # declared in local.tf
    }
    )
}
# Create public subnets
resource "aws_subnet" "public" { 
  count = length(var.public_subnets_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnets_cidr[count.index]
  availability_zone = local.az_names[count.index]
  tags = merge(
    var.common_tags,
    var.public_subnets_tags,
    {
        Name =" ${local.name}-public-${local.az_names[count.index]}" #declared in local.tf you can reference the local multiple times
    }
    )
}

# create private subnets
resource "aws_subnet" "private" { 
  count = length(var.private_subnets_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnets_cidr[count.index]
  availability_zone = local.az_names[count.index]
  tags = merge(
    var.common_tags,
    var.private_subnets_tags,
    {
        Name =" ${local.name}-private-${local.az_names[count.index]}" #declared in local.tf you can reference the local multiple times
    }
    )
}

# create database subnets
resource "aws_subnet" "database" { # create subnet
  count = length(var.database_subnets_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnets_cidr[count.index]
  availability_zone = local.az_names[count.index]
  tags = merge(
    var.common_tags,
    var.database_subnets_tags,
    {
        Name =" ${local.name}-database-${local.az_names[count.index]}" #declared in local.tf you can reference the local multiple times
    }
    )
}

resource "aws_db_subnet_group" "default" {
  name       = "${local.name}"
  subnet_ids = aws_subnet.database[*].id

  tags = {
    Name = "${local.name}"
  }
}

# elastic ip creation

resource "aws_eip" "eip" {
  domain           = "vpc"
}
# nat gateway 
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public[0].id # nat gateway in public 

  tags = merge(
    var.common_tags,
    var.nat_gateway_tags,
    {
        Name = "${local.name}"
    }
  )

 # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}

# route table public 

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.public_route_table_tags,
    {
        Name = "${local.name}-public"
    }
  )
}

# route table for private
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.private_route_table_tags,
    {
        Name = "${local.name}-private"
    }
  )
}

# route table for database
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.database_route_table_tags,
    {
        Name = "${local.name}-database"
    }
  )
}
# route table create
resource "aws_route" "public_route" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw.id # provide internet gateway id 
}

resource "aws_route" "private_route" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main.id # provide nat gateway id 
}
#route table association
resource "aws_route" "database_route" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main.id  # nat gateway id 
}
resource "aws_route_table_association" "public" {
  count = length(var.public_subnets_cidr) #we have two subnet so loop it 
  subnet_id = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnets_cidr)
  subnet_id = element(aws_subnet.private[*].id, count.index)
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {
  count = length(var.database_subnets_cidr)
  subnet_id = element(aws_subnet.database[*].id, count.index)
  route_table_id = aws_route_table.database.id
}