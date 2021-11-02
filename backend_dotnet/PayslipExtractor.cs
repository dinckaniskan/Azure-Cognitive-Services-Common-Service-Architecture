using System.Collections.Generic;
using System.Net.Http;
using System.Threading.Tasks;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.DurableTask;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json.Linq;


namespace Contoso.Example
{
    public static class PayslipExtractor
    {
        // public static ILogger log = new ILogger;

        [FunctionName("PayslipExtractorWorkflow")]
        public static async Task<string> RunOrchestrator(
            [OrchestrationTrigger] IDurableOrchestrationContext context,
            ILogger log)            
        {

            var inputs = context.GetInput<Dictionary<string,string>>();
 
            var extract = await context.CallActivityAsync<Extract>("CallOcrCustomModel", inputs);
            var validated_extract = await context.CallActivityAsync<Extract>("ValidateExtract", extract);

            log.LogInformation(validated_extract.AsJson());
            
            return validated_extract.AsJson();
        }



        [FunctionName("PayslipExtractor")]
        public static async Task<HttpResponseMessage> HttpStart(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", "post")] HttpRequestMessage req,
            [DurableClient] IDurableOrchestrationClient starter,
            ILogger log)
        {

            // Collect input values from request
            string body = await req.Content.ReadAsStringAsync();
            dynamic inputAttributes = JObject.Parse(body);
 
            // Parse dictionary of inputs
            Dictionary<string,string> inputs = new Dictionary<string,string>() {
                {"url", (string)inputAttributes.url},
                {"pages", (string)inputAttributes.pages}
            };
                

            // Function input comes from the request content.
            string instanceId = await starter.StartNewAsync("PayslipExtractorWorkflow", inputs);

            log.LogInformation($"Started orchestration with ID = '{instanceId}'.");

            return starter.CreateCheckStatusResponse(req, instanceId);
        }
    }
}