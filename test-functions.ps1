# Test all deployed Azure Functions

Write-Host "Testing Distributed Calculator Functions..." -ForegroundColor Cyan
Write-Host ""

$resourceGroup = "rg-dcalc"
$apps = @(
    @{Name="dc-add"; FunctionName="add"; TestData=@{a=10; b=5}; Expected=15},
    @{Name="dc-subtract"; FunctionName="subtract"; TestData=@{a=10; b=5}; Expected=5},
    @{Name="dc-multiply"; FunctionName="Multiply"; TestData=@{a=10; b=5}; Expected=50},
    @{Name="dc-divide"; FunctionName="divide"; TestData=@{a=10; b=5}; Expected=2}
)

foreach ($app in $apps) {
    Write-Host "Testing $($app.Name) ($($app.FunctionName))..." -ForegroundColor Yellow
    
    # Get the function URL
    $functionUrl = az functionapp function show `
        --name $app.Name `
        --resource-group $resourceGroup `
        --function-name $app.FunctionName `
        --query "invokeUrlTemplate" -o tsv 2>$null
    
    if ($functionUrl) {
        Write-Host "  URL: $functionUrl" -ForegroundColor Gray
        
        # Build query parameters
        $params = ""
        foreach ($key in $app.TestData.Keys) {
            $params += "&$key=$($app.TestData[$key])"
        }
        $params = $params.TrimStart('&')
        
        $testUrl = "$functionUrl`?$params"
        
        try {
            # Make the request
            $response = Invoke-RestMethod -Uri $testUrl -Method GET -ErrorAction Stop
            
            Write-Host "  Request: $($app.TestData.a) and $($app.TestData.b)" -ForegroundColor Gray
            Write-Host "  Response: $response" -ForegroundColor White
            Write-Host "  Expected: $($app.Expected)" -ForegroundColor Gray
            
            # Check if result matches expected
            if ($response -match $app.Expected) {
                Write-Host "  ✅ TEST PASSED" -ForegroundColor Green
            } else {
                Write-Host "  ⚠️  TEST FAILED - Result doesn't match expected value" -ForegroundColor Yellow
            }
        }
        catch {
            Write-Host "  ❌ ERROR: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    else {
        Write-Host "  ❌ Could not get function URL" -ForegroundColor Red
    }
    
    Write-Host ""
}

Write-Host ""
Write-Host "Testing complete!" -ForegroundColor Cyan
Write-Host ""
Write-Host "You can also test manually with these URLs:" -ForegroundColor Yellow
Write-Host "  Add:      https://dc-add-dmanhae7ejcsb6c5.westus2-01.azurewebsites.net/api/add?a=10&b=5" -ForegroundColor Gray
Write-Host "  Subtract: https://dc-subtract-{unique-id}.westus2-01.azurewebsites.net/api/subtract?a=10&b=5" -ForegroundColor Gray
Write-Host "  Multiply: https://dc-multiply-{unique-id}.westus2-01.azurewebsites.net/api/Multiply?a=10&b=5" -ForegroundColor Gray
Write-Host "  Divide:   https://dc-divide-{unique-id}.westus2-01.azurewebsites.net/api/divide?a=10&b=5" -ForegroundColor Gray
