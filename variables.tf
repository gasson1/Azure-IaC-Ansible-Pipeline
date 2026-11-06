# Zmienne wejściowe. Dzięki nim te same pliki .tf można wdrożyć
# z innymi ustawieniami (np. inny region) bez zmieniania kodu.
# Wartości podajemy w pliku terraform.tfvars (nie trafia na GitHuba).

variable "location" {
  description = "Region Azure, w którym powstanie infrastruktura"
  type        = string
  default     = "westeurope"
}

variable "prefix" {
  description = "Prefiks dodawany do nazw wszystkich zasobów"
  type        = string
  default     = "dyplom"
}

variable "vm_size" {
  description = "Rozmiar maszyn wirtualnych (B1s mieści się w darmowej subskrypcji)"
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Nazwa użytkownika administratora na maszynach"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  description = "Ścieżka do PUBLICZNEGO klucza SSH typu RSA (plik .pub)"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "allowed_ssh_cidr" {
  description = "Adres IP (w formacie CIDR, np. 1.2.3.4/32), z którego wolno łączyć się przez SSH"
  type        = string
}
