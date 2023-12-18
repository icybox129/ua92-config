resource "aws_instance" "wp" {
  ami                    = "ami-0fc5d935ebf8bc3bc"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = var.ec2_sg
  user_data              = file("${path.module}/user-data.sh")

  tags = { Name = "${var.naming_prefix}-ec2" }

}