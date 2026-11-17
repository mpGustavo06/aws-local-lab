output "load_balancer_dns" {
  description = "Endereco publico do Application Load Balancer"
  value       = aws_lb.app_alb.dns_name
}

output "s3_bucket_name" {
  description = "Nome do bucket S3 criado para armazenar arquivos"
  value       = aws_s3_bucket.user_files.bucket
}

output "rds_endpoint" {
  description = "Endpoint de conexao do banco PostgreSQL"
  value       = aws_db_instance.postgres.endpoint
}

output "sqs_queue_url" {
  description = "URL da fila SQS de processamento de arquivos"
  value       = aws_sqs_queue.file_processing.url
}

output "ec2_instance_id" {
  description = "ID da instancia EC2 criada"
  value       = aws_instance.app_server.id
}