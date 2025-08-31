variable "aws_region" {
  description = "AWS region"
  type        = string
  default = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID to use"
  type        = string
  default = "ami-025fe52e1f2dc5044"
}

variable "tags" {
  description = "Tags for the instance"
  type        = map(string)
  default     = {}
}
variable "aws_access_key" {
  description = "AWS access key"
  type        = string
  default     = "AKIATAPXOSEZHPVZVUWH"
}
variable "aws_secret_key" {
  description = "AWS access key"
  type        = string
  default     = "X5qAsezDEi7oPKveafNSJEpa2rthgyd9Fvl6vG/h"
}
