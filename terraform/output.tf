output "credential_name" {
    value = ec_deployment.try-vector-search.elasticsearch_username
}

output "credential_password" {
    value = nonsensitive(ec_deployment.try-vector-search.elasticsearch_password)
}

output "endpoint" {
  value = ec_deployment.try-vector-search.elasticsearch[0].https_endpoint
}