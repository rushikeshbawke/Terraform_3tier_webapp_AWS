#----- Security Group ------

resource "aws_security_group" "main" {
name = "main-security-group"
vpc_id = aws_vpc.main.id

egress {
from_port = 0
to_port = 0
protocol = "-1"
description = "Allow all outbound traffic"
cidr_blocks = ["0.0.0.0/0"]
}

ingress {
from_port = 22
to_port = 22
protocol = "tcp"
description = "Allow SSH access"
cidr_blocks = ["0.0.0.0/0"]
}

ingress {
from_port = 80
to_port = 80
protocol = "tcp"
description = "Allow HTTP access"
cidr_blocks = ["0.0.0.0/0"]
}

ingress {
from_port = 443
to_port = 443
protocol = "tcp"
description = "Allow HTTPS access"
cidr_blocks = ["0.0.0.0/0"]
}

