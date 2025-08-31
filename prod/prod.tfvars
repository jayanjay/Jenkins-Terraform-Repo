aws_region   = "ap-south-1"
ami_id       = "ami-02d26659fd82cf299"  # Replace with a valid AMI
instance_type = "t3.micro"
tags = {
  Name = "ProdInstance"
  Env  = "prod"
}
