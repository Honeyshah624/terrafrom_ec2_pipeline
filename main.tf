module "ec2" {
  source = "./modules/ec2"

  vpc_id             = var.vpc_id
  subnet_id          = var.subnet_id
  ami_id             = var.ami_id
  instance_type      = var.instance_type
  key_name           = var.key_name
  public_key         = var.public_key
  private_key        = var.private_key
  ssh_user           = var.ssh_user
  ssh_port           = var.ssh_port
  remote_exec_inline = var.remote_exec_inline
  enable_remote_exec = var.enable_remote_exec
  common_tags        = var.common_tags
  ingress_rules      = var.ingress_rules
  egress_rule        = var.egress_rule
  aws_region         = var.aws_region
  vpc_cidr           = var.vpc_cidr
}