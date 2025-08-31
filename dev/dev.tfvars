aws_region   = "ap-south-1"
ami_id       = "ami-0861f4e788f5069dd"  # Replace with a valid Ubuntu AMI in your region
instance_type = "t2.micro"
tags = {
  Name = "DevInstance"
  Env  = "dev"
}
