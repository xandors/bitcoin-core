locals {
  name   = "${var.environment}-${var.project}"
  region = data.aws_region.current.name
  users = [
    "alex",
    "prod-ci-user"
  ]

  tags = {
    environment = var.environment
    project     = var.project
  }
}
