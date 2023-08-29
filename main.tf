provider "aws" {
  region = lookup(var.awsprops, "region")
}

resource "aws_vpc" "dt_default_vpc" {
	cidr_block = "10.0.0.0/16"
	tags = {
		Name = "DT Default VPC"
	}
}
resource "aws_subnet" "app-subnet" {
	vpc_id = aws_vpc.dt_default_vpc.id
	cidr_block = "10.0.1.0/24"
	tags = {
		Name = "App Subnet"
	}
}
resource "aws_subnet" "db-subnet" {
	vpc_id = aws_vpc.dt_default_vpc.id
	cidr_block = "10.0.2.0/24"
	tags = {
		Name = "DB Subnet"
	}
}

resource "aws_security_group" "custom-sg" {
  name = lookup(var.awsprops, "secgroupname")
  description = lookup(var.awsprops, "secgroupname")
  vpc_id = aws_vpc.dt_default_vpc.id

  // To Allow SSH Transport
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  // To Allow Port 80 Transport
  ingress {
    from_port = 80
    protocol = ""
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_instance" "c8.local" {
  ami = lookup(var.awsprops, "ami")
  instance_type = lookup(var.awsprops, "itype")
  subnet_id = aws_subnet.app-subnet.id
  associate_public_ip_address = lookup(var.awsprops, "publicip")
  key_name = lookup(var.awsprops, "keyname")


  vpc_security_group_ids = [
    aws_security_group.custom-sg.id
  ]
  root_block_device {
    delete_on_termination = true
    iops = 150
    volume_size = 50
    volume_type = "gp2"
  }
  tags = {
    Name ="c8.local"
    Environment = "DEV"
    OS = "CentOS-8"
    Managed = "IAC"
  }

  depends_on = [ aws_security_group.custom-sg ]
}

resource "aws_instance" "u21.local" {
  ami = lookup(var.awsprops, "ami1")
  instance_type = lookup(var.awsprops, "itype")
  subnet_id = aws_security_group.db-subnet.id
  key_name = lookup(var.awsprops, "keyname")


  vpc_security_group_ids = [
    aws_security_group.custom-sg.id
  ]
  root_block_device {
    delete_on_termination = true
    iops = 150
    volume_size = 50
    volume_type = "gp2"
  }
  tags = {
    Name ="u21.local"
    Environment = "DEV"
    OS = "UBUNTU-21-04"
    Managed = "IAC"
  }

  depends_on = [ aws_security_group.custom-sg ]
}



output "ec2instance" {
  value = aws_instance.c8.local.public_ip
  value1 = aws_instance.u21.local.private_ip
}
