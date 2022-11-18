locals {
  urls = [
    for i in yandex_storage_object.image :
    "${yandex_storage_bucket.momo-store.bucket_domain_name}/${i.key}"
  ]
}

output ImageURLs {

  value = local.urls
  
}