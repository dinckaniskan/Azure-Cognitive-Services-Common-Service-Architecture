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

using System.Text.RegularExpressions;

namespace Contoso.Example
{
    public static class ActivitiesValidation
    {

        [FunctionName("ValidateExtract")]
        public static Extract ValidateExtract([ActivityTrigger] Extract extract, ILogger log)
        {
            log.LogInformation($"Called validate");

            bool isValid = true;
            string outcome = "ok";

            if (!IsValidAbn(extract.ABN) && isValid) {
                isValid = false;
                outcome = "invlid ABN";
            }

            if (!IsValidPeriod(extract.PeriodFrom, extract.PeriodTo) && isValid) {
                isValid = false;
                outcome = "invlid period";
            }
            
            extract.ExtactResult = outcome;

            return extract;
        }
    
        
        private static bool IsValidPeriod(DateTime from, DateTime to)
        {
            if(to.Date > from.Date)
                return true;
            else
                return false;
        }
        
        private static bool IsValidAbn(string abn)
        {
            // abn = abn?.Replace(" ", ""); // strip spaces

            // int[] weight = { 10, 1, 3, 5, 7, 9, 11, 13, 15, 17, 19 };
            // int weightedSum = 0;

            // //0. ABN must be 11 digits long
            // if (string.IsNullOrEmpty(abn) || !Regex.IsMatch(abn, @"^\d{11}$"))
            // {
            //     return false;
            // }

            // //Rules: 1,2,3                                  
            // for (int i = 0; i < weight.Length; i++)
            // {
            //     weightedSum += (int.Parse(abn[i].ToString()) - (i == 0 ? 1 : 0)) * weight[i];
            // }

            // //Rules: 4,5                 
            // return weightedSum % 89 == 0;


            abn = abn?.Replace(" ", ""); // strip spaces

            // int[] weight = { 10, 1, 3, 5, 7, 9, 11, 13, 15, 17, 19 };
            // int weightedSum = 0;

            //0. ABN must be 11 digits long
            if (string.IsNullOrEmpty(abn) || !Regex.IsMatch(abn, @"^\d{9}$"))
            {
                return false;
            }
            else
                return true;

            // //Rules: 1,2,3                                  
            // for (int i = 0; i < weight.Length; i++)
            // {
            //     weightedSum += (int.Parse(abn[i].ToString()) - (i == 0 ? 1 : 0)) * weight[i];
            // }

            // //Rules: 4,5                 
            // return weightedSum % 89 == 0;
        }
    }
}