variable "vpc_id" {}
variable "db_subnet_ids" {}
variable "app_security_group_id" {}
variable "environment" {}
variable "db_instance_class" {}
variable "db_username" {}
variable "db_password" {}

resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = var.db_subnet_ids

  tags = {
    Name = "${var.environment}-db-subnet-group"
  }
}

resource "aws_security_group" "db_sg" {
  name        = "${var.environment}-db-sg"
  description = "Allow DB traffic from App Tier"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432 // PostgreSQL port
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.app_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "main" {
  identifier           = "${var.environment}-rds-db"
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "14.6"
  instance_class       = var.db_instance_class
  db_subnet_group_name = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  username             = var.db_username
  password             = var.db_password
  skip_final_snapshot  = true // Set to false for prod
  multi_az             = var.environment == "prod" ? true : false
}