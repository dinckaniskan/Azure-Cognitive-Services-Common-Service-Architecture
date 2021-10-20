# This function is not intended to be invoked directly. Instead it will be
# triggered by an orchestrator function.
# Before running this sample, please:
# - create a Durable orchestration function
# - create a Durable HTTP starter function
# - add azure-functions-durable to requirements.txt
# - run pip install -r requirements.txt

import logging


def main(extractedValues: dict) -> bool:

    valid_abns = ['345987652']
    
    
    abn = extractedValues['abn']
    period = extractedValues['period']
    amount = extractedValues['amount']
    
    logging.info(abn)
    logging.info(period)
    logging.info(amount)

    if valid_abns.__contains__(abn):
        return True
    else:
        logging.info('BAD FILE DETECTED, ABN NOT VALID')
        return False