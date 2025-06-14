# Windows ISO Sources and Setup Guide

## Where to Get Windows ISOs

### 1. **Microsoft Official Sources (Recommended)**

#### **Windows 10/11 - Media Creation Tool**
- **URL**: https://www.microsoft.com/software-download/windows10 (or windows11)
- **Pros**: Official, always up-to-date, includes latest updates
- **Cons**: Creates media for current PC architecture only
- **Best for**: Personal use, single architecture builds

#### **Windows 10/11 - Direct ISO Download**
- **URL**: https://www.microsoft.com/software-download/windows10ISO
- **Method**: Use developer tools to change user agent to non-Windows
- **Pros**: Direct ISO download, multiple architectures
- **Cons**: Requires user agent manipulation

#### **Visual Studio Subscriptions (MSDN)**
- **URL**: https://my.visualstudio.com/Downloads
- **Requirements**: Active Visual Studio subscription
- **Pros**: Access to all Windows versions, evaluation versions
- **Cons**: Requires paid subscription

### 2. **Microsoft Evaluation Center**

#### **Windows Server Evaluation**
- **URL**: https://www.microsoft.com/en-us/evalcenter/
- **Available**: Windows Server 2019, 2022, Windows 10/11 Enterprise
- **License**: 180-day evaluation period
- **Pros**: Free, no license key required initially
- **Best for**: Testing, development, security research

### 3. **GCP Pre-built Images (Recommended for Packer)**

Since you're using GCP with Packer, you don't actually need to download ISOs. GCP provides pre-built Windows images:

#### **Available GCP Windows Images**
```bash
# List all available Windows images
gcloud compute images list --project windows-cloud --filter="family:windows*"

# Common families:
- windows-2019        # Windows Server 2019
- windows-2022        # Windows Server 2022  
- windows-2016        # Windows Server 2016
- windows-10-*        # Windows 10 versions
- windows-11-*        # Windows 11 versions
```

## Using GCP Images with Packer (Recommended Approach)

### Benefits of GCP Images
- ✅ No ISO download required
- ✅ Pre-activated and licensed
- ✅ Regular security updates
- ✅ Optimized for cloud deployment
- ✅ Faster build times

### Configuration for Different Windows Versions

#### **Windows Server 2019 (Default in our config)**
```hcl
source_image_family = "windows-2019"
source_image_project = "windows-cloud"
```

#### **Windows Server 2022**
```hcl
source_image_family = "windows-2022"
source_image_project = "windows-cloud"
```

#### **Windows 10 Enterprise**
```hcl
source_image_family = "windows-10-21h2-ent"
source_image_project = "windows-cloud"
```

#### **Windows 11 Enterprise**
```hcl
source_image_family = "windows-11-21h2-ent"
source_image_project = "windows-cloud"
```

## If You Need Custom ISOs

### Legal Requirements
- ✅ Use official Microsoft sources only
- ✅ Ensure proper licensing for your use case
- ✅ Respect evaluation period limitations
- ❌ Never use unofficial or modified ISOs
- ❌ Avoid torrent or unofficial download sites

### For Security Research
1. **Evaluation versions** are perfect for security research
2. **90-180 day** evaluation periods are usually sufficient
3. **No product key** required initially
4. **Can be reset** in some cases for extended testing

## Licensing Considerations

### **Evaluation Use**
- Free for evaluation/testing
- 180 days for Windows Server
- 90 days for Windows desktop versions
- Can often be extended once

### **Development/Research Use**
- Visual Studio subscriptions include Windows licenses
- Academic licenses available through education programs
- Some security research may qualify for NFR (Not For Resale) licenses

### **Production Use**
- Requires proper Windows licenses
- Can use existing Volume License agreements
- GCP Marketplace offers licensed Windows instances

## Recommended Setup for Your Use Case

Since you're doing **security research on GCP**, I recommend:

1. **Use GCP's pre-built Windows images** (already configured in our Packer template)
2. **Start with Windows Server 2019** for broad tool compatibility
3. **Use evaluation licensing** for research purposes
4. **Document your licensing compliance** for your organization

## Quick Start Commands

```bash
# See all available Windows images
gcloud compute images list --project windows-cloud

# Create instance from specific image family
gcloud compute instances create test-windows \
  --image-family=windows-2019 \
  --image-project=windows-cloud \
  --machine-type=n1-standard-2 \
  --zone=us-central1-a

# Use our Packer template (no ISO needed!)
packer build -var-file="variables.pkrvars.hcl" windows-commando-vm.pkr.hcl
```

## Alternative: Using Custom ISOs with Packer

If you absolutely need to use a custom ISO with Packer on GCP, you would need to:

1. Upload ISO to Google Cloud Storage
2. Create a custom image from the ISO
3. Use `iso_url` and `iso_checksum` in Packer config

However, this is more complex and rarely necessary since GCP provides excellent pre-built images.

## Summary

**For your security research project, stick with GCP's pre-built Windows images. They're:**
- Legally compliant
- Pre-licensed for cloud use  
- Regularly updated
- Optimized for performance
- Much faster to deploy

The Packer configuration I provided uses this recommended approach!