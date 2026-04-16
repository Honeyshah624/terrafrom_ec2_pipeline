resource "aws_security_group" "ssh_sg" {
  name        = "secure-ssh-sg"
  description = "Allow SSH and HTTP inbound rules"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = var.egress_rule.from_port
    to_port     = var.egress_rule.to_port
    protocol    = var.egress_rule.protocol
    cidr_blocks = var.egress_rule.cidr_blocks
  }

  tags = merge(var.common_tags, {
    Name = "secure-ssh-sg"
  })
}

resource "aws_key_pair" "imported_key" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)

  tags = var.common_tags
}

resource "aws_instance" "secure_ec2" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.ssh_sg.id]
  key_name                    = aws_key_pair.imported_key.key_name
  associate_public_ip_address = false

  tags = merge(var.common_tags, {
    Name = "TestVM"
  })
}

resource "aws_eip" "elastic_ip" {
  domain = "vpc"

  tags = merge(var.common_tags, {
    Name = "TestVM-EIP"
  })
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.secure_ec2.id
  allocation_id = aws_eip.elastic_ip.id
}

resource "null_resource" "install_remote" {
  count      = var.enable_remote_exec ? 1 : 0
  depends_on = [aws_eip_association.eip_assoc]

  triggers = {
    instance_id = aws_instance.secure_ec2.id
    eip         = aws_eip.elastic_ip.public_ip
    ssh_user    = var.ssh_user
    commands    = join(" || ", var.remote_exec_inline)
  }

  connection {
    type        = "ssh"
    user        = var.ssh_user
    host        = aws_eip.elastic_ip.public_ip
    port        = var.ssh_port
    private_key = file(var.private_key_path)
    timeout     = "5m"
  }

  provisioner "remote-exec" {
    inline = var.remote_exec_inline
  }
}