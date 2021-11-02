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

using Microsoft.Extensions.Configuration; 


namespace Contoso.Example
{
    public static class ActivitiesFormRecognizer
    {
        private static readonly string endpoint = System.Environment.GetEnvironmentVariable("formrecognizer_endpoint");
        private static readonly string apiKey = System.Environment.GetEnvironmentVariable("formrecognizer_key");
        private static readonly string modelId = System.Environment.GetEnvironmentVariable("formrecognizer_model_id");
        

        [FunctionName("CallOcrStandardModel")]
        public static string CallOcrStandardModel([ActivityTrigger] string name, ILogger log)
        {
            log.LogInformation($"Calling std model with {name}.");

            return $"Hello {name}!";
        }


        [FunctionName("CallOcrCustomModel")]
        public static async Task<Extract> CallOcrCustomModel([ActivityTrigger] Document doc, ILogger log)
        {            

            log.LogInformation($"Calling custom model with {doc.url} model id {modelId}.");
            
            var recognizerClient = GetFormRecognizerClient();
        
            var options = new RecognizeCustomFormsOptions() { IncludeFieldElements=true };
            options.Pages.Add(doc.pages);
            
            RecognizeCustomFormsOperation operation = await recognizerClient.StartRecognizeCustomFormsFromUriAsync(modelId, new Uri(doc.url), options);
            Response<RecognizedFormCollection> operationResponse = await operation.WaitForCompletionAsync();
            RecognizedFormCollection forms = operationResponse.Value;
            

            var extract = new Extract();

            foreach (RecognizedForm form in forms)
            {
                log.LogInformation($"Form of type: {form.FormType}");

                if (form.FormTypeConfidence.HasValue)
                    log.LogInformation($"Form type confidence: {form.FormTypeConfidence.Value}");

                log.LogInformation($"Form was analyzed with model with ID: {form.ModelId}");
                
                foreach (FormField field in form.Fields.Values)
                {
                    log.LogInformation($"Field '{field.Name}': ");

                    if (field.Name == "Business Name")
                        extract.Business = field.ValueData.Text;

                    if (field.Name == "Amount")
                        extract.SetAmount(field.ValueData.Text);

                    if (field.Name == "ABN")
                        extract.ABN = field.ValueData.Text;

                    if (field.Name == "Employee")                
                        extract.Employee = field.ValueData.Text;
                    
                    if (field.Name == "Period.To")
                        extract.SetPeriodTo(field.ValueData.Text);
                    
                    if (field.Name == "Period.From")
                        extract.SetPeriodFrom(field.ValueData.Text);


                    // if (field.LabelData != null)
                    // {
                    //     log.LogInformation($"  Label: '{field.LabelData.Text}'");
                    // }

                    // log.LogInformation($"  Value: '{field.ValueData.Text}'");
                    // log.LogInformation($"  Confidence: '{field.Confidence}'");
                }

                // // Iterate over tables, lines, and selection marks on each page
                // foreach (var page in form.Pages)
                // {
                //     for (int i = 0; i < page.Tables.Count; i++)
                //     {
                //         log.LogInformation($"Table {i + 1} on page {page.Tables[i].PageNumber}");
                //         foreach (var cell in page.Tables[i].Cells)
                //         {
                //             log.LogInformation($"  Cell[{cell.RowIndex}][{cell.ColumnIndex}] has text '{cell.Text}' with confidence {cell.Confidence}");
                //         }
                //     }
                //     log.LogInformation($"Lines found on page {page.PageNumber}");
                //     foreach (var line in page.Lines)
                //     {
                //         log.LogInformation($"  Line {line.Text}");
                //     }

                //     if (page.SelectionMarks.Count != 0)
                //     {
                //         log.LogInformation($"Selection marks found on page {page.PageNumber}");
                //         foreach (var selectionMark in page.SelectionMarks)
                //         {
                //             log.LogInformation($"  Selection mark is '{selectionMark.State}' with confidence {selectionMark.Confidence}");
                //         }
                //     }
                // }
            }
                        
            return extract;
        }


        private static FormRecognizerClient GetFormRecognizerClient()
        {
            var client = new FormRecognizerClient(new Uri(endpoint), new AzureKeyCredential(apiKey));
            
            return client;
        }

        private static FormTrainingClient GetFormTrainingClient()
        {
            // var client = new FormRecognizerClient(new Uri(endpoint), credential);
            var client = new FormTrainingClient(new Uri(endpoint), new AzureKeyCredential(apiKey));
            
            return client;
        }
    }
}