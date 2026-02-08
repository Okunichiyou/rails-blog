terraform {
  required_version = ">= 1.14"

  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 3.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
  }
}

# =============================================================================
# Providers
# =============================================================================

provider "openstack" {
  auth_url    = "https://identity.c3j1.conoha.io/v3"
  tenant_name = var.conoha_tenant_name
  user_name   = var.conoha_username
  password    = var.conoha_password
  region      = "c3j1"
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# =============================================================================
# VPS Instance
# =============================================================================

data "openstack_images_image_v2" "ubuntu" {
  name        = "vmi-ubuntu-24.04-amd64"
  most_recent = true
}

resource "openstack_compute_instance_v2" "server" {
  name            = "vm-c0eb9880-dd"
  flavor_name     = "g2l-p-c2m1"
  key_pair        = "rails-blog-ssh-key"
  security_groups = ["IPv4v6-SSH", "IPv4v6-Web"]

  block_device {
    uuid                  = data.openstack_images_image_v2.ubuntu.id
    source_type           = "image"
    destination_type      = "volume"
    volume_size           = 100
    boot_index            = 0
    delete_on_termination = true
  }

  network {
    uuid = "22d5d8ee-3c1c-4fd6-888a-20de824f1516"
  }

  metadata = {
    instance_name_tag = "rails-blog"
  }

  lifecycle {
    ignore_changes = [
      image_id,
    ]
  }
}

# =============================================================================
# Cloudflare DNS
# =============================================================================

resource "cloudflare_dns_record" "app" {
  zone_id = var.cloudflare_zone_id
  name    = "blog"
  content = openstack_compute_instance_v2.server.access_ip_v4
  type    = "A"
  proxied = true
  ttl     = 1
}
