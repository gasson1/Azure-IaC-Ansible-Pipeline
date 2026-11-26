# ------------------------------------------------------------------
# Most między Terraformem a Ansible: po "terraform apply" Terraform
# sam zapisuje plik inventory.ini z aktualnymi adresami IP maszyn.
# Dzięki temu nie trzeba ręcznie przepisywać adresów do inwentarza.
# ------------------------------------------------------------------
resource "local_file" "ansible_inventory" {
  filename        = "${path.module}/inventory.ini"
  file_permission = "0644"

  content = templatefile("${path.module}/inventory.tftpl", {
    web_public_ip  = azurerm_public_ip.web_pip.ip_address
    db_private_ip  = azurerm_network_interface.db_nic.private_ip_address
    admin_username = var.admin_username
  })
}
