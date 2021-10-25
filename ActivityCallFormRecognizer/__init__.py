# This function is not intended to be invoked directly. Instead it will be
# triggered by an orchestrator function.
# Before running this sample, please:
# - create a Durable orchestration function
# - create a Durable HTTP starter function
# - add azure-functions-durable to requirements.txt
# - run pip install -r requirements.txt

import os
import logging
from azure.core.credentials import AzureKeyCredential
from azure.ai.formrecognizer import DocumentAnalysisClient


def main(formUrl: list) -> str:

    endpoint = os.environ.get("formrecognizer_endpoint")
    key = os.environ.get("formrecognizer_key")
    model_id = os.environ.get("formrecognizer_model_id")

    # formUrl = "https://deseaisq.blob.core.windows.net/filedrop/payslip.pdf?sp=r&st=2021-10-19T22:53:46Z&se=2022-10-20T06:53:46Z&spr=https&sv=2020-08-04&sr=c&sig=O%2Fypezh%2BvnVbaOEiSK1UtLEb9dyjsDecSOvg29VUdEA%3D"


    document_analysis_client = DocumentAnalysisClient(
        endpoint=endpoint, credential=AzureKeyCredential(key)
    )

    # Make sure your document's type is included in the list of document types the custom model can analyze
    poller = document_analysis_client.begin_analyze_document_from_url(model_id, formUrl['url'], pages=formUrl['page'])
    result = poller.result()

    resp = []

    print(result.documents)

    for idx, document in enumerate(result.documents):
        logging.info("--------Analyzing document #{}--------".format(idx + 1))
        logging.info("Document has type {}".format(document.doc_type))
        logging.info("Document has confidence {}".format(document.confidence))
        logging.info("Document was analyzed by model with ID {}".format(result.model_id))
                
        docitems = {}
        for name, field in document.fields.items():
            field_value = field.value if field.value else field.content
            logging.info(f"......found field {name} of type '{field.value_type}' with value '{field_value}' and with confidence {field.confidence}")

            # Handle period
            if name == 'Period':
                item = field_value.split(' to ')
                docitems[name] = {
                    'From': item[0],
                    'To': item[1]
                    }
            else:
                docitems[name] = field_value


            # Handle amount
            if name == 'Amount':
                docitems[name] = float(field_value.replace('$', ''))


        doc = {            
            'extracted_attributes': docitems
        }
        
        # resp.append(doc)

    logging.info(doc)

    return doc