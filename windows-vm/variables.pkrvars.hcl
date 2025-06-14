# GCP Configuration
project_id           = "your-gcp-project-id"  # Update this with your actual project ID
zone                = "us-central1-a"
source_image_family = "windows-2019"
source_image_project = "windows-cloud"

# VM Configuration
machine_type = "n1-standard-4"
disk_size    = "100"

# Image Configuration
image_name        = "windows-commando-vm"
image_description = "Windows VM with Commando VM tools for security research"

# Optional: Advanced Configuration
# Uncomment and modify these if needed

# Alternative zones (uncomment one if you prefer a different zone)
# zone = "us-west1-b"
# zone = "europe-west1-b"
# zone = "asia-southeast1-a"

# Alternative Windows versions (uncomment if you want a different version)
# source_image_family = "windows-2022"
# source_image_family = "windows-2016"

# Alternative machine types (uncomment if you want different specs)
# machine_type = "n1-standard-2"   # Less powerful, cheaper
# machine_type = "n1-standard-8"   # More powerful, more expensive
# machine_type = "c2-standard-4"   # Compute-optimized
# machine_type = "n2-standard-4"   # Newer generation

# Larger disk if you need more space for tools and samples
# disk_size = "200"