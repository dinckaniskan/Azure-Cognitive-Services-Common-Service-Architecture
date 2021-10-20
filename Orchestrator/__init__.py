# This function is not intended to be invoked directly. Instead it will be
# triggered by an HTTP starter function.
# Before running this sample, please:
# - create a Durable activity function (default name is "Hello")
# - create a Durable HTTP starter function
# - add azure-functions-durable to requirements.txt
# - run pip install -r requirements.txt

import logging
import json

import azure.functions as func
import azure.durable_functions as df


def orchestrator_function(context: df.DurableOrchestrationContext):
    file_sas_url = context.get_input()

    logging.info(f"INPUT {file_sas_url}!")

    extractedValues = yield context.call_activity('ActivityCallFormRecognizer', file_sas_url)

    results = []
    for doc in extractedValues:
        result = yield context.call_activity('ActivityValidateData', doc['items'])
        results.append(result)
        

    logging.info([extractedValues, results])
    return [extractedValues, results]

main = df.Orchestrator.create(orchestrator_function)