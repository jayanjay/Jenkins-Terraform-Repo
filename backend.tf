terraform {
  backend "s3" {
    bucket         = "jayanjay-terraform-state"
    key            = "main/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}

