aws_region   = "us-east-1"
ami_id       = "ami-025fe52e1f2dc5044"  # Replace with a valid AMI
instance_type = "t3.micro"
tags = {
  Name = "ProdInstance"
  Env  = "prod"
}
