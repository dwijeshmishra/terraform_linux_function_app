#approach 1
resource "azurerm_bastion_host" "bastion" {
  count = data.azurerm_bastion_host.existing_bastion.sku == "Standard" ? 1 : 0

  dynamic "bastion" {
    for_each = count.index == 0 ? [1] : []

    content {
      name                = "shared-bastion"
      location            = var.location
      resource_group_name = var.target_infra_rg
      sku                 = "Basic"

      ip_configuration {
        name                  = "configuration"
        subnet_id             = azurerm_subnet.subnet-bastion.id
        public_ip_address_id  = azurerm_public_ip.bastion.id
      }

      lifecycle {
        create_before_destroy = true
      }
    }
  }
}
#approach 2
locals {
  recreate_bastion = data.azurerm_bastion_host.existing_bastion.sku == "Standard" ? [0, 1] : []
}

resource "azurerm_bastion_host" "bastion" {
  for_each              = local.recreate_bastion
  name                  = "shared-bastion"
  location              = var.location
  resource_group_name   = var.target_infra_rg
  sku                   = "Basic"

  ip_configuration {
    name                  = "configuration"
    subnet_id             = azurerm_subnet.subnet-bastion.id
    public_ip_address_id  = azurerm_public_ip.bastion.id
  }

  lifecycle {
    prevent_destroy         = true
    create_before_destroy   = true
  }
}
