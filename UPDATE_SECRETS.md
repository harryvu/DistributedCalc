# GitHub Secrets Update Instructions

## ✅ All 4 New Function Apps Created Successfully!

All Function Apps are now running on **Standard Consumption Plan** (not Flex preview):
- ✅ dc-add-v2 (Node.js 20)
- ✅ dc-subtract-v2 (Python 3.11)
- ✅ dc-multiply-v2 (.NET 8.0 Isolated)
- ✅ dc-divide-v2 (Custom handler for Go)

## 📝 Update GitHub Secrets

Go to: https://github.com/harryvu/DistributedCalc/settings/secrets/actions

Update these 4 secrets with the new app names:

```
AZURE_FUNCTIONAPP_NAME_ADDING = dc-add-v2
AZURE_FUNCTIONAPP_NAME_SUBTRACTING = dc-subtract-v2
AZURE_FUNCTIONAPP_NAME_MULTIPLYING = dc-multiply-v2
AZURE_FUNCTIONAPP_NAME_DIVIDING = dc-divide-v2
```

## 🔄 Deploy to New Apps

After updating the secrets, trigger a deployment:

### Option 1: Make a small change and push
```powershell
git commit --allow-empty -m "Trigger deployment to new Function Apps"
git push
```

### Option 2: Manually trigger workflow
Go to: https://github.com/harryvu/DistributedCalc/actions/workflows/deploy-azure-functions.yml
Click "Run workflow"

## 🧪 Test URLs (after deployment)

- **Addition**: https://dc-add-v2.azurewebsites.net/api/add?a=10&b=5
- **Subtraction**: https://dc-subtract-v2.azurewebsites.net/api/subtract?a=10&b=5
- **Multiplication**: https://dc-multiply-v2.azurewebsites.net/api/Multiply?a=10&b=5
- **Division**: https://dc-divide-v2.azurewebsites.net/api/divide?a=10&b=5

## 🗑️ Clean Up Old Apps (Optional)

After verifying the new apps work, you can delete the old Flex Consumption apps:

```powershell
az functionapp delete --name dc-add --resource-group rg-dcalc -y
az functionapp delete --name dc-subtract --resource-group rg-dcalc -y
az functionapp delete --name dc-multiply --resource-group rg-dcalc -y
az functionapp delete --name dc-divide --resource-group rg-dcalc -y
```

## ℹ️ What Changed

- **Old**: Flex Consumption (preview) with limited runtime support
- **New**: Standard Consumption (Y1) with full runtime support
- **Benefits**:
  - ✅ Stable, production-ready
  - ✅ Full Kudu API access
  - ✅ Better debugging tools
  - ✅ Proven runtime support
  - ✅ Same pay-per-execution pricing
