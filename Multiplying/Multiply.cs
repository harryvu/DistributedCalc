using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace Multiplying
{
    public static class Multiply
    {
        [FunctionName("multiply")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", "post", Route = null)] HttpRequest req,
            ILogger log)
        {
            log.LogInformation("C# HTTP trigger function processed a request for multiplication.");

            string aStr = req.Query["a"];
            string bStr = req.Query["b"];

            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            dynamic data = JsonConvert.DeserializeObject(requestBody);
            aStr = aStr ?? data?.a;
            bStr = bStr ?? data?.b;

            if (string.IsNullOrEmpty(aStr) || string.IsNullOrEmpty(bStr))
            {
                return new BadRequestObjectResult("Please provide parameters 'a' and 'b' in query string or request body");
            }

            if (!double.TryParse(aStr, out double a) || !double.TryParse(bStr, out double b))
            {
                return new BadRequestObjectResult("Please provide valid numbers for parameters 'a' and 'b'");
            }

            double result = a * b;

            var response = new
            {
                operation = "multiplication",
                a = a,
                b = b,
                result = result
            };

            return new OkObjectResult(response);
        }
    }
}
