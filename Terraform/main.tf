provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "./modules/vpc"
}

module "igw" {
  source = "./modules/igw"
  vpc_id = module.vpc.vpc_id
}

module "subnets" {
  source = "./modules/subnets"
  vpc_id = module.vpc.vpc_id
}

module "route_table" {
  source           = "./modules/route_table"
  vpc_id           = module.vpc.vpc_id
  igw_id           = module.igw.igw_id
  public_subnet_id = module.subnets.public_subnet_id
}

module "ec2" {
  source           = "./modules/ec2"
  vpc_id           = module.vpc.vpc_id
  public_subnet_id = module.subnets.public_subnet_id
  private_subnet_id = module.subnets.private_subnet_id
  key_name         = "my-key-pair"
}
