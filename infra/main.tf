terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = var.regiao_aws
}

# resource "aws_vpc" "main" {
#   cidr_block       = "10.0.0.0/16"
#   instance_tenancy = "default"

#   tags = {
#     Name = "main"
#   }
# }

resource "aws_launch_template" "maquina" {
  image_id =  "ami-0735c191cf914754d"
  instance_type = var.instancia
  key_name = var.chave
  tags = {
    Name = "Terraform Ansible Python"
  }
  #Add Security Group
  security_group_names =  [ var.ambiente ]
  #vpc_security_group_ids = [aws_security_group.acesso_geral.id]
}

resource "aws_key_pair" "chaveSSH" {
  key_name = var.chave
  public_key = file("${var.chave}.pub")
}


resource "aws_autoscaling_group" "grupo" {
  availability_zones = [ "${var.regiao_aws}a" ]
  name = var.nomeGrupo
  desired_capacity = 1
  max_size = var.maximo
  min_size = var.minimo
  launch_template {
    id = aws_launch_template.maquina.id
    version = "$Latest"
  }
}
