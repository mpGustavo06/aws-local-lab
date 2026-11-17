terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  insecure                    = true

  endpoints {
    s3             = "https://127.0.0.1:9297"
    dynamodb       = "https://127.0.0.1:9297"
    sqs            = "https://127.0.0.1:9297"
    sns            = "https://127.0.0.1:9297"
    iam            = "https://127.0.0.1:9297"
    sts            = "https://127.0.0.1:9297"
    lambda         = "https://127.0.0.1:9297"
    ec2            = "https://127.0.0.1:9297"
    rds            = "https://127.0.0.1:9297"
    elb            = "https://127.0.0.1:9297"
    elbv2          = "https://127.0.0.1:9297"
    secretsmanager = "https://127.0.0.1:9297"
  }
}