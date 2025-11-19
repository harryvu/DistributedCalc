# Regenerate publishing profiles for all Function Apps
# This creates fresh credentials after enabling Basic Auth

Write-Host "Regenerating publishing profiles for all Function Apps..." -ForegroundColor Cyan
Write-Host ""

$resourceGroup = "rg-dcalc"
$apps = @("dc-add", "dc-subtract", "dc-multiply", "dc-divide")

foreach ($app in $apps) {
    Write-Host "Processing $app..." -ForegroundColor Yellow
    
    # Get new publish profile and save to file
    $outputFile = "$PSScriptRoot\$app.PublishSettings"
    az functionapp deployment list-publishing-profiles --name $app --resource-group $resourceGroup --xml > $outputFile 2>$null
    
    if (Test-Path $outputFile) {
        Write-Host "  ✅ New publish profile saved to: $outputFile" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Failed to get publish profile for $app" -ForegroundColor Red
    }
    Write-Host ""
}

Write-Host "================================" -ForegroundColor Yellow
Write-Host "IMPORTANT: Download NEW publish profiles NOW!" -ForegroundColor Red
Write-Host "================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "Go to Azure Portal for each Function App and:" -ForegroundColor White
Write-Host "  1. Click 'Get publish profile'" -ForegroundColor White
Write-Host "  2. Save the .PublishSettings file" -ForegroundColor White
Write-Host "  3. Copy the ENTIRE XML content" -ForegroundColor White
Write-Host "  4. Update the GitHub Secret" -ForegroundColor White
Write-Host ""
Write-Host "Apps to update:" -ForegroundColor Cyan
foreach ($app in $apps) {
    Write-Host "  - $app" -ForegroundColor White
}
