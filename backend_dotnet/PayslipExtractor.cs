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
        [FunctionName("PayslipExtractorWorkflow")]
        public static async Task<string> RunOrchestrator(
            [OrchestrationTrigger] IDurableOrchestrationContext context)
        {
            // var outputs = new List<string>();

            // // Replace "hello" with the name of your Durable Activity Function.
            // outputs.Add(await context.CallActivityAsync<string>("CallFormRecognizer", "Tokyo"));
            // outputs.Add(await context.CallActivityAsync<string>("CallFormRecognizer", "Seattle"));
            // outputs.Add(await context.CallActivityAsync<string>("CallFormRecognizer", "London"));

            var x = await context.CallActivityAsync<string>("CallOcrStandardModel", "Tokyo");

            // returns ["Hello Tokyo!", "Hello Seattle!", "Hello London!"]
            return x;
        }



        [FunctionName("PayslipExtractor")]
        public static async Task<HttpResponseMessage> HttpStart(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", "post")] HttpRequestMessage req,
            [DurableClient] IDurableOrchestrationClient starter,
            ILogger log)
        {

            string body = await req.Content.ReadAsStringAsync();
            dynamic b = JObject.Parse(body);
            
            string url = b.url;
            string pages = b.pages;

            log.LogInformation(url);
            log.LogInformation(pages);

            // Function input comes from the request content.
            string instanceId = await starter.StartNewAsync("PayslipExtractor", null);

            log.LogInformation($"Started orchestration with ID = '{instanceId}'.");

            return starter.CreateCheckStatusResponse(req, instanceId);
        }
    }
}