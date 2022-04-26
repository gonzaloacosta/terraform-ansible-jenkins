#Get linux AMI ID using SSM Parameter endpoint in master region
data "aws_ssm_parameter" "linux_ami_master" {
  provider = aws.region_master
  name     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

data "aws_ssm_parameter" "linux_ami_slaves" {
  provider = aws.region_slaves
  name     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_key_pair" "master_key" {
  provider   = aws.region_master
  key_name   = "jenkins-master"
  public_key = file(var.jenkins_pub_key)
}

resource "aws_key_pair" "slaves_key" {
  provider   = aws.region_slaves
  key_name   = "jenkins-slaves"
  public_key = file(var.jenkins_pub_key)
}

# master instances
resource "aws_instance" "jenkins_master" {
  provider                    = aws.region_master
  ami                         = data.aws_ssm_parameter.linux_ami_master.value
  instance_type               = var.jenkins_master_instance_type
  key_name                    = aws_key_pair.master_key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.master_sg.id]
  subnet_id                   = aws_subnet.master_subnet_1.id


    provisioner "local-exec" {
      command = <<EOF
aws ec2 wait instance-status-ok --profile ${local.profile}  --region ${var.jenkins_master_region} --instance-ids ${self.id} && \
ansible-playbook --private-key ${var.jenkins_private_key} --extra-vars 'passed_in_hosts=tag_Name_${self.tags.Name}' ansible_templates/install_jenkins_master.yaml
EOF

}

  tags = merge(local.tags, { Name = "jenkins_master_tf" })

  depends_on = [aws_main_route_table_association.set_master_default_rt_assoc]

}

resource "aws_instance" "jenkins_slaves" {
  count                       = var.jenkins_slaves_number
  provider                    = aws.region_slaves
  ami                         = data.aws_ssm_parameter.linux_ami_slaves.value
  instance_type               = var.jenkins_slaves_instance_type
  key_name                    = aws_key_pair.slaves_key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.slaves_sg.id]
  subnet_id                   = aws_subnet.slaves_subnet_1.id

#  provisioner "remote-exec" {
#    when = destroy
#    inline = [
#      "java -jar /home/ec2-user/jenkins-cli.jar -auth @/home/ec2-user/jenkins_auth -s http://jenkins.internal:8080 auth @/home/ec2-user/jenkins_auth delete-node ${self.private_ip}"
#    ]
#    connection {
#      type        = "ssh"
#      user        = "ec2-user"
#      private_key = file(var.jenkins_private_key)
#      host        = self.public_ip
#    }
#  }

  provisioner "local-exec" {
    command = <<EOF
aws ec2 wait instance-status-ok --profile ${local.profile} --region ${var.jenkins_slaves_region} --instance-ids ${self.id} && \
ansible-playbook --private-key ${var.jenkins_private_key} --extra-vars 'passed_in_hosts=tag_Name_${self.tags.Name} master_ip=${aws_instance.jenkins_slaves[count.index].private_ip}' ansible_templates/install_jenkins_slave.yaml
EOF
  }

  tags = merge(local.tags, { Name = "jenkins_slaves_tf" })

  depends_on = [aws_main_route_table_association.set_slaves_default_rt_assoc, aws_instance.jenkins_master]
}

