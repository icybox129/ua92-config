output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "subnets" {
  value = aws_subnet.public_subnet.id
}

output "vpc_cidr_block" {
  value = var.vpc_cidr_block
}

output "public_ip" {
  value = aws_instance.wp.public_ip
}