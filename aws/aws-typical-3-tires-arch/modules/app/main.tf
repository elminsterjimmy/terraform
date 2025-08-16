variable "vpc_id" {}
variable "public_subnet_ids" {}
variable "app_subnet_ids" {}
variable "environment" {}
variable "app_name" {}
variable "web_instance_type" {}
variable "app_instance_type" {}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

// IAM role for the application tier EC2 instances
resource "aws_iam_role" "app_role" {
    name = "${var.environment}-${var.app_name}--ec2-role"

    assume_role_policy = jsonencode(
        {
            Version = "2012-10-17",
            Statement = [
                {
                    Action = "sts:AssumeRole",
                    Effect = "Allow",
                    Principal = {
                        Service = "ec2.amazonaws.com"
                    }
                }
            ]
        })

    tags = {
        Name        = "${var.environment}-${var.app_name}-ec2-role"
        Environment = var.environment
        Application = var.app_name
    }
}

resource "aws_cloudwatch_log_group" "app_log_group" {
  name              = "/aws/ec2/${var.environment}-${var.app_name}-log-group"
  retention_in_days = 30

  tags = {
    Name        = "${var.environment}-${var.app_name}-log-group"
    Environment = var.environment
    Application = var.app_name
  }
}

// IAM policy to allow writing to CloudWatch Logs
resource "aws_iam_policy" "app_logging_policy" {
    name = "${var.environment}-${var.app_name}-logging-policy"

    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Effect = "Allow",
                Action = [
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents",
                    "logs:DescribeLogStreams",
                ],
                Resource = [
                  # Permission to create the specific log group
                  "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/ec2/${var.environment}-${var.app_name}-log-group",
                  # Permission for any log stream within that specific log group
                  "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/ec2/${var.environment}-${var.app_name}-log-group:*",
                ]
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "app_logging_attachment" {
  role       = aws_iam_role.app_role.name
  policy_arn = aws_iam_policy.app_logging_policy.arn
}

// IAM instance profile for the application tier
resource "aws_iam_instance_profile" "app_instance_profile" {
    name = "${var.environment}-${var.app_name}-instance-profile"
    role = aws_iam_role.app_role.name

    tags = {
        Name        = "${var.environment}-${var.app_name}-instance-profile"
        Environment = var.environment
        Application = var.app_name
    }
}


// Placeholder for Web Tier Security Group
resource "aws_security_group" "web_sg" {
  name        = "${var.environment}-web-sg"
  description = "Web Tier Security Group, allowing HTTP and HTTPS inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1" // All protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-web-sg"
    Environment = var.environment
    Application = var.app_name
  }
}

// Placeholder for App Tier Security Group
resource "aws_security_group" "app_sg" {
  name        = "${var.environment}-${var.app_name}-sg"
  description = "App Tier Security Group, allowing traffic from Web Tier"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1" // All protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-${var.app_name}-sg"
    Environment = var.environment
    Application = var.app_name
  }
}


// NOTE: A full implementation would include:
// - aws_launch_template for web servers
// - aws_autoscaling_group for web servers
// - aws_lb for the public-facing ALB
// - aws_lb_target_group for the web servers
// - aws_launch_template for app servers
// - aws_autoscaling_group for app servers
// - aws_lb for an internal load balancer (optional)
// - aws_lb_target_group for the app servers



data "aws_ami" "amazon_liunx_2" {
    most_recent = true
    owners      = ["amazon"]

    filter {
        name = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }
}

// Placeholder for App Tier Launch Template
resource "aws_launch_template" "app_tier" {
    name_prefix = "${var.environment}-${var.app_name}-"
    image_id = data.aws_ami.amazon_liunx_2.id
    instance_type = var.app_instance_type

    iam_instance_profile {
      name = aws_iam_instance_profile.app_instance_profile.name
    }

    vpc_security_group_ids = [aws_security_group.app_sg.id]

    lifecycle {
      create_before_destroy = true
    }
}