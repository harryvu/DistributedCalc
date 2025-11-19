# Troubleshooting 401 Deployment Errors

## Problem
GitHub Actions deployment fails with:
```
Failed to fetch Kudu App Settings.
Unauthorized (CODE: 401)
```

## Root Cause
Azure Function Apps have **Basic Authentication** disabled by default for security. The `Azure/functions-action` requires Basic Auth to be enabled to validate resources using the SCM/Kudu API.

## Solution

### Option 1: Enable Basic Authentication (Recommended for CI/CD)

For **each** Function App (Adding, Subtracting, Multiplying, Dividing):

1. Go to Azure Portal
2. Navigate to your Function App
3. Go to **Settings** → **Configuration** → **General settings**
4. Scroll down to **Platform settings**
5. Find **SCM Basic Auth Publishing Credentials**
6. Set to **On**
7. Click **Save**
8. Repeat for all 4 Function Apps

### Option 2: Use Azure CLI (Faster)

Run these commands for each Function App:

```bash
# Enable Basic Auth for SCM
az functionapp config set --name <function-app-name> --resource-group <resource-group-name> --ftps-state FtpsOnly
az resource update --resource-group <resource-group-name> --name scm --namespace Microsoft.Web --resource-type basicPublishingCredentialsPolicies --parent sites/<function-app-name> --set properties.allow=true

# Verify
az functionapp deployment list-publishing-credentials --name <function-app-name> --resource-group <resource-group-name>
```

Replace:
- `<function-app-name>`: Your Function App name (e.g., `func-adding-calc`)
- `<resource-group-name>`: Your resource group name

### Option 3: Regenerate and Re-download Publish Profiles (CRITICAL STEP)

**IMPORTANT**: If you enabled Basic Auth after the publish profiles were created, you MUST regenerate them:

1. In Azure Portal, go to each Function App
2. Go to **Deployment** → **Deployment Center**
3. Click **Manage publish profile** → **Reset publish profile** (this regenerates credentials)
4. Click **Download publish profile** button
5. Open the downloaded `.PublishSettings` file and copy the entire XML content
6. Update GitHub Secrets:
   - `AZURE_FUNCTIONAPP_PUBLISH_PROFILE_ADDING`
   - `AZURE_FUNCTIONAPP_PUBLISH_PROFILE_SUBTRACTING`
   - `AZURE_FUNCTIONAPP_PUBLISH_PROFILE_MULTIPLYING`
   - `AZURE_FUNCTIONAPP_PUBLISH_PROFILE_DIVIDING`
7. When pasting into GitHub Secrets, ensure **no extra whitespace** before or after the XML

**Note**: Old publish profiles will NOT work after enabling Basic Auth - you must reset them.

## Why This Happens

Microsoft disabled Basic Auth by default in 2022 for enhanced security. However, publish profile deployments via GitHub Actions still require it for the SCM (Kudu) endpoint validation step.

## Security Note

Basic Auth is only required for the SCM endpoint (build/deployment), not for the function runtime itself. Your functions remain secure with Azure AD authentication if configured.
