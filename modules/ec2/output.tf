output "instance_public_ip" {
  description = "Elastic IP attached to the EC2 instance"
  value       = aws_eip.elastic_ip.public_ip
}