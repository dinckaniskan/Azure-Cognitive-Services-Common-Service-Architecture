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
    public static class ActivitiesValidation
    {

        [FunctionName("ValidateExtract")]
        public static string ValidateExtract([ActivityTrigger] string name, ILogger log)
        {
            log.LogInformation($"Called validate with {name}.");
            
            return $"Hello {name}!";
        }
    }
}