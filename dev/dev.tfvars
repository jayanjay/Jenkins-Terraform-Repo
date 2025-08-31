aws_region   = "ap-south-1"
ami_id       = "ami-00ca32bbc84273381"  # Replace with a valid Ubuntu AMI in your region
instance_type = "t2.micro"
tags = {
  Name = "DevInstance"
  Env  = "dev"
}
