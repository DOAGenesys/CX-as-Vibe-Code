terraform {
  required_providers {
    genesyscloud = {
      source  = "mypurecloud/genesyscloud"
      version = "~> 1.79.0"
    }
  }
}

provider "genesyscloud" {}

resource "genesyscloud_user" "vibe_user" {
  email = "vibe@email.com"
  name  = "vibe_user"
  state = "active"
}

resource "genesyscloud_routing_queue" "vibe_queue" {
  name = "vibe_queue"

  members {
    user_id  = genesyscloud_user.vibe_user.id
    ring_num = 1
  }
}
