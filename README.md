# faasd for Microsoft Azure

This repo contains a Terraform Module for how to deploy a [faasd](https://github.com/openfaas/faasd) instance on
[Microsoft Azure](https://azure.microsoft.com/) using [Terraform](https://www.terraform.io/).

__faasd__, a lightweight & portable faas engine, is [OpenFaaS](https://github.com/openfaas/) reimagined, but without the cost and complexity of Kubernetes. It runs on a single host with very modest requirements, making it fast and easy to manage. Under the hood it uses [containerd](https://containerd.io/) and [Container Networking Interface (CNI)](https://github.com/containernetworking/cni) along with the same core OpenFaaS components from the main project.

## What's a Terraform Module?

A Terraform Module refers to a self-contained packages of Terraform configurations that are managed as a group. This repo
is a Terraform Module and contains many "submodules" which can be composed together to create useful infrastructure patterns.

## How do you use this module?

This repository defines a [Terraform module](https://www.terraform.io/docs/modules/usage.html), which you can use in your
code by adding a `module` configuration and setting its `source` parameter to URL of this repository:

```hcl
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "faasd" {
  name     = "FaasdResources"
  location = "West Europe"
}

resource "azurerm_virtual_network" "faasd" {
  name                = "FaasdNetwork"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.faasd.location
  resource_group_name = azurerm_resource_group.faasd.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.faasd.name
  virtual_network_name = azurerm_virtual_network.faasd.name
  address_prefixes     = ["10.0.2.0/24"]
}

module "faasd" {
  source = "github.com/jsiebens/terraform-azurerm-faasd"
  
  name                = "faasd"
  resource_group_name = azurerm_resource_group.faasd.name
  location            = azurerm_resource_group.faasd.location
  subnet_id           = azurerm_subnet.internal.id
  public_key          = file("~/.ssh/id_rsa.pub")
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| azurerm | >= 2.50.0 |
| random | >= 3.1.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 2.50.0 |
| random | >= 3.1.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_linux_virtual_machine.faasd](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | resource |
| [azurerm_network_interface.faasd](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface_security_group_association.faasd](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | resource |
| [azurerm_network_security_group.faasd](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_public_ip.faasd](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [random_password.faasd](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| admin\_username | The username of the local administrator used for the Virtual Machine. | `string` | `"adminuser"` | no |
| basic\_auth\_password | The basic auth password, if left empty, a random password is generated. | `string` | `null` | no |
| basic\_auth\_user | The basic auth user name. | `string` | `"admin"` | no |
| domain | A public domain for the faasd instance. This will the use of Caddy and a Let's Encrypt certificate | `string` | `""` | no |
| email | Email used to order a certificate from Let's Encrypt | `string` | `""` | no |
| location | Specifies the supported Azure location in which to create the resources. | `string` | n/a | yes |
| name | The name of the faasd instance. All resources will be namespaced by this value. | `string` | n/a | yes |
| public\_key | The Public Key which should be used for authentication, which needs to be at least 2048-bit and in `ssh-rsa` format. | `string` | n/a | yes |
| resource\_group\_name | The name of the resource group in which to create the resources. | `string` | n/a | yes |
| size | The SKU which should be used for this Virtual Machine, such as `Standard_B1ms`. | `string` | `"Standard_B1ms"` | no |
| subnet\_id | The ID of the Subnet where the Network Interface should be located in. | `string` | n/a | yes |
| tags | A mapping of tags which should be assigned to the resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| basic\_auth\_password | The basic auth password. |
| basic\_auth\_user | The basic auth user name. |
| gateway\_url | The url of the faasd gateway |
| ipv4\_address | The public IP address of the faasd instance |
<!-- END_TF_DOCS -->

## See Also

- [faasd on Google Cloud Platform with Terraform](https://github.com/jsiebens/terraform-google-faasd)
- [faasd on Microsoft Azure with Terraform](https://github.com/jsiebens/terraform-azurerm-faasd)
- [faasd on DigitalOcean with Terraform](https://github.com/jsiebens/terraform-digitalocean-faasd)
- [faasd on Equinix Metal with Terraform](https://github.com/jsiebens/terraform-equinix-faasd)
- [faasd on Scaleway with Terraform](https://github.com/jsiebens/terraform-scaleway-faasd)
