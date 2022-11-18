terraform {
#   backend "s3" {
#   }
  backend "s3" {
  endpoint   = "storage.yandexcloud.net"
  bucket     = "terraform-backend-cherkashin"
  region     = "ru-central1"
  key        = "terraform/terraform.tfstate"
  shared_credentials_file = ".s3conf"
  skip_region_validation      = true
  skip_credentials_validation = true
 }
}