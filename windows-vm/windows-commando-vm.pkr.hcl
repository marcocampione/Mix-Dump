packer {
  required_plugins {
    googlecompute = {
      source  = "github.com/hashicorp/googlecompute"
      version = "~> 1"
    }
  }
}

# Variable declarations - values are defined in variables.pkrvars.hcl
variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "zone" {
  type        = string
  description = "GCP Zone"
}

variable "source_image_family" {
  type        = string
  description = "Source image family"
}

variable "source_image_project" {
  type        = string
  description = "Source image project"
}

variable "machine_type" {
  type        = string
  description = "Machine type"
}

variable "disk_size" {
  type        = string
  description = "Boot disk size in GB"
}

variable "image_name" {
  type        = string
  description = "Base name of the output image"
}

variable "image_description" {
  type        = string
  description = "Description of the output image"
}

source "googlecompute" "windows_commando" {
  project_id              = var.project_id
  zone                    = var.zone
  source_image_family     = var.source_image_family
  source_image_project    = var.source_image_project
  machine_type            = var.machine_type
  disk_size               = var.disk_size
  image_name              = "${var.image_name}-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  image_description       = var.image_description
  image_family            = "windows-commando-vm"
  
  # WinRM Configuration
  communicator            = "winrm"
  winrm_username          = "packer"
  winrm_use_ssl           = true
  winrm_insecure          = true
  winrm_timeout           = "15m"
  
  # Metadata for OS Login and startup script
  metadata = {
    enable-oslogin = "TRUE"
    windows-startup-script-ps1 = <<-EOT
      Set-ExecutionPolicy Unrestricted -Force
      Enable-PSRemoting -Force
      Set-NetFirewallRule -DisplayName 'Windows Remote Management (HTTP-In)' -Enabled True
      winrm quickconfig -q
      winrm set winrm/config/service '@{AllowUnencrypted="true"}'
      winrm set winrm/config/service/auth '@{Basic="true"}'
      winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="2048"}'
      Restart-Service winrm
      netsh advfirewall firewall set rule name='Windows Remote Management (HTTP-In)' new enable=yes
      $Password = ConvertTo-SecureString -AsPlainText 'PackerPassword123!' -Force
      New-LocalUser -Name 'packer' -Password $Password -PasswordNeverExpires
      Add-LocalGroupMember -Group 'Administrators' -Member 'packer'
    EOT
  }
  
  # Network and security settings
  tags = ["packer", "security-research", "commando-vm"]
  
  # Enable nested virtualization if needed for advanced analysis
  enable_nested_virtualization = false
  
  # Use SSD for better performance
  disk_type = "pd-ssd"
}

build {
  name = "windows-commando-vm"
  sources = ["source.googlecompute.windows_commando"]
  
  # Initial Windows configuration
  provisioner "powershell" {
    script = "./scripts/01-initial-setup.ps1"
  }
  
  # Download and prepare Commando VM
  provisioner "powershell" {
    script = "./scripts/02-download-commando-vm.ps1"
  }
  
  # Install Commando VM
  provisioner "powershell" {
    script = "./scripts/03-install-commando-vm.ps1"
  }
  
  # Additional security tools and configuration
  provisioner "powershell" {
    script = "./scripts/04-additional-tools.ps1"
  }
  
  # System restart
  provisioner "windows-restart" {
    restart_timeout = "10m"
  }
  
  # Final configuration and cleanup
  provisioner "powershell" {
    script = "./scripts/05-final-config.ps1"
  }
  
  # Generate manifest
  post-processor "manifest" {
    output = "windows-commando-vm-manifest.json"
    strip_path = true
  }
}