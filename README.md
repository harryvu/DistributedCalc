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

Each microservice can be deployed independently to Azure Functions:

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
