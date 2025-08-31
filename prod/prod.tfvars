aws_region   = "us-east-1"
ami_id       = "ami-0360c520857e3138f"  # Replace with a valid AMI
instance_type = "t3.micro"
tags = {
  Name = "ProdInstance"
  Env  = "prod"
}
