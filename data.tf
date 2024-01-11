data "aws_availability_zones" "azs" {
   state = "available" #op
 # all_availability_zones = true
}
# get from datasource default vpc
data "aws_vpc" "default" {
  default = true
}
#route table association
data "aws_route_table" "default" {
    vpc_id = data.aws_vpc.default.id
    filter {
        name = "association.main"
        values = ["true"]
    }
}