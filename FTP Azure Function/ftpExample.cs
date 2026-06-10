using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

namespace aardvarklabs;

public class ftpExample
{
    private readonly ILogger<ftpExample> _logger;

    public ftpExample(ILogger<ftpExample> logger)
    {
        _logger = logger;
    }

    [Function("ftpExample")]
    public IActionResult Run([HttpTrigger(AuthorizationLevel.Function, "get", "post")] HttpRequest req)
    {
        _logger.LogInformation("C# HTTP trigger function processed a request.");
        return new OkObjectResult("Welcome to Azure Functions!");
    }
}