# Setup Azure Service Principal for GitHub Actions

# This script creates a service principal with the necessary permissions to deploy to your Function Apps

Write-Host "Creating Azure Service Principal for GitHub Actions..." -ForegroundColor Cyan
Write-Host ""

# Get subscription ID
$subscriptionId = az account show --query id -o tsv
$subscriptionName = az account show --query name -o tsv

Write-Host "Subscription: $subscriptionName" -ForegroundColor Gray
Write-Host "Subscription ID: $subscriptionId" -ForegroundColor Gray
Write-Host ""

# Create service principal
Write-Host "Creating service principal..." -ForegroundColor Yellow
$sp = az ad sp create-for-rbac `
    --name "github-actions-distributedcalc" `
    --role "Contributor" `
    --scopes "/subscriptions/$subscriptionId/resourceGroups/rg-dcalc" `
    --sdk-auth `
    --output json | ConvertFrom-Json

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Service principal created successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Yellow
    Write-Host "COPY THIS JSON TO GITHUB SECRET: AZURE_CREDENTIALS" -ForegroundColor Yellow
    Write-Host "================================================" -ForegroundColor Yellow
    Write-Host ""
    
    # Display the credentials in JSON format
    $sp | ConvertTo-Json -Depth 10
    
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Copy the JSON above (everything including the curly braces)" -ForegroundColor White
    Write-Host "2. Go to: https://github.com/harryvu/DistributedCalc/settings/secrets/actions" -ForegroundColor White
    Write-Host "3. Create new secret named: AZURE_CREDENTIALS" -ForegroundColor White
    Write-Host "4. Paste the JSON as the value" -ForegroundColor White
    Write-Host "5. Re-run the GitHub Actions workflow" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "❌ Failed to create service principal" -ForegroundColor Red
    Write-Host "Error code: $LASTEXITCODE" -ForegroundColor Red
}
