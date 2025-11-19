# Verify App Names Script
# Run this to check if your GitHub secrets match your actual Azure Function App names

Write-Host "Checking Function App Names..." -ForegroundColor Cyan
Write-Host ""

# Check if Azure CLI is installed
try {
    $azVersion = az version --output json | ConvertFrom-Json
    Write-Host "✅ Azure CLI is installed (version $($azVersion.'azure-cli'))" -ForegroundColor Green
} catch {
    Write-Host "❌ Azure CLI is not installed. Please install it from: https://aka.ms/installazurecliwindows" -ForegroundColor Red
    exit 1
}

# Check if logged in
try {
    $account = az account show 2>$null | ConvertFrom-Json
    
    # Check if logged in with correct account
    if ($account.user.name -ne "hung@nguontri.com") {
        Write-Host "⚠️  Currently logged in as: $($account.user.name)" -ForegroundColor Yellow
        Write-Host "   Please log in with hung@nguontri.com" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Running: az login" -ForegroundColor Cyan
        az login
        $account = az account show | ConvertFrom-Json
    }
    
    Write-Host "✅ Logged in to Azure as: $($account.user.name)" -ForegroundColor Green
    Write-Host "   Subscription: $($account.name)" -ForegroundColor Gray
    Write-Host ""
} catch {
    Write-Host "❌ Not logged in to Azure. Logging in now..." -ForegroundColor Yellow
    az login
    $account = az account show | ConvertFrom-Json
    Write-Host "✅ Logged in as: $($account.user.name)" -ForegroundColor Green
    Write-Host ""
}

# List all Function Apps in the subscription
Write-Host "Finding Function Apps in your subscription..." -ForegroundColor Cyan
$functionApps = az functionapp list --query "[].{name:name, resourceGroup:resourceGroup, state:state}" -o json | ConvertFrom-Json

if ($functionApps.Count -eq 0) {
    Write-Host "❌ No Function Apps found in this subscription" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Found $($functionApps.Count) Function App(s):" -ForegroundColor Green
Write-Host ""
Write-Host "Copy these exact names to your GitHub Secrets:" -ForegroundColor Yellow
Write-Host "================================================" -ForegroundColor Yellow

foreach ($app in $functionApps) {
    Write-Host ""
    Write-Host "App Name: " -NoNewline -ForegroundColor Cyan
    Write-Host $app.name -ForegroundColor White
    Write-Host "Resource Group: " -NoNewline -ForegroundColor Gray
    Write-Host $app.resourceGroup -ForegroundColor White
    Write-Host "State: " -NoNewline -ForegroundColor Gray
    Write-Host $app.state -ForegroundColor $(if ($app.state -eq "Running") { "Green" } else { "Yellow" })
    
    # Get the publish profile URL to verify
    try {
        $appDetails = az functionapp show --name $app.name --resource-group $app.resourceGroup --query "{defaultHostName:defaultHostName}" -o json | ConvertFrom-Json
        Write-Host "URL: " -NoNewline -ForegroundColor Gray
        Write-Host "https://$($appDetails.defaultHostName)" -ForegroundColor White
    } catch {
        Write-Host "Could not get URL details" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "GitHub Secrets to set (based on your apps):" -ForegroundColor Cyan
Write-Host ""

# Try to match apps to the calculator services
$services = @("adding", "subtract", "multiply", "divid")
foreach ($service in $services) {
    $matchedApp = $functionApps | Where-Object { $_.name -like "*$service*" } | Select-Object -First 1
    if ($matchedApp) {
        $secretName = "AZURE_FUNCTIONAPP_NAME_" + $service.ToUpper()
        if ($service -eq "subtract") { $secretName = "AZURE_FUNCTIONAPP_NAME_SUBTRACTING" }
        if ($service -eq "multiply") { $secretName = "AZURE_FUNCTIONAPP_NAME_MULTIPLYING" }
        if ($service -eq "divid") { $secretName = "AZURE_FUNCTIONAPP_NAME_DIVIDING" }
        
        Write-Host "$secretName = " -NoNewline -ForegroundColor Yellow
        Write-Host $matchedApp.name -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Go to GitHub repository → Settings → Secrets and variables → Actions" -ForegroundColor White
Write-Host "2. Update/Add the AZURE_FUNCTIONAPP_NAME_* secrets with the exact names above" -ForegroundColor White
Write-Host "3. Make sure the names match EXACTLY (case-sensitive)" -ForegroundColor White
