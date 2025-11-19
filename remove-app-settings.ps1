# Remove unsupported app settings from all Function Apps

Write-Host "Removing unsupported app settings from all Function Apps..." -ForegroundColor Cyan
Write-Host ""

$resourceGroup = "rg-dcalc"
$apps = @("dc-add", "dc-subtract", "dc-multiply", "dc-divide")

foreach ($app in $apps) {
    Write-Host "Removing settings from $app..." -ForegroundColor Yellow
    
    # Remove the unsupported app settings
    az functionapp config appsettings delete `
        --name $app `
        --resource-group $resourceGroup `
        --setting-names SCM_DO_BUILD_DURING_DEPLOYMENT ENABLE_ORYX_BUILD `
        --output none 2>$null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Unsupported settings removed from $app" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  May have already been removed from $app" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "✅ Done! Now re-run the GitHub Actions workflow." -ForegroundColor Green
