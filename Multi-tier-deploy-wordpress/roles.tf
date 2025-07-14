# Create IAM role for Terraform deployments
resource "aws_iam_role" "terraform_role" {
  name = "terraform-deployment-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"  # Adjust based on your use case
          # OR use AWS = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
      }
      }
    ]
  })
}

    # Create policy for Secrets Manager access
resource "aws_iam_policy" "terraform_secrets_policy" {
  name = "terraform-secrets-policy"
  description = "Policy for Terraform to manage Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:CreateSecret",
          "secretsmanager:PutSecretValue",
          "secretsmanager:DeleteSecret",
          "secretsmanager:TagResource",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "*"
       }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "terraform_secrets_attachment" {
  role       = aws_iam_role.terraform_role.name
  policy_arn = aws_iam_policy.terraform_secrets_policy.arn
}


#Ec2 role and policy
resource "aws_iam_role" "ec2_role" {
  name = "ec2_secrets_access"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "secrets_policy" {
  name = "secrets_access_policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [aws_secretsmanager_secret.kezsecret.arn]
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_secrets_profile"
  role = aws_iam_role.ec2_role.name
}
