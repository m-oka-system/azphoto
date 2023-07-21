variable "common" {
  type = map(string)
  default = {
    prefix   = "prefix"
    env      = "env"
    location = "japaneast"
  }
}

variable "network" {
  type = map(object({
    name          = string
    address_space = list(string)
  }))
  default = {
    spoke1 = {
      name          = "spoke1"
      address_space = ["10.10.0.0/16"]
    }
  }
}

variable "subnet" {
  default = {
    app = {
      name                                      = "app"
      target_vnet                               = "spoke1"
      address_prefixes                          = ["10.10.1.0/24"]
      private_endpoint_network_policies_enabled = false
      service_delegation = {
        name    = "Microsoft.Web/serverFarms"
        actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    }
    pe = {
      name                                      = "pe"
      target_vnet                               = "spoke1"
      address_prefixes                          = ["10.10.2.0/24"]
      private_endpoint_network_policies_enabled = true
      service_delegation                        = {}
    }
    db = {
      name                                      = "db"
      target_vnet                               = "spoke1"
      address_prefixes                          = ["10.10.3.0/24"]
      private_endpoint_network_policies_enabled = false
      service_delegation = {
        name    = "Microsoft.DBforMySQL/flexibleServers"
        actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      }
    }
  }

}

variable "storage" {
  type = map(object({
    name                          = string
    account_tier                  = string
    account_kind                  = string
    account_replication_type      = string
    access_tier                   = string
    enable_https_traffic_only     = bool
    public_network_access_enabled = bool
    is_hns_enabled                = bool
    blob_properties = object({
      versioning_enabled                = bool
      change_feed_enabled               = bool
      last_access_time_enabled          = bool
      delete_retention_policy           = number
      container_delete_retention_policy = number
    })
    network_rules = object({
      default_action             = string
      bypass                     = list(string)
      ip_rules                   = list(string)
      virtual_network_subnet_ids = list(string)
    })
  }))
  default = {
    app = {
      name                          = "app"
      account_tier                  = "Standard"
      account_kind                  = "StorageV2"
      account_replication_type      = "LRS"
      access_tier                   = "Hot"
      enable_https_traffic_only     = true
      public_network_access_enabled = true
      is_hns_enabled                = false
      blob_properties = {
        versioning_enabled                = false
        change_feed_enabled               = false
        last_access_time_enabled          = false
        delete_retention_policy           = 7
        container_delete_retention_policy = 7
      }
      network_rules = {
        default_action             = "Allow"
        bypass                     = ["AzureServices"]
        ip_rules                   = []
        virtual_network_subnet_ids = []
      }
    }
    log = {
      name                          = "log"
      account_tier                  = "Standard"
      account_kind                  = "StorageV2"
      account_replication_type      = "LRS"
      access_tier                   = "Hot"
      enable_https_traffic_only     = true
      public_network_access_enabled = true
      is_hns_enabled                = false
      blob_properties = {
        versioning_enabled                = false
        change_feed_enabled               = false
        last_access_time_enabled          = false
        delete_retention_policy           = 7
        container_delete_retention_policy = 7
      }
      network_rules = {
        default_action             = "Deny"
        bypass                     = ["AzureServices"]
        ip_rules                   = ["100.0.0.1"]
        virtual_network_subnet_ids = []
      }
    }
  }
}

variable "blob_container" {
  type = map(map(string))
  default = {
    app01 = {
      storage_account_key   = "app"
      container_name        = "static"
      container_access_type = "blob"
    }
    app02 = {
      storage_account_key   = "app"
      container_name        = "media"
      container_access_type = "blob"
    }
    log01 = {
      storage_account_key   = "log"
      container_name        = "log"
      container_access_type = "private"
    }
  }
}
