# ---------- VPC ----------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# ---------- Internet Gateway ----------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# ---------- Public Subnet -> Web-tier ----------
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  count             = length(var.public_subnet_cidrs)
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-web-${var.availability_zones[count.index]}"
  }
}

# ---------- Private Subnet -> App-tier ----------
resource "aws_subnet" "app" {
  vpc_id            = aws_vpc.main.id
  count             = length(var.app_subnet_cidrs)
  cidr_block        = var.app_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.project_name}-private-app-${var.availability_zones[count.index]}"
  }
}

# ---------- Private Subnet -> DB-tier ----------
resource "aws_subnet" "db" {
  count             = length(var.db_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.db_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "main-db-subnet-${var.availability_zones[count.index]}"
    Tier = "database"
  }
}

# ---------- NAT Gateway ----------
resource "aws_eip" "nat" {
  domain = "vpc"
  count  = length(var.public_subnet_cidrs)

  tags = {
    Name = "${var.project_name}-nat-eip-${var.availability_zones[count.index]}"
  }
}

resource "aws_nat_gateway" "nat" {
  count         = length(var.public_subnet_cidrs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.project_name}-nat-gateway-${var.availability_zones[count.index]}"
  }

  depends_on = [aws_internet_gateway.igw]

}

# ---------- Route Table: Public ----------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project_name}-public-route-table"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ---------- Route Table: Private ----------
resource "aws_route_table" "app" {
  vpc_id = aws_vpc.main.id
  count  = length(var.public_subnet_cidrs)

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }

  tags = {
    Name = "${var.project_name}-private-route-table"
  }
}

resource "aws_route_table_association" "app" {
  count          = length(aws_subnet.app)
  subnet_id      = aws_subnet.app[count.index].id
  route_table_id = aws_route_table.app[count.index].id
}

# ---------- Route Table: DB ----------
resource "aws_route_table" "db" {
  vpc_id = aws_vpc.main.id
  count  = length(var.db_subnet_cidrs)

  tags = {
    Name = "${var.project_name}-db-route-table-${var.availability_zones[count.index]}"
  }
}

resource "aws_route_table_association" "db" {
  count          = length(aws_subnet.db)
  subnet_id      = aws_subnet.db[count.index].id
  route_table_id = aws_route_table.db[count.index].id
}

# ---------- VPC Flow Logs ----------
resource "aws_flow_log" "vpc_flow_log" {
  vpc_id               = aws_vpc.main.id
  log_destination      = aws_s3_bucket.flow_logs.arn
  traffic_type         = "ALL"
  log_destination_type = "s3"

  tags = {
    Name = "${var.project_name}-vpc-flow-log"
  }
}