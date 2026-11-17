# Bucket S3 Privado para armazenar os arquivos dos usuarios
resource "aws_s3_bucket" "user_files" {
  bucket        = "storage-app-user-files-local"
  force_destroy = true # Permite destruir o bucket mesmo se houver arquivos de teste

  tags = {
    Name = "storage-app-user-files"
  }
}

# Bloqueia qualquer acesso publico direto aos arquivos do bucket
resource "aws_s3_bucket_public_access_block" "user_files_block" {
  bucket = aws_s3_bucket.user_files.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Ativa versionamento para evitar perda acidental de arquivos
resource "aws_s3_bucket_versioning" "user_files_versioning" {
  bucket = aws_s3_bucket.user_files.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Fila SQS para processamento assincrono apos upload (ex: miniaturas/virus scan)
resource "aws_sqs_queue" "file_processing" {
  name                       = "storage-app-file-processing-queue"
  visibility_timeout_seconds = 60
  message_retention_seconds  = 86400

  tags = {
    Name = "storage-app-file-processing-queue"
  }
}

# Grupo de Subnets Privadas para o Banco RDS
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "storage-app-rds-subnet-group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  tags = {
    Name = "storage-app-rds-subnet-group"
  }
}

# Instancia RDS PostgreSQL (Usuarios, Login e Metadados dos Arquivos)
resource "aws_db_instance" "postgres" {
  identifier             = "storage-app-db"
  engine                 = "postgres"
  engine_version         = "16.3"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = "storage_app"
  username               = "app_admin"
  password               = "SuperSecretPassword123!"
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible    = false
  skip_final_snapshot    = true

  tags = {
    Name = "storage-app-postgres"
  }
}