variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID to use"
  type        = string
  default     = "ami-0532be01f26a3de55"
}

variable "tags" {
  description = "Tags for the instance"
  type        = map(string)
  default     = {}
}
# variable "aws_access_key" {
#   description = "AWS access key"
#   type        = string
#   default     = "AKIAV6SP6Y3YKHFUKFGT"
# }
# variable "aws_secret_key" {
#   description = "AWS access key"
#   type        = string
#   default     = "TrXMAtMNwgkMpCPp0XTVHdlQgXs3bD+PKHQje1EA"
# }
