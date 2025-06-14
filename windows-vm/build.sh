#!/bin/bash

# Build script for Windows Commando VM on GCP with separated variables
# Make sure you have the following prerequisites:

echo "=== Windows Commando VM Packer Build Script ==="

# Check if scripts directory exists
if [ ! -d "scripts" ]; then
    echo "Error: scripts directory not found."
    echo "Please ensure the following files exist:"
    echo "  scripts/01-initial-setup.ps1"
    echo "  scripts/02-download-commando-vm.ps1"  
    echo "  scripts/03-install-commando-vm.ps1"
    echo "  scripts/04-additional-tools.ps1"
    echo "  scripts/05-final-config.ps1"
    exit 1
fi

# Verify all required script files exist
required_scripts=(
    "scripts/01-initial-setup.ps1"
    "scripts/02-download-commando-vm.ps1"
    "scripts/03-install-commando-vm.ps1"
    "scripts/04-additional-tools.ps1"
    "scripts/05-final-config.ps1"
)

for script in "${required_scripts[@]}"; do
    if [ ! -f "$script" ]; then
        echo "Error: Required script not found: $script"
        exit 1
    fi
done

echo "✓ All required script files found"

# Load environment variables if .env file exists
if [ -f ".env" ]; then
    echo "Loading environment variables from .env file..."
    source .env
fi

# Check prerequisites
echo "Checking prerequisites..."

# Check if Packer is installed
if ! command -v packer &> /dev/null; then
    echo "Error: Packer is not installed. Please install Packer first."
    echo "Visit: https://www.packer.io/downloads"
    exit 1
fi

# Check if gcloud is installed and authenticated
if ! command -v gcloud &> /dev/null; then
    echo "Error: Google Cloud SDK is not installed."
    echo "Visit: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Check if authenticated
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n 1 &> /dev/null; then
    echo "Error: Not authenticated with Google Cloud."
    echo "Run: gcloud auth login"
    exit 1
fi

# Set required environment variables
if [ -z "$GCP_PROJECT_ID" ]; then
    export GCP_PROJECT_ID=$(gcloud config get-value project)
fi

if [ -z "$GCP_PROJECT_ID" ]; then
    echo "Error: GCP Project ID not set."
    echo "Either:"
    echo "  1. Set it in .env file: export GCP_PROJECT_ID=\"your-project-id\""
    echo "  2. Run: gcloud config set project YOUR_PROJECT_ID"
    echo "  3. Set environment variable: export GCP_PROJECT_ID=\"your-project-id\""
    exit 1
fi

echo "Using GCP Project: $GCP_PROJECT_ID"

# Update variables file with project ID if needed
if grep -q "your-gcp-project-id" variables.pkrvars.hcl; then
    echo "Updating project ID in variables.pkrvars.hcl..."
    sed -i.bak "s/your-gcp-project-id/$GCP_PROJECT_ID/g" variables.pkrvars.hcl
    echo "Updated variables file (backup saved as variables.pkrvars.hcl.bak)"
fi

# Enable required APIs
echo "Enabling required GCP APIs..."
gcloud services enable compute.googleapis.com
gcloud services enable oslogin.googleapis.com

# Initialize Packer (download required plugins)
echo "Initializing Packer plugins..."
packer init windows-commando-vm.pkr.hcl

# Validate Packer template with variables file
echo "Validating Packer template with variables..."
packer validate -var-file="variables.pkrvars.hcl" windows-commando-vm.pkr.hcl

if [ $? -ne 0 ]; then
    echo "Error: Packer template validation failed."
    exit 1
fi

# Build the image with variables file
echo "Starting Packer build with variables file..."
echo "This process will take 30-60 minutes depending on internet speed and VM performance."

packer build -var-file="variables.pkrvars.hcl" windows-commando-vm.pkr.hcl

if [ $? -eq 0 ]; then
    echo "=== BUILD SUCCESSFUL ==="
    echo "Your Windows Commando VM image has been created successfully!"
    echo "Image name: windows-commando-vm-$(date +%Y-%m-%d-%H%M)"
    echo ""
    echo "To create a VM instance from this image:"
    echo "gcloud compute instances create commando-vm-instance \\"
    echo "  --image-family=windows-commando-vm \\"
    echo "  --image-project=$GCP_PROJECT_ID \\"
    echo "  --machine-type=n1-standard-4 \\"
    echo "  --zone=us-central1-a \\"
    echo "  --boot-disk-size=100GB \\"
    echo "  --metadata=enable-oslogin=TRUE"
    echo ""
    echo "Build manifest saved to: windows-commando-vm-manifest.json"
else
    echo "=== BUILD FAILED ==="
    echo "Check the logs above for error details."
    exit 1
fi