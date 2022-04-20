variable "location" {  
    type = string 
    default = "eastus"
}

variable "appname" {  
    type    = string
    default = "appfunctions"
}

variable "appservice_sku" {  
    type = string 
    default = "eastus"
}

variable "ip_block" {  
    type = string 
    default = "0.0.0.0/0"
}

variable "ip_allow" {  
    type = string 
    default = "xxx.xxx.xxx.xxx/xx"
}
