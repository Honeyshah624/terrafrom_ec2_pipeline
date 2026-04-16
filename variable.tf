variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}

variable "public_key" {
  description = "Public SSH key content"
  type        = string
}

variable "private_key" {
  description = "Private SSH key content"
  type        = string
  sensitive   = true
}

variable "ssh_user" {
  description = "SSH username used by Terraform connection"
  type        = string
  default     = "ubuntu"
}

variable "ssh_port" {
  description = "SSH port used by Terraform connection"
  type        = number
  default     = 22
}

variable "remote_exec_inline" {
  description = "List of remote commands to execute"
  type        = list(string)
}

variable "enable_remote_exec" {
  description = "Whether to run remote-exec provisioning"
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "Common organizational tags"
  type        = map(string)
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet"
  type        = string
}

variable "ingress_rules" {
  description = "Dynamic ingress rules"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}

variable "egress_rule" {
  description = "Dynamic egress rule"
  type = object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  })
}