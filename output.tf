output "ec2_public_ip" {
  description = "Public IP of the EC2 instance from child module"
  value       = module.ec2.instance_public_ip
}