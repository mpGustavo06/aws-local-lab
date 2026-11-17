# Segredo no Secrets Manager para credenciais do banco e chave JWT de login
resource "aws_secretsmanager_secret" "app_secrets" {
  name                    = "storage-app/prod/credentials"
  description             = "Credenciais do PostgreSQL e segredo JWT para login"
  recovery_window_in_days = 0 # Facilita recriacao imediata em ambiente de testes
}

resource "aws_secretsmanager_secret_version" "app_secrets_val" {
  secret_id = aws_secretsmanager_secret.app_secrets.id
  secret_string = jsonencode({
    DB_USERNAME = "app_admin"
    DB_PASSWORD = "SuperSecretPassword123!"
    JWT_SECRET  = "chave-secreta-jwt-local-2026"
  })
}

# IAM Role para o Servidor EC2 assumir identidade sem precisar de Access Keys fixas
resource "aws_iam_role" "ec2_role" {
  name = "storage-app-ec2-role"

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

# Politica dando acesso ao S3 (arquivos), SQS (fila) e Secrets Manager (login/banco)
resource "aws_iam_role_policy" "ec2_policy" {
  name = "storage-app-ec2-policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.user_files.arn,
          "${aws_s3_bucket.user_files.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage"
        ]
        Resource = [aws_sqs_queue.file_processing.arn]
      },
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = [aws_secretsmanager_secret.app_secrets.arn]
      }
    ]
  })
}

# Instance Profile que vincula a IAM Role a instancia EC2
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "storage-app-ec2-profile"
  role = aws_iam_role.ec2_role.name
}