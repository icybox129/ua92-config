provider "aws" {
  region = "us-east-1"
}

module "network" {
  source        = "../../modules/network"
  naming_prefix = local.naming_prefix
  ec2_sg        = [module.sg.ec2_sg_id]
}

module "sg" {
  source         = "../../modules/sg"
  naming_prefix  = local.naming_prefix
  vpc_id         = module.network.vpc_id
  vpc_cidr_block = module.network.vpc_cidr_block
}

module "r53" {
  source        = "../../modules/r53"
  naming_prefix = local.naming_prefix
  public_ip      = module.network.public_ip
}
