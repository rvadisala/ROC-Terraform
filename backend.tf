#terraform {
#  backend "s3" {
#    region         = "us-east-2"
#    profile        = "default"
#    key            = "terraformstatefile.tfstate"
#    bucket         = "terraform-stateinfo-2022"
#    dynamodb_table = "terraformlocking"
#  }
#}