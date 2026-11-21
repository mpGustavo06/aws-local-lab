# ==============================================================================
# SECURITY GROUPS
# ==============================================================================

# Security Group do Application Load Balancer (ALB)
resource "aws_security_group" "alb_sg" {
  name        = "storage-app-alb-sg"
  description = "Permite trafego HTTP de entrada vindo da internet"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "storage-app-alb-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb_sg.id
  description       = "Permite trafego HTTP na porta 80"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "alb_out" {
  security_group_id = aws_security_group.alb_sg.id
  description       = "Permite todo o trafego de saida do ALB"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


# Security Group da Aplicação (EC2 / Web Server)
resource "aws_security_group" "app_sg" {
  name        = "storage-app-ec2-sg"
  description = "Permite trafego na porta da aplicacao restrito ao ALB"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "storage-app-ec2-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "app_from_alb" {
  security_group_id            = aws_security_group.app_sg.id
  description                  = "Permite acesso na porta 8080 apenas atraves do ALB"
  referenced_security_group_id = aws_security_group.alb_sg.id
  ip_protocol                  = "tcp"
  from_port                    = 8080
  to_port                      = 8080
}

resource "aws_vpc_security_group_egress_rule" "app_out" {
  security_group_id = aws_security_group.app_sg.id
  description       = "Permite todo o trafego de saida da aplicacao"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


# Security Group do Banco de Dados (RDS PostgreSQL)
resource "aws_security_group" "rds_sg" {
  name        = "storage-app-rds-sg"
  description = "Permite acesso ao PostgreSQL restrito aos servidores web"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "storage-app-rds-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_app" {
  security_group_id            = aws_security_group.rds_sg.id
  description                  = "Permite PostgreSQL na porta 5432 apenas a partir da EC2"
  referenced_security_group_id = aws_security_group.app_sg.id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
}

resource "aws_vpc_security_group_egress_rule" "rds_out" {
  security_group_id = aws_security_group.rds_sg.id
  description       = "Permite todo o trafego de saida do banco de dados"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}