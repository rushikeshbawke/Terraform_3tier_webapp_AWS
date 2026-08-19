variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Name whcih is used for naming resources."
  type        = string
  default     = "demo-three-tier"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "my_ip_cidr" {
  description = "Your IP in CIDR form, allowed for SSH access to instances (only used if ssh_key_name is set)"
  type        = string
  default     = "0.0.0.0/0"
}

# --------- VPC & subnets ------------

variable "vpc_cidr" {
  description = "CIDR of main vpc"
  type        = string
  default     = "12.5.0.0/16"
}

variable "availability_zones" {
  description = "availability zone"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR for web tier subnet"
  type        = list(string)
  default     = ["12.5.0.0/24", "12.5.10.0/24"]
}

variable "app_subnet_cidrs" {
  description = "CIDR for app tier subnet"
  type        = list(string)
  default     = ["12.5.1.0/24", "12.5.11.0/24"]
}

variable "db_subnet_cidrs" {
  description = "CIDR for db tier subnet"
  type        = list(string)
  default     = ["12.5.2.0/24", "12.5.12.0/24"]
}

# --------- web tier variables ---------

variable "web_instance_type" {
  description = "The EC2 instance type for the web tier."
  type        = string
  default     = "t3.micro"
}

variable "web_ami_id" {
  description = "The pre-configured image used by orgnaization"
  type        = string
  default     = null
}

variable "web_asg_min_size" {
  description = "The minimum number of EC2 instances in the web tier."
  type        = number
  default     = 2
}

variable "web_asg_max_size" {
  description = "The maximum number of EC2 instances in the web tier."
  type        = number
  default     = 4
}

variable "web_asg_desired_capacity" {
  description = "The desired number of EC2 instances in the web tier ASG."
  type        = number
  default     = 2
}

variable "web_port" {
  type    = number
  default = 80
}

# --------- app tier variables ---------

variable "app_instance_type" {
  description = "The EC2 instance type for the app tier."
  type        = string
  default     = "t3.small"
}

variable "app_ami_id" {
  description = "The pre-configured image used by orgnaization"
  type        = string
  default     = null
}

variable "app_asg_min_size" {
  description = "The minimum number of EC2 instances in the app tier."
  type        = number
  default     = 2
}

variable "app_asg_max_size" {
  description = "The maximum number of EC2 instances in the app tier."
  type        = number
  default     = 4
}

variable "app_asg_desired_capacity" {
  description = "The desired number of EC2 instances in the web tier ASG."
  type        = number
  default     = 2
}

variable "app_port" {
  type    = number
  default = 8080
}

# --------- db tier ----------

variable "db_engine" {
  type    = string
  default = "mysql"
}

variable "db_engine_version" {
  type    = string
  default = "8.0"
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_allocated_storage" {
  type    = number
  default = 20
}

variable "db_name" {
  type    = string
  default = "appdb"
}

variable "db_username" {
  type    = string
  default = "dbadmin"
}

variable "db_multi_az" {
  description = "Deploy RDS Multi-AZ (primary in AZ-1a, standby/backup in AZ-1b — matches DATABASE-TIER-1/2 in the diagram)"
  type        = bool
  default     = true
}

# ---------  Notifictions -------------
variable "user_email" {
  description = "The email address to receive notifications and alerts."
  type        = string
  default     = "rushikeshbawke0000@gmail.com"
}

# ---- Route53 / CloudFront ----
variable "domain_name" {
  description = "Root domain name managed in Route53 (leave empty to skip Route53/ACM)"
  type        = string
  default     = ""
}

variable "create_route53_zone" {
  description = "Whether Terraform should create the Route53 hosted zone (set false if it already exists)"
  type        = bool
  default     = false
}

variable "ssh_key_name" {
  description = "Existing EC2 key pair name for SSH access (optional, leave empty to disable SSH)"
  type        = string
  default     = ""
}

