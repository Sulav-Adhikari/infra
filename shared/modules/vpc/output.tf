output "vpc_id" {
  value = aws_vpc.this.id
}

output "cidr_block" {
  value = aws_vpc.this.cidr_block
}

output "public_subnets" {
  value = aws_subnet.public.*.id
}

output "private_subnets" {
  value = aws_subnet.private.*.id
}

output "allow_ssh_sg" {
  value = length(var.ssh_allow_cidrs) > 0 ? element(aws_security_group.allow_ssh.*.id, 1) : ""
}


output "allow_http_sg" {
  value = aws_security_group.allow_http.id
}

output "main_rt" {
  value = aws_vpc.this.main_route_table_id
}

output "aws_azs" {
  value = data.aws_availability_zones.available.names
}

output "private_subnets_cidr" {
  value = aws_subnet.private.*.cidr_block
}

output "nat_eip" {
  value = var.enable_private_net ? element(aws_eip.eip.*.public_ip, 0) : ""
}

output "allow_local_all" {
  value = aws_security_group.local_allow_all.id
}

output "allow_efs_sg" {
  value = aws_security_group.allow_efs.id
}
