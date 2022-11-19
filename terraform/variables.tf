variable "yc_cloud_id" {
  description = "Yandex Cloud cloud ID"
  type = string
  default = "b1gg4bpie8ugm3fn140o"
}

variable "yc_folder_id" {
  description = "Yandex Cloud folder ID"
  type = string
  default = "b1g359ce7ggcfaa2ijm1"
}

variable "yc_zone_name" {
  description = "Yandex Cloud zone name"
  type = string
  default = "ru-central1-a"
}

variable "yc_token" {
    description = "OAuth token"
    sensitive = true
}

variable "s3access_key" {
  description = "Access key to Storage service"
  sensitive = true
}

variable "s3secret_key" {
  description = "Secret key to Storage service"
  sensitive = true
}
