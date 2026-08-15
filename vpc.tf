# ---------- VPC ----------

resource "aws_vpc" "main" {
cidr_block = "12.5.0.0/16"
enable_dns_support = true
enable_dns_hostnames = true

tags = {
Name = "main-vpc"
}

#------ Internet Gateway ------

resource "aws_internet_gateway" "main" {
vpc_id = aws_vpc.main.id

tags = {
Name = "main-igw"
}
}

#------ Public Subnet -> Web-tier ------

resource "aws_subnet" "public" {
vpc_id = aws_vpc.main.id
cidr_block = "12.5.1.0/24"
map_public_ip_on_launch = true
availability_zone = "ap-south-1a"

tags = {
Name = "main-public-subnet"
}
}

#----- Private Subnet -> App-tier ------

resource "aws_subnet" "private" {
vpc_id = aws_vpc.main.id
cidr_block = "12.5.2.0/24"
availability_zone = "ap-south-1a"

tags = {
Name = "main-private-subnet"
}
}

#----- Private Subnet -> DB-tier ------
resource "aws_subnet" "db" {
vpc_id = aws_vpc.main.id
cidr_block = "12.5.3.0/24"
availability_zone = "ap-south-1a"

tags = {
Name = "main-db-subnet"
}
}

#----- NAT Gateway ------

resource "aws_eip" "nat" {
domain = "vpc"

tags = {
Name = "main-nat-eip"
}
}

resource "aws_nat_gateway" "main" {
allocation_id = aws_eip.nat.id
subnet_id = aws_subnet.public.id

tags = {
Name = "main-nat-gateway"   
}
}

#----- Route Table Public ------

resource "aws_route_table" "public" {
vpc_id = aws_vpc.main.id

route {
cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.main.id
}

tags = {
Name = "main-public-route-table"
}
}

resource "aws_route_table_association" "public" {
subnet_id = aws_subnet.public.id
route_table_id = aws_route_table.public.id
}

#----- Route Table Private ------

resource "aws_route_table" "private" {
vpc_id = aws_vpc.main.id

route {
cidr_block = "0.0.0.0/0"
nat_gateway_id = aws_nat_gateway.main.id
}
}

resource "aws_route_table_association" "private" {
subnet_id = aws_subnet.private.id
route_table_id = aws_route_table.private.id
}
}

#----- Route Table DB ------

resource "aws_route_table" "db" {
vpc_id = aws_vpc.main.id

tags = {
Name = "main-db-route-table"
}
}

resource "aws_route_table_association" "db" {
subnet_id = aws_subnet.db.id
route_table_id = aws_route_table.db.id
}

#----- AWS VPC Flow Logs ------

resource "aws_flow_log" "vpc_flow_log" {
vpc_id = aws_vpc.main.id
log_destination = aws_s3_bucket.flow_logs.arn
traffic_type = "ALL"
log_destination_type = "aws_s3_bucket"

tags = {
Name = "main-vpc-flow-log"
}
}
