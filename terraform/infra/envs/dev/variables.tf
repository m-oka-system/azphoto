variable "common" {
  type = map(string)
  default = {
    prefix   = "azphoto"
    env      = "dev"
    location = "japaneast"
  }
}

variable "allowed_cidr" {
  type = string
}

variable "secret_key" {
  type = string
}

variable "sendgrid_api_key" {
  type = string
}

variable "default_from_email" {
  type = string
}

variable "django_app" {
  type = map(string)
  default = {
    websites_enable_app_service_storage = "False"
    websites_port                       = "8000"
    django_settings_module              = "config.settings.production"
    django_secure_ssl_redirect          = "False"
    django_debug                        = "False"
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

variable "network_security_group" {
  type = map(object({
    name          = string
    target_subnet = string
    security_rule = list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = string
      destination_port_range     = string
      source_address_prefix      = optional(string)
      source_address_prefixes    = optional(list(string))
      destination_address_prefix = string
    }))
  }))
  default = {
    app = {
      name          = "app"
      target_subnet = "app"
      security_rule = []
    }
    pe = {
      name          = "pe"
      target_subnet = "pe"
      security_rule = []
    }
    db = {
      name          = "db"
      target_subnet = "db"
      security_rule = []
    }
    vm = {
      name          = "vm"
      target_subnet = "vm"
      security_rule = [
        {
          name                       = "AllowMyIpAddressHTTPInbound"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "80"
          source_address_prefixes    = ["MyIP"]
          destination_address_prefix = "*"
        },
        {
          name                       = "AllowMyIpAddressHTTPSInbound"
          priority                   = 110
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefixes    = ["MyIP"]
          destination_address_prefix = "*"
        },
        {
          name                       = "AllowMyIpAddressSSHInbound"
          priority                   = 120
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefixes    = ["MyIP"]
          destination_address_prefix = "*"
        },
        {
          name                       = "AllowMyIpAddressRDPInbound"
          priority                   = 130
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "3389"
          source_address_prefixes    = ["MyIP"]
          destination_address_prefix = "*"
        }
      ]
    }
  }
}

variable "dns" {
  type = map(map(string))
  default = {
    app = {
      dns_zone_name = "azphoto.xyz"
      subdomain     = "www"
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
        ip_rules                   = ["MyIP"]
        virtual_network_subnet_ids = []
      }
    }
  }
}

variable "blob_container" {
  type = map(map(string))
  default = {
    app_static = {
      storage_account_key   = "app"
      container_name        = "static"
      container_access_type = "blob"
    }
    app_media = {
      storage_account_key   = "app"
      container_name        = "media"
      container_access_type = "blob"
    }
    log = {
      storage_account_key   = "log"
      container_name        = "log"
      container_access_type = "private"
    }
  }
}

variable "key_vault" {
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
        ip_rules                   = ["MyIP"]
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
    db_port                      = number
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
      db_port                      = 3306
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

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}

variable "database" {
  type = map(map(string))
  default = {
    app = {
      name                = "photo"
      target_mysql_server = "app"
      charset             = "utf8mb4"
      collation           = "utf8mb4_0900_ai_ci"
    }
  }
}

variable "redis" {
  type = map(object({
    name                          = string
    sku_name                      = string
    family                        = string
    redis_port                    = number
    capacity                      = number
    redis_version                 = number
    public_network_access_enabled = bool
    enable_non_ssl_port           = bool
    minimum_tls_version           = string
  }))
  default = {
    app = {
      name                          = "redis"
      sku_name                      = "Basic"
      family                        = "C"
      redis_port                    = 6380
      capacity                      = 0
      redis_version                 = 6
      public_network_access_enabled = false
      enable_non_ssl_port           = false
      minimum_tls_version           = "1.2"
    }
  }
}

variable "private_dns_zone" {
  type = map(string)
  default = {
    blob      = "privatelink.blob.core.windows.net"
    key_vault = "privatelink.vaultcore.azure.net"
    redis     = "privatelink.redis.cache.windows.net"
  }
}

variable "vm" {
  type = map(object({
    name          = string
    target_subnet = string
    vm_size       = string
    os_disk_cache = string
    os_disk_type  = string
    os_disk_size  = number
    source_image_reference = object({
      offer     = string
      publisher = string
      sku       = string
      version   = string
    })
    public_ip = object({
      sku               = string
      allocation_method = string
      zones             = list(string)
    })
  }))
  default = {
    jumpbox = {
      name          = "linux-vm"
      target_subnet = "vm"
      vm_size       = "Standard_DS1_v2"
      os_disk_cache = "ReadWrite"
      os_disk_type  = "Standard_LRS"
      os_disk_size  = 30
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

variable "vm_admin_username" {
  type = string
}

variable "public_key" {
  type = string
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

variable "service_plan" {
  type = map(map(string))
  default = {
    app = {
      name     = "app"
      os_type  = "Linux"
      sku_name = "B1"
    }
  }
}

variable "app_service" {
  type = map(object({
    name                          = string
    target_service_plan           = string
    target_subnet                 = string
    target_user_assigned_identity = string
    target_frontdoor_profile      = string
    https_only                    = bool
    public_network_access_enabled = bool
    site_config = object({
      always_on              = bool
      ftps_state             = string
      vnet_route_all_enabled = bool
    })
    ip_restriction = map(object({
      name        = string
      priority    = number
      action      = string
      ip_address  = string
      service_tag = string
    }))
    scm_ip_restriction = map(object({
      name        = string
      priority    = number
      action      = string
      ip_address  = string
      service_tag = string
    }))
  }))
  default = {
    app = {
      name                          = "app"
      target_service_plan           = "app"
      target_subnet                 = "app"
      target_user_assigned_identity = "app"
      target_frontdoor_profile      = "app"
      https_only                    = true
      public_network_access_enabled = true
      site_config = {
        always_on              = false
        ftps_state             = "Disabled"
        vnet_route_all_enabled = true
      }
      ip_restriction = {
        frontdoor = {
          name        = "AllowFrontDoor"
          priority    = 100
          action      = "Allow"
          ip_address  = null
          service_tag = "AzureFrontDoor.Backend"
        }
        myip = {
          name        = "AllowMyIP"
          priority    = 200
          action      = "Allow"
          ip_address  = "MyIP"
          service_tag = null
        }
      }
      scm_ip_restriction = {
        devops = {
          name        = "AllowDevOps"
          priority    = 100
          action      = "Allow"
          ip_address  = null
          service_tag = "AzureCloud"
        }
        myip = {
          name        = "AllowMyIP"
          priority    = 200
          action      = "Allow"
          ip_address  = "MyIP"
          service_tag = null
        }
      }
    }
  }
}

variable "frontdoor_profile" {
  type = map(object({
    name                     = string
    sku_name                 = string
    response_timeout_seconds = number
  }))
  default = {
    app = {
      name                     = "app"
      sku_name                 = "Standard_AzureFrontDoor"
      response_timeout_seconds = 60
    }
  }
}

variable "frontdoor_endpoint" {
  type = map(object({
    name                     = string
    target_frontdoor_profile = string
  }))
  default = {
    app = {
      name                     = "app"
      target_frontdoor_profile = "app"
    }
  }
}

variable "frontdoor_origin_group" {
  type = map(object({
    name                                                      = string
    target_frontdoor_profile                                  = string
    session_affinity_enabled                                  = bool
    restore_traffic_time_to_healed_or_new_endpoint_in_minutes = number
    health_probe = object({
      interval_in_seconds = number
      path                = string
      protocol            = string
      request_type        = string
    })
    load_balancing = object({
      additional_latency_in_milliseconds = number
      sample_size                        = number
      successful_samples_required        = number
    })
  }))
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
    blob = {
      name                                                      = "blob"
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
  type = map(object({
    name                           = string
    target_frontdoor_origin_group  = string
    target_backend_origin          = string
    certificate_name_check_enabled = bool
    http_port                      = number
    https_port                     = number
    priority                       = number
    weight                         = number
  }))
  default = {
    app = {
      name                           = "app"
      target_frontdoor_origin_group  = "app"
      target_backend_origin          = "app"
      certificate_name_check_enabled = true
      http_port                      = 80
      https_port                     = 443
      priority                       = 1
      weight                         = 1000
    }
    blob = {
      name                           = "blob"
      target_frontdoor_origin_group  = "blob"
      target_backend_origin          = "blob"
      certificate_name_check_enabled = true
      http_port                      = 80
      https_port                     = 443
      priority                       = 1
      weight                         = 1000
    }
  }
}

variable "frontdoor_route" {
  type = map(object({
    name                          = string
    target_frontdoor_endpoint     = string
    target_frontdoor_origin_group = string
    target_frontdoor_origin       = string
    target_custom_domain          = string
    forwarding_protocol           = string
    https_redirect_enabled        = bool
    patterns_to_match             = list(string)
    supported_protocols           = list(string)
    link_to_default_domain        = bool
    cache = object({
      compression_enabled           = bool
      query_string_caching_behavior = string
      query_strings                 = list(string)
      content_types_to_compress     = list(string)
    })
  }))
  default = {
    app = {
      name                          = "app"
      target_frontdoor_endpoint     = "app"
      target_frontdoor_origin_group = "app"
      target_frontdoor_origin       = "app"
      target_custom_domain          = "app"
      forwarding_protocol           = "HttpsOnly"
      https_redirect_enabled        = true
      patterns_to_match             = ["/*"]
      supported_protocols           = ["Http", "Https"]
      link_to_default_domain        = true
      cache                         = null
    }
    blob = {
      name                          = "blob"
      target_frontdoor_endpoint     = "app"
      target_frontdoor_origin_group = "blob"
      target_frontdoor_origin       = "blob"
      target_custom_domain          = "app"
      forwarding_protocol           = "HttpsOnly"
      https_redirect_enabled        = true
      patterns_to_match             = ["/media/*", "/static/*"]
      supported_protocols           = ["Http", "Https"]
      link_to_default_domain        = true
      cache = {
        compression_enabled           = true
        query_string_caching_behavior = "IgnoreQueryString"
        query_strings                 = []
        content_types_to_compress     = ["text/html", "text/css", "text/javascript"]
      }
    }
  }
}

variable "frontdoor_firewall_policy" {
  type = map(object({
    name                              = string
    sku_name                          = string
    mode                              = string
    custom_block_response_status_code = number
  }))
  default = {
    app = {
      name                              = "IPRestrictionPolicy"
      sku_name                          = "Standard_AzureFrontDoor"
      mode                              = "Prevention"
      custom_block_response_status_code = 403
    }
  }
}

variable "frontdoor_firewall_custom_rule" {
  type = map(object({
    rule_name    = string
    priority     = number
    match_values = list(string)
  }))
  default = {
    clientip = {
      rule_name    = "AllowClientIP"
      priority     = 100
      match_values = ["MyIP"]
    }
  }
}

variable "frontdoor_security_policy" {
  type = map(object({
    name                     = string
    target_frontdoor_profile = string
    target_firewall_policy   = string
  }))
  default = {
    app = {
      name                     = "app"
      target_frontdoor_profile = "app"
      target_firewall_policy   = "app"
    }
  }
}

variable "user_assigned_identity" {
  type = map(object({
    name = string
  }))
  default = {
    app = {
      name = "app"
    }
  }
}

variable "role_assignment" {
  type = map(object({
    target_identity      = string
    role_definition_name = string
  }))
  default = {
    app_acr_pull = {
      target_identity      = "app"
      role_definition_name = "AcrPull"
    }
    app_key_vault_secrets_user = {
      target_identity      = "app"
      role_definition_name = "Key Vault Secrets User"
    }
    app_storage_blob_data_contributor = {
      target_identity      = "app"
      role_definition_name = "Storage Blob Data Contributor"
    }
  }
}

variable "log_analytics" {
  type = map(object({
    sku               = string
    retention_in_days = number
  }))
  default = {
    logs = {
      sku               = "PerGB2018"
      retention_in_days = 30
    }
  }
}

variable "application_insights" {
  type = map(object({
    name              = string
    application_type  = string
    target_workspace  = string
    retention_in_days = number
  }))
  default = {
    app = {
      name              = "app"
      target_workspace  = "logs"
      application_type  = "web"
      retention_in_days = 90
    }
  }
}

variable "microsoft_teams" {
  type = map(string)
}

variable "action_group" {
  type = object({
    receiver_name           = string
    use_common_alert_schema = bool
  })
  default = {
    receiver_name           = "teams-notify"
    use_common_alert_schema = true
  }
}
