resource "yandex_iam_service_account" "s3tf" {
  name = "s3tf"
  description = "Service account for S3 storage. Terraform created"
}

resource "yandex_resourcemanager_folder_iam_binding" "storage-admin" {
  folder_id = var.yc_folder_id
  role = "storage.admin"
  members = [ "serviceAccount:${yandex_iam_service_account.s3tf.id}" ]
}

resource "yandex_iam_service_account_static_access_key" "static-key" {
  service_account_id = yandex_iam_service_account.s3tf.id
  description        = "static access key for object storage"
}

resource "yandex_storage_bucket" "momo-store" {
  access_key = yandex_iam_service_account_static_access_key.static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.static-key.secret_key
  bucket = "momo-store-static"
  anonymous_access_flags {
    read = true
    list = false
  }
  max_size = 52428800

}

resource "yandex_storage_bucket" "tfstate" {
  access_key = yandex_iam_service_account_static_access_key.static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.static-key.secret_key
  bucket = "terraform-backend-cherkashin"
}

resource "yandex_storage_object" "image" {
  count = 14
  bucket = yandex_storage_bucket.momo-store.bucket
  key    = "${count.index + 1}.jpg"
  source = "images/${count.index + 1}.jpg"
}