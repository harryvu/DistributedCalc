# Quick test of deployed functions with detailed error reporting

Write-Host "Quick Function Test" -ForegroundColor Cyan
Write-Host "==================" -ForegroundColor Cyan
Write-Host ""

# Test data
$tests = @(
    @{
        Name = "Addition (JavaScript)"
        Url = "https://dc-add-dmanhae7ejcsb6c5.westus2-01.azurewebsites.net/api/add?a=15&b=25"
        Expected = "40"
    },
    @{
        Name = "Subtraction (Python)"
        Url = "https://dc-subtract-brddgwafhqbxeube.westus2-01.azurewebsites.net/api/subtract?a=50&b=20"
        Expected = "30"
    },
    @{
        Name = "Multiplication (C#)"
        Url = "https://dc-multiply-eadzdrfja9fzctg5.westus2-01.azurewebsites.net/api/Multiply?a=6&b=7"
        Expected = "42"
    },
    @{
        Name = "Division (Go)"
        Url = "https://dc-divide-hhbsemf5hubshrau.westus2-01.azurewebsites.net/api/divide?a=100&b=4"
        Expected = "25"
    }
)

foreach ($test in $tests) {
    Write-Host "$($test.Name)" -ForegroundColor Yellow
    Write-Host "  Testing: $($test.Url)" -ForegroundColor Gray
    
    try {
        $response = Invoke-RestMethod -Uri $test.Url -Method GET -TimeoutSec 30
        $responseText = $response | ConvertTo-Json -Compress
        
        Write-Host "  Response: $responseText" -ForegroundColor White
        
        if ($responseText -match $test.Expected) {
            Write-Host "  ✅ PASS" -ForegroundColor Green
        } else {
            Write-Host "  ⚠️  Response doesn't contain expected value: $($test.Expected)" -ForegroundColor Yellow
        }
    }
    catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Host "  ❌ FAIL - HTTP $statusCode" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    Write-Host ""
}

Write-Host "Test URLs for manual testing:" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan
foreach ($test in $tests) {
    Write-Host $test.Url -ForegroundColor Gray
}
