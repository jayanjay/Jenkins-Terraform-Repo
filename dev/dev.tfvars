aws_region   = "ap-south-1"
ami_id       = "ami-025fe52e1f2dc5044"  # Replace with a valid Ubuntu AMI in your region
instance_type = "t2.micro"
tags = {
  Name = "DevInstance"
  Env  = "dev"
}
