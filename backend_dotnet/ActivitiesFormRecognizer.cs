using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.DurableTask;
using Microsoft.Extensions.Logging;

using Azure;
using Azure.AI.FormRecognizer;  
using Azure.AI.FormRecognizer.Models;
using Azure.AI.FormRecognizer.Training;

using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;

namespace Contoso.Example
{
    public static class ActivitiesFormRecognizer
    {
        private static readonly string endpoint = "PASTE_YOUR_FORM_RECOGNIZER_ENDPOINT_HERE";
        private static readonly string apiKey = "PASTE_YOUR_FORM_RECOGNIZER_SUBSCRIPTION_KEY_HERE";
        private static readonly AzureKeyCredential credential = new AzureKeyCredential(apiKey);
        

        [FunctionName("CallOcrStandardModel")]
        public static string CallOcrStandardModel([ActivityTrigger] string name, ILogger log)
        {
            log.LogInformation($"Calling std model with {name}.");

            return $"Hello {name}!";
        }


        [FunctionName("CallOcrCustomModel")]
        public static string CallOcrCustomModel([ActivityTrigger] string name, ILogger log)
        {
            log.LogInformation($"Calling custom model with {name}.");

            return $"Hello {name}!";
        }
    }
}