# Script to recreate Function Apps on Standard Consumption Plan
# This replaces the Flex Consumption (preview) apps with production-ready Consumption plan

Write-Host "Creating Standard Consumption Plan Function Apps" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host ""

$rg = "rg-dcalc"
$location = "westus2"
$storageAccount = "stdcalc$(Get-Random -Minimum 1000 -Maximum 9999)"

Write-Host "Configuration:" -ForegroundColor Yellow
Write-Host "  Resource Group: $rg" -ForegroundColor Gray
Write-Host "  Location: $location" -ForegroundColor Gray
Write-Host "  Storage Account: $storageAccount" -ForegroundColor Gray
Write-Host ""

# Step 1: Create storage account
Write-Host "[1/5] Creating storage account..." -ForegroundColor Yellow
az storage account create `
    --name $storageAccount `
    --location $location `
    --resource-group $rg `
    --sku Standard_LRS `
    --kind StorageV2 `
    --output none

if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✅ Storage account created: $storageAccount" -ForegroundColor Green
} else {
    Write-Host "  ❌ Failed to create storage account" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Step 2: Create Function Apps
Write-Host "[2/5] Creating Function Apps on standard Consumption plan..." -ForegroundColor Yellow
Write-Host ""

# JavaScript Function App
Write-Host "  Creating dc-add-v2 (Node.js 18)..." -ForegroundColor Cyan
az functionapp create `
    --name dc-add-v2 `
    --storage-account $storageAccount `
    --consumption-plan-location $location `
    --resource-group $rg `
    --functions-version 4 `
    --runtime node `
    --runtime-version 18 `
    --os-type Linux `
    --output none

if ($LASTEXITCODE -eq 0) {
    Write-Host "    ✅ dc-add-v2 created" -ForegroundColor Green
} else {
    Write-Host "    ❌ Failed" -ForegroundColor Red
}

# Python Function App
Write-Host "  Creating dc-subtract-v2 (Python 3.9)..." -ForegroundColor Cyan
az functionapp create `
    --name dc-subtract-v2 `
    --storage-account $storageAccount `
    --consumption-plan-location $location `
    --resource-group $rg `
    --functions-version 4 `
    --runtime python `
    --runtime-version 3.9 `
    --os-type Linux `
    --output none

if ($LASTEXITCODE -eq 0) {
    Write-Host "    ✅ dc-subtract-v2 created" -ForegroundColor Green
} else {
    Write-Host "    ❌ Failed" -ForegroundColor Red
}

# .NET Function App
Write-Host "  Creating dc-multiply-v2 (DotNet 6.0)..." -ForegroundColor Cyan
az functionapp create `
    --name dc-multiply-v2 `
    --storage-account $storageAccount `
    --consumption-plan-location $location `
    --resource-group $rg `
    --functions-version 4 `
    --runtime dotnet `
    --runtime-version 6.0 `
    --os-type Linux `
    --output none

if ($LASTEXITCODE -eq 0) {
    Write-Host "    ✅ dc-multiply-v2 created" -ForegroundColor Green
} else {
    Write-Host "    ❌ Failed" -ForegroundColor Red
}

# Custom handler for Go (Node.js runtime with custom handler)
Write-Host "  Creating dc-divide-v2 (Custom handler)..." -ForegroundColor Cyan
az functionapp create `
    --name dc-divide-v2 `
    --storage-account $storageAccount `
    --consumption-plan-location $location `
    --resource-group $rg `
    --functions-version 4 `
    --runtime node `
    --runtime-version 18 `
    --os-type Linux `
    --output none

if ($LASTEXITCODE -eq 0) {
    # Set custom handler app setting
    az functionapp config appsettings set `
        --name dc-divide-v2 `
        --resource-group $rg `
        --settings "FUNCTIONS_WORKER_RUNTIME=custom" `
        --output none
    
    Write-Host "    ✅ dc-divide-v2 created (custom handler configured)" -ForegroundColor Green
} else {
    Write-Host "    ❌ Failed" -ForegroundColor Red
}

Write-Host ""

# Step 3: Get hostnames
Write-Host "[3/5] Getting Function App URLs..." -ForegroundColor Yellow
$apps = az functionapp list --resource-group $rg --query "[?name=='dc-add-v2' || name=='dc-subtract-v2' || name=='dc-multiply-v2' || name=='dc-divide-v2'].{Name:name, URL:defaultHostName}" -o json | ConvertFrom-Json

foreach ($app in $apps) {
    Write-Host "  $($app.Name): https://$($app.URL)" -ForegroundColor Gray
}
Write-Host ""

# Step 4: Display GitHub Secrets to update
Write-Host "[4/5] Update these GitHub Secrets:" -ForegroundColor Yellow
Write-Host "  Go to: https://github.com/harryvu/DistributedCalc/settings/secrets/actions" -ForegroundColor Gray
Write-Host ""
Write-Host "  AZURE_FUNCTIONAPP_NAME_ADDING = dc-add-v2" -ForegroundColor White
Write-Host "  AZURE_FUNCTIONAPP_NAME_SUBTRACTING = dc-subtract-v2" -ForegroundColor White
Write-Host "  AZURE_FUNCTIONAPP_NAME_MULTIPLYING = dc-multiply-v2" -ForegroundColor White
Write-Host "  AZURE_FUNCTIONAPP_NAME_DIVIDING = dc-divide-v2" -ForegroundColor White
Write-Host ""

# Step 5: Summary
Write-Host "[5/5] Summary" -ForegroundColor Yellow
Write-Host "  ✅ Storage account: $storageAccount" -ForegroundColor Green
Write-Host "  ✅ 4 Function Apps created on standard Consumption (Y1) plan" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Update GitHub Secrets with the app names above" -ForegroundColor White
Write-Host "  2. Commit and push changes (or manually trigger GitHub Actions workflow)" -ForegroundColor White
Write-Host "  3. All 4 Function Apps should deploy and work correctly!" -ForegroundColor White
Write-Host ""

# Clean up old apps (optional)
Write-Host "Optional: Delete old Flex Consumption apps?" -ForegroundColor Yellow
Write-Host "  az functionapp delete --name dc-add --resource-group $rg" -ForegroundColor Gray
Write-Host "  az functionapp delete --name dc-subtract --resource-group $rg" -ForegroundColor Gray
Write-Host "  az functionapp delete --name dc-multiply --resource-group $rg" -ForegroundColor Gray
Write-Host "  az functionapp delete --name dc-divide --resource-group $rg" -ForegroundColor Gray
