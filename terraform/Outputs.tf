output "aws_instance_id" {
  value = aws_instance.n8n_server.id
}

output "public_dns" {
  value = aws_instance.n8n_server.public_dns
}

output "public_ip" {
  value = aws_instance.n8n_server.public_ip
}