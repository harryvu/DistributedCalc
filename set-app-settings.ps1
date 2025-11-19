# Set required app settings for Azure Functions deployment
# This prevents the GitHub Action from trying to set them (which causes 405 errors)

Write-Host "Setting app settings for all Function Apps..." -ForegroundColor Cyan
Write-Host ""

$resourceGroup = "rg-dcalc"
$apps = @("dc-add", "dc-subtract", "dc-multiply", "dc-divide")

foreach ($app in $apps) {
    Write-Host "Configuring $app..." -ForegroundColor Yellow
    
    # Set app settings
    az functionapp config appsettings set `
        --name $app `
        --resource-group $resourceGroup `
        --settings `
        SCM_DO_BUILD_DURING_DEPLOYMENT=false `
        ENABLE_ORYX_BUILD=false `
        --output none
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ App settings configured for $app" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Failed to configure $app" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Done! App settings have been configured." -ForegroundColor Green
Write-Host "The GitHub Action will no longer try to set these settings." -ForegroundColor Gray
