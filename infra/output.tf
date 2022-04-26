output "jenkins_main_node_public_ip" {
  value = aws_instance.jenkins_master.public_ip
}

output "jenkins_slaves_public_ipds" {
  value = {
    for instance in aws_instance.jenkins_slaves :
    instance.id => instance.public_ip
  }
}

output "lb_dns_name" {
  value = aws_lb.jenkins.dns_name
}

output "url" {
  value = aws_route53_record.jenkins.fqdn
}
