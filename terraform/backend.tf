terraform {
  backend "s3" {
    bucket       = "ecs-production-cicd-fresh-terraform-state-498245874320"
    key          = "ecs-production-cicd-fresh/production/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}
