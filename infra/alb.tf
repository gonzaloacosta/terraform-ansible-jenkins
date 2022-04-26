resource "aws_lb" "jenkins" {
  provider           = aws.region_master
  name               = "jenkins-master"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [aws_subnet.master_subnet_1.id, aws_subnet.master_subnet_2.id]
  tags               = merge(local.tags, { Name = "${local.preffix}-jenkins-master" })
}

resource "aws_lb_target_group" "jenkins" {
  provider    = aws.region_master
  name        = "jenkins-lb-tg"
  port        = 8080
  target_type = "instance"
  vpc_id      = aws_vpc.vpc_master.id
  protocol    = "HTTP"
  health_check {
    enabled  = true
    interval = 10
    path     = "/login"
    port     = 8080
    protocol = "HTTP"
    matcher  = "200-299"
  }
  tags = merge(local.tags, { Name = "${local.preffix}-jenkins-lb-tg" })
}

resource "aws_lb_listener" "jenkins_http" {
  provider          = aws.region_master
  load_balancer_arn = aws_lb.jenkins.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "jenkins_https" {
  provider          = aws.region_master
  load_balancer_arn = aws_lb.jenkins.arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.jenkins_lb_https.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins.arn
  }
}

resource "aws_lb_target_group_attachment" "jenkins" {
  provider         = aws.region_master
  target_group_arn = aws_lb_target_group.jenkins.arn
  target_id        = aws_instance.jenkins_master.id
  port             = 8080

}
