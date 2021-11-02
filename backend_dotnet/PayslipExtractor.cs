using System.Collections.Generic;
using System.Net.Http;
using System.Threading.Tasks;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.DurableTask;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json.Linq;
using System;

using System.Text.Json;
using System.Text.Json.Serialization;

namespace Contoso.Example
{
    public static class PayslipExtractor
    {

        [FunctionName("PayslipExtractorWorkflow")]
        public static async Task<JObject> RunOrchestrator(
            [OrchestrationTrigger] IDurableOrchestrationContext context,
            ILogger log)            
        {

            var inputs = context.GetInput<OcrRequest>();
 
            var results = new ResultsCollection();

            foreach(Document doc in inputs.Documents) {
                var extract = await context.CallActivityAsync<Extract>("CallOcrCustomModel", doc);
                var validated_extract = await context.CallActivityAsync<Extract>("ValidateExtract", extract);

                results.Extracts.Add(validated_extract);
            }
                        
            return results.AsJson();
        }



        [FunctionName("PayslipExtractor")]
        public static async Task<HttpResponseMessage> HttpStart(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", "post")] HttpRequestMessage req,
            [DurableClient] IDurableOrchestrationClient starter,
            ILogger log)
        {

            // Collect input values from request
            string body = await req.Content.ReadAsStringAsync();            
            
            var inputs = JsonSerializer.Deserialize<OcrRequest>(body);
                            
            // Function input comes from the request content.
            string instanceId = await starter.StartNewAsync("PayslipExtractorWorkflow", inputs);

            log.LogInformation($"Started orchestration with ID = '{instanceId}'.");

            return starter.CreateCheckStatusResponse(req, instanceId);
        }
    }
}