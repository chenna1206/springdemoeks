output "ec2_public_ip" {
  value = aws_instance.spring_ec2.public_ip
}

output "ec2_public_dns" {
  value = aws_instance.spring_ec2.public_dns
}

output "ecr_repository_url" {
  value = aws_ecr_repository.springboot.repository_url
}