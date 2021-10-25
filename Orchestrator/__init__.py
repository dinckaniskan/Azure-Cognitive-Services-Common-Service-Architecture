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
    input_data = context.get_input()
    logging.info(f"INPUT {input_data}!")
    
    resp = {}
    processed_docs = []
    
    if type(input_data) == list:
        for list_item in input_data:
            for page in range(1, (list_item['pages']+1)):
                logging.info(f'working page: {page}')
                
                data = {
                    "url": list_item['url'], 
                    "page": page
                    }

                extractedValues = yield context.call_activity('ActivityCallFormRecognizer', data)
                extractedValues.update(data)
                processed_docs.append(extractedValues)

    elif type(input_data) == dict:
        for page in range(1, (input_data['pages']+1)):
            logging.info(f'working page: {page}')
            
            data = {
                "url": input_data['url'], 
                "page": page
                }

            extractedValues = yield context.call_activity('ActivityCallFormRecognizer', data)
            extractedValues.update(data)
            processed_docs.append(extractedValues)


    aggs = 0
    for doc in processed_docs:        
            doc['result'] = yield context.call_activity('ActivityValidateData', doc['extracted_attributes'])

            if doc['result']['isDocumentValid']:
                logging.info(doc['extracted_attributes']['Amount'])
                aggs += int(doc['extracted_attributes']['Amount'])
                      

    resp['processed_docs'] = processed_docs
    resp['total_amount'] = aggs

    logging.info(extractedValues)
    return resp

main = df.Orchestrator.create(orchestrator_function)