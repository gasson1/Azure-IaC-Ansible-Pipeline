# Wartości wyświetlane po "terraform apply".
# Później użyje ich Ansible, żeby wiedzieć, gdzie się połączyć.

output "web_public_ip" {
  description = "Publiczny adres IP serwera web"
  value       = azurerm_public_ip.web_pip.ip_address
}

output "web_private_ip" {
  description = "Prywatny adres IP serwera web"
  value       = azurerm_network_interface.web_nic.private_ip_address
}

output "db_private_ip" {
  description = "Prywatny adres IP serwera bazy danych"
  value       = azurerm_network_interface.db_nic.private_ip_address
}

output "admin_username" {
  description = "Użytkownik do logowania przez SSH"
  value       = var.admin_username
}
