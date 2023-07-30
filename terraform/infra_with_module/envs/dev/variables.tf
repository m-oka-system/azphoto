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
  type = map(object({
    name                                      = string
    target_vnet                               = string
    address_prefixes                          = list(string)
    private_endpoint_network_policies_enabled = bool
    service_delegation = object({
      name    = string
      actions = list(string)
    })
  }))
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
      service_delegation                        = null
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
    vm = {
      name                                      = "vm"
      target_vnet                               = "spoke1"
      address_prefixes                          = ["10.10.4.0/24"]
      private_endpoint_network_policies_enabled = false
      service_delegation                        = null
    }
  }
}

variable "dns" {
  type = map(map(string))
  default = {
    app = {
      dns_zone_name           = "example.com"
      custom_domain_host_name = "www"
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

variable "keyvault" {
  type = map(object({
    name                       = string
    sku_name                   = string
    enable_rbac_authorization  = bool
    purge_protection_enabled   = bool
    soft_delete_retention_days = number
    network_acls = object({
      default_action             = string
      bypass                     = string
      ip_rules                   = list(string)
      virtual_network_subnet_ids = list(string)
    })
  }))
  default = {
    app = {
      name                       = "app"
      sku_name                   = "standard"
      enable_rbac_authorization  = true
      purge_protection_enabled   = false
      soft_delete_retention_days = 7
      network_acls = {
        default_action             = "Deny"
        bypass                     = "AzureServices"
        ip_rules                   = ["100.0.0.1"]
        virtual_network_subnet_ids = []
      }
    }
  }
}

variable "mysql" {
  type = map(object({
    name                         = string
    target_vnet                  = string
    target_subnet                = string
    db_username                  = string
    db_password                  = string
    db_size                      = string
    version                      = string
    zone                         = string
    backup_retention_days        = number
    geo_redundant_backup_enabled = bool
    storage = object({
      auto_grow_enabled = bool
      iops              = number
      size_gb           = number
    })
  }))
  default = {
    app = {
      name                         = "mysql"
      target_vnet                  = "spoke1"
      target_subnet                = "db"
      db_username                  = "db_username"
      db_password                  = "db_password"
      db_size                      = "B_Standard_B1s"
      version                      = "8.0.21"
      zone                         = "1"
      backup_retention_days        = 7
      geo_redundant_backup_enabled = false
      storage = {
        auto_grow_enabled = true
        iops              = 360
        size_gb           = 20
      }
    }
  }
}

variable "database" {
  type = map(map(string))
  default = {
    app = {
      name                = "MyDatabase"
      target_mysql_server = "app"
      charset             = "utf8mb4"
      collation           = "utf8mb4_0900_ai_ci"
    }
  }
}

variable "vm" {
  default = {
    jumpbox = {
      name              = "linux-vm"
      target_subnet     = "vm"
      vm_size           = "Standard_DS1_v2"
      vm_admin_username = "azureuser"
      os_disk_cache     = "ReadWrite"
      os_disk_type      = "Standard_LRS"
      os_disk_size      = 30
      source_image_reference = {
        offer     = "0001-com-ubuntu-server-focal"
        publisher = "canonical"
        sku       = "20_04-lts-gen2"
        version   = "latest"
      }
      public_ip = {
        sku               = "Standard"
        allocation_method = "Static"
        zones             = ["1", "2", "3"]
      }
    }
  }
}

variable "container_registry" {
  type = map(object({
    sku_name                      = string
    admin_enabled                 = bool
    public_network_access_enabled = bool
    zone_redundancy_enabled       = bool
  }))
  default = {
    app = {
      sku_name                      = "Basic"
      admin_enabled                 = false
      public_network_access_enabled = true
      zone_redundancy_enabled       = false
    }
  }
}

variable "app_service" {
  type = map(object({
    name          = string
    os_type       = string
    sku_name      = string
    target_subnet = string
    https_only    = bool
    site_config = object({
      always_on              = bool
      ftps_state             = string
      vnet_route_all_enabled = bool
    })
  }))
  default = {
    app = {
      name          = "app"
      os_type       = "Linux"
      sku_name      = "B1"
      target_subnet = "app"
      https_only    = true
      site_config = {
        always_on              = false
        ftps_state             = "Disabled"
        vnet_route_all_enabled = true
      }
    }
  }
}

variable "frontdoor" {
  default = {
    app = {
      name                     = "app"
      sku_name                 = "Standard_AzureFrontDoor"
      response_timeout_seconds = 60
    }
  }
}

variable "frontdoor_endpoint" {
  default = {
    app = {
      name                     = "app"
      target_frontdoor_profile = "app"
    }
  }
}

variable "frontdoor_origin_group" {
  default = {
    app = {
      name                                                      = "app"
      target_frontdoor_profile                                  = "app"
      session_affinity_enabled                                  = false
      restore_traffic_time_to_healed_or_new_endpoint_in_minutes = 0
      health_probe = {
        interval_in_seconds = 100
        path                = "/"
        protocol            = "Https"
        request_type        = "HEAD"
      }
      load_balancing = {
        additional_latency_in_milliseconds = 50
        sample_size                        = 4
        successful_samples_required        = 3
      }
    }
  }
}

variable "frontdoor_origin" {
  default = {
    app = {
      name                           = "app"
      target_frontdoor_origin_group  = "app"
      target_app_service             = "app"
      certificate_name_check_enabled = true
      http_port                      = 80
      https_port                     = 443
      priority                       = 1
      weight                         = 1000
    }
  }
}

variable "frontdoor_route" {
  default = {
    app = {
      name                          = "app"
      target_frontdoor_endpoint     = "app"
      target_frontdoor_origin_group = "app"
      target_frontdoor_origin       = "app"
      forwarding_protocol           = "HttpsOnly"
      https_redirect_enabled        = true
      patterns_to_match             = ["/*"]
      supported_protocols           = ["Http", "Https"]
      link_to_default_domain        = true
    }
  }
}
