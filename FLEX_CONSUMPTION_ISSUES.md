# Troubleshooting Flex Consumption Function Apps

## Current Issue
3 out of 4 Function Apps are not working properly on Flex Consumption (preview) SKU:
- **dc-add (JavaScript)**: 500 Internal Server Error
- **dc-multiply (C#)**: 503 Service Unavailable / No functions registered
- **dc-divide (Go)**: 404 Not Found

Only **dc-subtract (Python)** is working correctly.

## Root Cause
Azure Flex Consumption is a **preview SKU** with limited runtime support and different deployment requirements compared to standard Consumption plans. The SKU has:
- Limited Kudu API access (can't debug easily)
- Different app settings requirements
- Runtime-specific compatibility issues
- Limited tooling support

## Recommended Solutions

### Option 1: Recreate Function Apps on Standard Consumption Plan (RECOMMENDED)

The standard Consumption plan has full support for all runtimes and better tooling.

#### Steps:
1. Delete existing Function Apps (or create new ones with different names)
2. Create new Function Apps with Consumption (Y1) plan:

```powershell
# Create new Function Apps on standard Consumption plan
$rg = "rg-dcalc"
$location = "westus2"
$storage = "stdcalcstorage"  # Must be globally unique

# Create storage account if needed
az storage account create --name $storage --location $location --resource-group $rg --sku Standard_LRS

# Create Function Apps with standard Consumption plan
az functionapp create --name dc-add-v2 --storage-account $storage --consumption-plan-location $location `
  --resource-group $rg --functions-version 4 --runtime node --runtime-version 18 --os-type Linux

az functionapp create --name dc-subtract-v2 --storage-account $storage --consumption-plan-location $location `
  --resource-group $rg --functions-version 4 --runtime python --runtime-version 3.9 --os-type Linux

az functionapp create --name dc-multiply-v2 --storage-account $storage --consumption-plan-location $location `
  --resource-group $rg --functions-version 4 --runtime dotnet --runtime-version 6.0 --os-type Linux

# Note: Go is not officially supported on Azure Functions, requires custom handlers
```

3. Update GitHub Secrets with new app names
4. Redeploy via GitHub Actions

### Option 2: Fix Individual Runtime Issues on Flex

#### JavaScript (dc-add) - 500 Error
**Issue**: Flex Consumption may not be properly initializing Node.js runtime

**Potential fixes**:
- Ensure `package.json` and `node_modules` are included in deployment
- Try deploying with `--build-remote true` flag
- Check if Functions runtime version matches Node version

#### C# (dc-multiply) - No functions registered
**Issue**: .azurefunctions metadata not recognized or .NET runtime not starting

**Potential fixes**:
- The manually created `.azurefunctions` directory may not be valid for Flex
- Try deploying source code with `--build-remote true` instead of pre-built
- Verify .NET 6.0 is supported on Flex Consumption

#### Go (dc-divide) - 404 Not Found
**Issue**: Go is not officially supported on Azure Functions, requires custom handlers

**Status**: Custom handlers may not work properly on Flex Consumption preview
**Workaround**: May need to wait for Flex Consumption GA or use standard plan

### Option 3: Use Container-based Deployment

For full control over runtimes (especially Go), use Azure Functions on Docker containers:

```powershell
# Create container-based Function Apps
az functionapp create --name dc-divide-container --storage-account $storage `
  --resource-group $rg --plan <premium-plan-name> --deployment-container-image-name <your-go-image>
```

## Immediate Action Required

Choose one of the options above. **Option 1 (Standard Consumption Plan) is strongly recommended** because:
- ✅ Proven, stable runtime support
- ✅ Full Kudu API access for debugging
- ✅ Better Azure CLI/Portal tooling
- ✅ Extensive documentation and community support
- ✅ Same cost model as Flex (pay per execution)

The CI/CD pipeline is working correctly - the issue is purely with the Flex Consumption SKU's preview limitations.
