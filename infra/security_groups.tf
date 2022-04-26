resource "aws_security_group" "lb_sg" {
  provider    = aws.region_master
  name        = "${local.preffix}-jenkins-master-lb-sg"
  description = "Allow 443 and traffic to Jenkins SG"
  vpc_id      = aws_vpc.vpc_master.id
  ingress {
    description = "Allow 443 from enywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.gonza_office_ips
  }
  ingress {
    description = "Allow 80 from enywhere for redirections"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.gonza_office_ips
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "master_sg" {
  provider    = aws.region_master
  name        = "${local.preffix}-jenkins-master-sg"
  description = "Allow 8080 and traffic to Jenkins SG"
  vpc_id      = aws_vpc.vpc_master.id
  ingress {
    description = "Allow SSH from enywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.gonza_office_ips
  }
  ingress {
    description     = "Allow 80 from enywhere for redirections"
    from_port       = var.jenkins_port
    to_port         = var.jenkins_port
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }
  ingress {
    description = "Allow traffic from vpc slaves"
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["20.3.0.0/16"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "slaves_sg" {
  provider    = aws.region_slaves
  name        = "${local.preffix}-jenkins-slaves-sg"
  description = "Allow TCP/8080 and TCP/22"
  vpc_id      = aws_vpc.vpc_slaves.id
  ingress {
    description = "Allow SSH from enywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.gonza_office_ips
  }
  ingress {
    description = "Allow traffic from vpc master"
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["10.3.0.0/16"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
