output client_config_path {
  value = local_file.client-configuration.filename
}

output client_config_content {
  value = local_file.client-configuration.content
}