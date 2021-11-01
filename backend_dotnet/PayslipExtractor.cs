using System.Collections.Generic;
using System.Net.Http;
using System.Threading.Tasks;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.DurableTask;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Extensions.Logging;


namespace Contoso.Example
{
    public static class PayslipExtractor
    {
        [FunctionName("PayslipExtractor")]
        public static async Task<string> RunOrchestrator(
            [OrchestrationTrigger] IDurableOrchestrationContext context)
        {
            // var outputs = new List<string>();

            // // Replace "hello" with the name of your Durable Activity Function.
            // outputs.Add(await context.CallActivityAsync<string>("CallFormRecognizer", "Tokyo"));
            // outputs.Add(await context.CallActivityAsync<string>("CallFormRecognizer", "Seattle"));
            // outputs.Add(await context.CallActivityAsync<string>("CallFormRecognizer", "London"));

            var x = await context.CallActivityAsync<string>("CallFormRecognizer", "Tokyo");

            // returns ["Hello Tokyo!", "Hello Seattle!", "Hello London!"]
            return x;
        }



        [FunctionName("PayslipExtractor_HttpStart")]
        public static async Task<HttpResponseMessage> HttpStart(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", "post")] HttpRequestMessage req,
            [DurableClient] IDurableOrchestrationClient starter,
            ILogger log)
        {
            // Function input comes from the request content.
            string instanceId = await starter.StartNewAsync("PayslipExtractor", null);

            log.LogInformation($"Started orchestration with ID = '{instanceId}'.");

            return starter.CreateCheckStatusResponse(req, instanceId);
        }



        // // Activities
        // [FunctionName("PayslipExtractor_Hello")]
        // public static string SayHello([ActivityTrigger] string name, ILogger log)
        // {
        //     log.LogInformation($"Saying hello to {name}.");
        //     return $"Hello {name}!";
        // }



    }
}