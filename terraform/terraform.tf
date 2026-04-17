terraform {
  backend "s3" {
    bucket = "terraform-iamrobertyoung"
    key    = "projects/homelab-graylog/main/tfstate.json"
    region = "eu-west-1"
  }
}
