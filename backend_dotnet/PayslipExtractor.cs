using System.Net.Http;
using System.Threading.Tasks;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.DurableTask;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json.Linq;

using System.Text.Json;
using System.Globalization;
using System.Threading;

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

                if(doc.pages > 1) {
                    for (int p=1; p <= doc.pages; p++) {
                        var extract = await context.CallActivityAsync<Extract>("CallOcrCustomModel", new Document(doc.url, p));
                        var validated_extract = await context.CallActivityAsync<Extract>("ValidateExtract", extract);

                        results.Extracts.Add(validated_extract);
                    }
                }
                else {
                    var extract = await context.CallActivityAsync<Extract>("CallOcrCustomModel", doc);
                    var validated_extract = await context.CallActivityAsync<Extract>("ValidateExtract", extract);

                    results.Extracts.Add(validated_extract);
                }
                
            }
                        
            return results.AsJson();
        }



        [FunctionName("PayslipExtractor")]
        public static async Task<HttpResponseMessage> HttpStart(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", "post")] HttpRequestMessage req,
            [DurableClient] IDurableOrchestrationClient starter,
            ILogger log)
        {
            // Change the culuture of the thread currently running
            Thread.CurrentThread.CurrentCulture = CultureInfo.GetCultureInfo("en-AU");
            
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