module "aws-prod" {
    source = "../../infra"
    instancia = "t2.micro"
    regiao_aws = "us-west-2"
    chave = "IaC-Prod"
    ambiente = "prod"
}

output "IP" {
  value = module.aws-prod.IP_publico
}