# Azure Deployment Setup

The GitHub Actions workflow now uses Azure Service Principal authentication instead of publish profiles, which is more reliable and secure.

## Required GitHub Secrets

You need to set up the following secrets in your GitHub repository:

### 1. AZURE_CREDENTIALS (Service Principal)

Create an Azure Service Principal and add it as a GitHub secret:

```bash
az ad sp create-for-rbac --name "DistributedCalc-GitHub-Actions" \
  --role contributor \
  --scopes /subscriptions/{subscription-id}/resourceGroups/{resource-group-name} \
  --sdk-auth
```

**Replace:**
- `{subscription-id}` - Your Azure subscription ID
- `{resource-group-name}` - The resource group containing your Function Apps

This command will output JSON credentials. Copy the entire JSON output and save it as the `AZURE_CREDENTIALS` secret in GitHub.

### 2. Function App Names

Set these secrets with the exact names of your Azure Function Apps:

- `AZURE_FUNCTIONAPP_NAME_ADDING` - Name of the Adding service Function App
- `AZURE_FUNCTIONAPP_NAME_SUBTRACTING` - Name of the Subtracting service Function App
- `AZURE_FUNCTIONAPP_NAME_MULTIPLYING` - Name of the Multiplying service Function App
- `AZURE_FUNCTIONAPP_NAME_DIVIDING` - Name of the Dividing service Function App

## How to Add Secrets to GitHub

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add each secret with its corresponding value

## Verify Service Principal Permissions

After creating the Service Principal, verify it has the correct permissions:

```bash
# Assign Website Contributor role specifically for Function Apps
az role assignment create \
  --assignee {service-principal-app-id} \
  --role "Website Contributor" \
  --scope /subscriptions/{subscription-id}/resourceGroups/{resource-group-name}
```

## Testing the Deployment

After setting up the secrets:

1. Push any change to the `main` branch
2. The GitHub Actions workflow will trigger automatically
3. Monitor the workflow run in the **Actions** tab of your repository

## Troubleshooting

If deployment fails:

1. Verify the Service Principal has correct permissions
2. Ensure Function App names match exactly (case-sensitive)
3. Check that the Service Principal hasn't expired
4. Verify the resource group and subscription IDs are correct
