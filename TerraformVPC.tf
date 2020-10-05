provider "aws" {
    region = "us-east-1"
}

resource "aws_vpc" "TerraformVPC" {
    cidr_block = "192.168.0.0/16"
    tags = {
        Name = "temitayokasali"
    }
}

resource "aws_subnet" "mysubnet" {
    cidr_block = "192.168.1.0/24"
    vpc_id = aws_vpc.TerraformVPC.id
}

resource "aws_internet_gateway" "tkig" {
    vpc_id = aws_vpc.TerraformVPC.id

    tags = {
        Name = "TerraformIGW"
    }
}

resource "aws_route_table" "rtaws" {
    vpc_id = aws_vpc.TerraformVPC.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.tkig.id
    }
    tags = {
        Name = "TerraformRT"
    }
}

resource "aws_route_table_association" "A" {
    subnet_id      = aws_subnet.mysubnet.id
    route_table_id = aws_route_table.rtaws.id
}


resource "aws_security_group" "TKSG" {
    name        = "allow_tls"
    description = "Allow TLS inbound traffic"
    vpc_id      = aws_vpc.TerraformVPC.id

    ingress {
        description = "TLS from VPC"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "TLS from VPC"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        description = "TLS from VPC"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "TKSG"
    }
}


output "VPCIP" {
    value = aws_vpc.TerraformVPC.cidr_block
}


resource "aws_instance" "ec2" {
    ami = "ami-00514a528eadbc95b"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.mysubnet.id
    associate_public_ip_address = true
    security_groups = [aws_security_group.TKSG.id]
    key_name = "terraformk"
}

output "PrivateIP" {
    value = aws_instance.ec2.private_ip
}

output "PublicIP" {
    value = aws_instance.ec2.public_ip
}


output "keyname" {
    value = aws_instance.ec2.key_name
}

output "instancetype" {
    value = aws_instance.ec2.instance_type
}

