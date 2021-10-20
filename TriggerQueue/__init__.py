import logging

import azure.functions as func
import azure.durable_functions as df

async def main(msg: func.QueueMessage, starter: str) -> func.HttpResponse:
    
    message = msg.get_json()

    client = df.DurableOrchestrationClient(starter)    
    instance_id = await client.start_new("Orchestrator", None, message['url'])
    
    logging.info(f"Started orchestration with ID = '{instance_id}'.")

    logging.info('Python queue trigger function processed a queue item: %s', message)