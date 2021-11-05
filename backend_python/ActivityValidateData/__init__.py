# This function is not intended to be invoked directly. Instead it will be
# triggered by an orchestrator function.
# Before running this sample, please:
# - create a Durable orchestration function
# - create a Durable HTTP starter function
# - add azure-functions-durable to requirements.txt
# - run pip install -r requirements.txt

import logging


def main(extractedValues: dict) -> bool:

    valid_abns = ['998877665']
    
    employee = extractedValues['Employee']
    business = extractedValues['Business Name']
    abn = extractedValues['ABN']
    period = extractedValues['Period']
    amount = extractedValues['Amount']
    
    logging.info(employee)
    logging.info(business)
    logging.info(abn)
    logging.info(period)
    logging.info(amount)

    message = "Success."
    isDocumentValid = True
    
    if len(abn) != 9 and isDocumentValid:
        message = f'ERROR: BAD ABN. ABN is not 9 characters. Found {len(abn)}'
        isDocumentValid = False

        logging.info(message)
        

    if (not valid_abns.__contains__(abn)) and isDocumentValid:           
        message = 'ERROR: BAD ABN. ABN not found in valid ABNs list.'
        isDocumentValid = False
        logging.info(message)
        

    return {
            "outcome": message,
            "isDocumentValid": isDocumentValid
        }