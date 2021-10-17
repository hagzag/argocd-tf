locals {
  password  = bcrypt(random_password.password.result, 10)
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "random_string" "suffix-name" {
  length          = 8
  special         = false
}
