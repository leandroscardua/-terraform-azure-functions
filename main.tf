terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"

    }
  }
}


resource "azurerm_resource_group" "rg" {
  name     = var.appname
  location = var.location
}

resource "azurerm_storage_account" "sa" {
  name                     = var.appname
  resource_group_name      = var.appname
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"



  depends_on = [ azurerm_resource_group.rg ]
}

resource "azurerm_service_plan" "sp" {
  name                = var.appname
  resource_group_name = var.appname
  location            = var.location
  sku_name            = "F1"
  os_type             = "Windows"

  depends_on = [ azurerm_storage_account.sa ]
}

resource "azurerm_windows_function_app" "wfa" {
  name                = var.appname
  resource_group_name = var.appname
  location            = var.location
  storage_account_name = azurerm_storage_account.sa.name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key
  service_plan_id      = azurerm_service_plan.sp.id
  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "powershell"
  }
  site_config {
      always_on         = false
      use_32_bit_worker = true
      ftps_state        = "Disabled"
      scm_use_main_ip_restriction = false
      ip_restriction {
        action      = "Deny"
        ip_address  = var.ip_block
        name        = "internet"
        priority    = 101 
      }
      ip_restriction {
        action      = "Allow"
        ip_address  = var.ip_allow
        name        = "myip"
        priority    = 100
      }

  }

  depends_on = [ azurerm_service_plan.sp ]
}

resource "null_resource" "wfaps" {
  provisioner "local-exec" {
    command = <<-EOT
    az functionapp update --name ${azurerm_windows_function_app.wfa.name} --resource-group ${azurerm_windows_function_app.wfa.resource_group_name} --set siteConfig.powerShellVersion=~7
    EOT
  }
  depends_on = [azurerm_windows_function_app.wfa]
  triggers = {
        build_number = "1"
  }   
}
