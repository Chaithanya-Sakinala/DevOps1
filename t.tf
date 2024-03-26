provider "azurerm" {
 client_secret = "CVA8Q~Ebh1C4bWo4oXMsjcg6d~zWDXLVwT~YOb7Z"
 client_id = "dfaf16ee-2f06-4643-84e7-bbdc43850f87"
 tenant_id = "15fae2f6-4d4b-4382-a2a5-89478e38a20e"
 subscription_id = "f74be4c1-1825-4911-a360-a1b108e5f285"
  features {}
}

data "azurerm_resource_group" "main" {
    name = "chaithanya-rg"
}

output "id" {
      value = data.azurerm_resource_group.main.id
}

data "azurerm_image" "main" {
     name = "ubuntu-jammy-1711042543"
     resource_group_name = "chaithanya-rg"
}

output "image_id" {
    value = "/subscriptions/f74be4c1-1825-4911-a360-a1b108e5f285/resourceGroups/chaithanya-rg/providers/Microsoft.Compute/images/ubuntu-jammy-1711042543"
}

resource "azurerm_virtual_network" "vnet" {
  name = "vnet"
  location = "Central US"
  address_space = ["10.0.0.0/16"]
  resource_group_name = "chaithanya-rg"

}


resource "azurerm_subnet" "subnet" {
  name = "vmsubnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = "chaithanya-rg"
  address_prefixes = ["10.0.10.0/24"]
}
resource "azurerm_network_interface" "nic" {
  name = "vm-nic"
  location = "Central US"
  resource_group_name = "chaithanya-rg"
  ip_configuration {
    name = "vmipconfig"
    subnet_id = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}

resource "azurerm_public_ip" "pip" {
  name = "pipip"
  location = "Central US"
  resource_group_name = "chaithanya-rg"
  allocation_method = "Dynamic"
}
resource "azurerm_linux_virtual_machine" "vm" {
  name = "LinuxVm"
  location = "Central US"
  resource_group_name = "chaithanya-rg"
  network_interface_ids = [azurerm_network_interface.nic.id]
  size = "Standard_DS1_v2"
  os_disk {
    name = "vmOsDisk"
    caching = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
  admin_username = "azureadmin"
  admin_password = "Tomorrow@123"
  disable_password_authentication = "false"
     /* source_image_reference {
    publisher = "Canonical"
    offer = "0001-com-ubuntu-server-jammy"
    sku = "22_04-lts"
    version = "latest"
  }  */

source_image_id = data.azurerm_image.main.id

custom_data = base64encode(data.template_file.init.rendered)
}
data "template_file" "init" {
  template = file("bootstrap.sh")
}
