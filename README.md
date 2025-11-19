# DistributedCalc
Simplest Distributed Calculator

A distributed calculator system built with Azure Functions microservices. Each mathematical operation is implemented as a separate microservice in a different programming language.

## Architecture

This distributed calculator consists of four independent microservices:

1. **Adding** - JavaScript/Node.js Azure Function
2. **Subtracting** - Python Azure Function
3. **Multiplying** - C# Azure Function
4. **Dividing** - Go Azure Function

Each microservice is designed to be deployed independently to Azure Functions and can be scaled separately based on demand.

## Microservices

### Adding Service (JavaScript)
- **Language**: JavaScript (Node.js)
- **Endpoint**: `/api/add`
- **Parameters**: `a` and `b` (numbers)
- **Location**: `Adding/`

### Subtracting Service (Python)
- **Language**: Python
- **Endpoint**: `/api/subtract`
- **Parameters**: `a` and `b` (numbers)
- **Location**: `Subtracting/`

### Multiplying Service (C#)
- **Language**: C# (.NET 6.0)
- **Endpoint**: `/api/multiply`
- **Parameters**: `a` and `b` (numbers)
- **Location**: `Multiplying/`

### Dividing Service (Go)
- **Language**: Go
- **Endpoint**: `/api/divide`
- **Parameters**: `a` and `b` (numbers)
- **Note**: Includes division by zero validation
- **Location**: `Dividing/`

## API Usage

All services accept parameters via query string or JSON body:

### Query String Example
```
GET /api/add?a=5&b=3
```

### JSON Body Example
```
POST /api/add
Content-Type: application/json

{
  "a": 5,
  "b": 3
}
```

### Response Format
```json
{
  "operation": "addition",
  "a": 5,
  "b": 3,
  "result": 8
}
```

## Local Development

### Prerequisites
- [Azure Functions Core Tools](https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local)
- Node.js (for Adding service)
- Python 3.x (for Subtracting service)
- .NET 6.0 SDK (for Multiplying service)
- Go 1.19+ (for Dividing service)

### Running Locally

#### Adding Service (JavaScript)
```bash
cd Adding
npm install
func start
```

#### Subtracting Service (Python)
```bash
cd Subtracting
pip install -r requirements.txt
func start
```

#### Multiplying Service (C#)
```bash
cd Multiplying
dotnet restore
func start
```

#### Dividing Service (Go)
```bash
cd Dividing
go mod download
go build handler.go
func start
```

## Deployment to Azure

### Automated Deployment with GitHub Actions

This project includes a GitHub Actions workflow (`.github/workflows/deploy-azure-functions.yml`) that automatically deploys all four microservices to Azure Functions when changes are pushed to the `main` branch.

#### Setup Instructions

1. **Create Azure Function Apps**: Create four separate Azure Function Apps in your Azure subscription (one for each microservice). Make sure to set the authentication level to **Anonymous** for public access.

2. **Get Publish Profiles**: For each Function App, download the publish profile from the Azure Portal:
   - Go to your Function App → Get publish profile
   - Save the XML content

3. **Configure GitHub Secrets**: Add the following secrets to your GitHub repository (Settings → Secrets and variables → Actions):
   - `AZURE_FUNCTIONAPP_NAME_ADDING` - Name of your Adding service Function App
   - `AZURE_FUNCTIONAPP_PUBLISH_PROFILE_ADDING` - Publish profile XML for Adding service
   - `AZURE_FUNCTIONAPP_NAME_SUBTRACTING` - Name of your Subtracting service Function App
   - `AZURE_FUNCTIONAPP_PUBLISH_PROFILE_SUBTRACTING` - Publish profile XML for Subtracting service
   - `AZURE_FUNCTIONAPP_NAME_MULTIPLYING` - Name of your Multiplying service Function App
   - `AZURE_FUNCTIONAPP_PUBLISH_PROFILE_MULTIPLYING` - Publish profile XML for Multiplying service
   - `AZURE_FUNCTIONAPP_NAME_DIVIDING` - Name of your Dividing service Function App
   - `AZURE_FUNCTIONAPP_PUBLISH_PROFILE_DIVIDING` - Publish profile XML for Dividing service

4. **Deploy**: Push to the `main` branch or manually trigger the workflow from the Actions tab to deploy all services.

### Manual Deployment

Each microservice can also be deployed independently using Azure Functions Core Tools:

```bash
# Deploy from each service directory
func azure functionapp publish <YOUR-FUNCTION-APP-NAME>
```

## Error Handling

All services include proper error handling for:
- Missing parameters
- Invalid number formats
- Division by zero (Dividing service only)

## Project Structure

```
DistributedCalc/
├── .github/
│   └── workflows/
│       └── deploy-azure-functions.yml  # GitHub Actions deployment workflow
├── Adding/                 # JavaScript/Node.js service
│   ├── add/
│   │   ├── function.json
│   │   └── index.js
│   ├── host.json
│   └── package.json
├── Subtracting/           # Python service
│   ├── subtract/
│   │   ├── function.json
│   │   └── __init__.py
│   ├── host.json
│   └── requirements.txt
├── Multiplying/           # C# service
│   ├── Multiply.cs
│   ├── Multiplying.csproj
│   └── host.json
├── Dividing/              # Go service
│   ├── divide/
│   │   └── function.json
│   ├── handler.go
│   ├── go.mod
│   └── host.json
└── README.md
```
