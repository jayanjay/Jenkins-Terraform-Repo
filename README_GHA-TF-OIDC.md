AWS CONSOLE – One-time setup
================================
Step 1: Create OIDC Identity Provider
-------------------------------------------
AWS Console → IAM → Identity providers → Add provider
Provider type: OpenID Connect
Provider URL: https://token.actions.githubusercontent.com
Audience: sts.amazonaws.com
# This enables GitHub to authenticate with AWS without secrets.

Step 2: Create IAM Role for GitHub Actions
-----------------------------------------------
IAM → Roles → Create role → GHA-Role(role_name)
> Trusted entity type: Web identity
> Identity provider: token.actions.githubusercontent.com
> Audience: sts.amazonaws.com
> Attach permissions to the role → AmazonS3FullAccess , AmazonDynamoDBFullAccess , AmazonEC2FullAccess

Step 3: Fix the IAM Trust Policy (CRITICAL)
-----------------------------------------------
Edit Trust relationships of the role and replace with:
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::621402808084:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:jayanjay/Jenkins-Terraform-Repo:*"
        }
      }
    }
  ]
}

Step 4 : Step 5: Create S3 bucket for Terraform state in VS Terminal
------------------------------------------------------------------------
1st run - 
---------------
aws s3 mb s3://jayanjay-terraform-state --region ap-south-1

aws s3api put-bucket-versioning \
  --bucket jayanjay-terraform-state \
  --versioning-configuration Status=Enabled

2nd run - 
----------------
Create a file called encryption.json and add below command - 
{
  "Rules": [
    {
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }
  ]
}
Then run :
aws s3api put-bucket-encryption --bucket jayanjay-terraform-state --server-side-encryption-configuration file://encryption.json

Step 5 : Create DynamoDB Table for Locking
--------------------------------------------------
aws dynamodb create-table \
  --table-name terraform-state-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region ap-south-1

Step 6: Update IAM Role Used by OIDC (below step is not needed if you already given your role full access to S3 and DynamoDB)
-------------------------------------------------------------------------------------------------------------------------------
Your existing OIDC role must have access to backend resources. Attach this policy to the role

{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket"
      ],
      "Resource": "arn:aws:s3:::jayanjay-terraform-state"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws:s3:::jayanjay-terraform-state/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:DeleteItem",
        "dynamodb:DescribeTable"
      ],
      "Resource": "arn:aws:dynamodb:ap-south-1:<ACCOUNT_ID>:table/terraform-state-locks"
    }
  ]
}

Step 7: Add Terraform Backend Configuration
------------------------------------------------
Create backend.tf with below content :

terraform {
  backend "s3" {
    bucket         = "jayanjay-terraform-state"
    key            = "main/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}

Step 8: Run your WorkFlow and check the status.
-----------------------------------------------------

Notes: why we go for OIDC instead of Access Keys and Secret Keys
------------------------------------------------------------------------
(OpenID Connect) is an identity federation protocol built on OAuth 2.0. An OIDC provider is a trusted identity issuer that can prove who something is without passwords or keys.

In this setup: GitHub is the OIDC provider. AWS is the service that trusts it

OIDC Way (What we implemented) - No keys. No secrets. No storage.

Instead: GitHub proves its identity to AWS at runtime, and AWS issues temporary credentials. AWS trusts GitHub to say “this workflow is who it claims to be,” and gives it temporary AWS credentials.

How GitHub ↔ AWS OIDC works (Step-by-step)
-----------------------------------------------
1️⃣ GitHub Workflow starts - Your workflow runs with: permissions:
                                                        id-token: write
   This tells GitHub: “I need an identity token for this run”

2️⃣ GitHub creates an OIDC token (JWT) - GitHub generates a signed JWT token, which is Is short-lived (minutes), Is                 
cryptographically signed, Cannot be forged

3️⃣ GitHub sends token to AWS STS - GitHub calls: sts:AssumeRoleWithWebIdentity and sends The OIDC token and The IAM role ARN (GHA-Role)

4️⃣ AWS validates the token - AWS checks: Is the token issuer trusted? We have registered - https://token.actions.githubusercontent.com as an IAM OIDC Provider.

5️⃣ Does the role trust this provider? - IAM role trust policy:
                                        "Principal": {
                                        "Federated": "arn:aws:iam::ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
                                                    }
6️⃣ AWS issues TEMPORARY credentials - If everything matches, AWS returns: AccessKeyId, SecretAccessKey, SessionToken
    These are Valid for minutes to hours
    These are: Auto-rotated, Short-lived, Scoped to the role permissions

7️⃣ GitHub injects credentials into environment : AWS credentials are set as environment variables: AWS_ACCESS_KEY_ID,               AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN

Now, Terraform talks to AWS
-------------------------------