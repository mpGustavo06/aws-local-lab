# Application Load Balancer (ALB) nas Subnets Publicas
resource "aws_lb" "app_alb" {
  name               = "storage-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  tags = {
    Name = "storage-app-alb"
  }
}

# Target Group apontando para a porta 8080 da aplicacao
resource "aws_lb_target_group" "app_tg" {
  name     = "storage-app-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Listener HTTP (Porta 80) encaminhando para o Target Group
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# Instancia EC2 (Servidor da Aplicacao Web / API de Login e Upload)
resource "aws_instance" "app_server" {
  ami                    = "ami-0c55b159cbfafe1f0" # AMI ficticia aceita pelo emulador local
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_a.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "storage-app-web-server"
  }
}

# Registra a instancia EC2 dentro do Target Group do Load Balancer
resource "aws_lb_target_group_attachment" "app_attachment" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.app_server.id
  port             = 8080
}