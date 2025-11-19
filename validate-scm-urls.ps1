# Validate publish profile SCM URLs
# This checks if the SCM URLs in your publish profiles are correct

Write-Host "Validating Function App SCM endpoints..." -ForegroundColor Cyan
Write-Host ""

$resourceGroup = "rg-dcalc"
$apps = @(
    @{Name="dc-add"; Display="Adding Service"},
    @{Name="dc-subtract"; Display="Subtracting Service"},
    @{Name="dc-multiply"; Display="Multiplying Service"},
    @{Name="dc-divide"; Display="Dividing Service"}
)

Write-Host "Expected SCM URLs that should be in your publish profiles:" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Yellow
Write-Host ""

foreach ($app in $apps) {
    $name = $app.Name
    $display = $app.Display
    
    # Get the default hostname
    $hostname = az functionapp show --name $name --resource-group $resourceGroup --query "defaultHostName" -o tsv 2>$null
    
    if ($hostname) {
        $scmUrl = "https://$name.scm.azurewebsites.net"
        
        Write-Host "$display ($name):" -ForegroundColor Cyan
        Write-Host "  SCM URL: $scmUrl" -ForegroundColor White
        Write-Host "  Zip Deploy: $scmUrl/api/zipdeploy" -ForegroundColor Gray
        Write-Host ""
    }
}

Write-Host ""
Write-Host "ACTION REQUIRED:" -ForegroundColor Yellow
Write-Host "1. Download fresh publish profiles from Azure Portal for each app" -ForegroundColor White
Write-Host "2. Open each .PublishSettings file in a text editor" -ForegroundColor White  
Write-Host "3. Verify the publishUrl contains the SCM URL shown above" -ForegroundColor White
Write-Host "4. Copy the entire XML content to the corresponding GitHub Secret" -ForegroundColor White
Write-Host ""
Write-Host "The publishUrl should look like:" -ForegroundColor Gray
Write-Host '  publishUrl="<app-name>.scm.azurewebsites.net:443"' -ForegroundColor Gray
