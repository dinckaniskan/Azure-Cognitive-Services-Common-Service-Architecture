# Azure-Cognitive-Services-workflow-with-Durable-Functions
Azure Cognitive Services workflow with Durable Functions

# Service definitions
Services may be defines as follows. (only Payslip implemented here yet)
![diagram of sample service](docs/Common%20Service%20Pattern.svg)
## Payslip entity extractor
Extracts specified fields from the specified blob passed to the service

### Request Orchistrator
HTTP request will initiate the durable function orchistration
sample request
example funtion
HTTP POST https://ocrdurablesample.azurewebsites.net/api/orchestrators/Orchestrator
BODY:
```json
 {
"url": "https://deseaisq.blob.core.windows.net/filedrop/valid2.pdf?sp=r&st=2021-10-19T22:53:46Z&se=2022-10-20T06:53:46Z&spr=https&sv=2020-08-04&sr=c&sigAAAAAAAAABBBBBBBBBBBCCCCCCCCCCC",
"pages": 1
}
```

### Response - initial
returns a GUID which is the ID for future requests

### Request - polling for results (not yet complete)
HTTP POST https://ocrdurablesample.azurewebsites.net/api/orchestrators/xxxxxxxxxxxxxxxx

**Sample response**
```json
{
  "name": "Orchestrator",
  "instanceId": "f6bdee37fc1c4b4da59f172f34e5aa",
  "status": "in progress"
}
```
### Request - polling for results (completion)
HTTP POST https://ocrdurablesample.azurewebsites.net/api/orchestrators/xxxxxxxxxxxxxxxx
#### Sample response:
```json
{
  "name": "Orchestrator",
  "instanceId": "f6bdee37fc1c4b4da59f172f34e5aa",
  "runtimeStatus": "Completed",
  "input": "{\"url\": \"https://deseaisq.blob.core.windows.net/filedrop/valid2.pdf?sp=r&st=2021-10-19T22:53:46Z&se=2022-10-20T06:53:46Z&spr=https&sv=2020-08-04&sr=c&sig=XX\", \"pages\": 1}",
  "customStatus": null,
  "output": {
    "processed_docs": [
      {
        "extracted_attributes": {
          "other": null,
          "Amount": 593.76,
          "Period": {
            "From": "08/04/2015",
            "To": "14/04/2015"
          },
          "Business Name": "Good Guy",
          "Employee": "Pete Trusty",
          "ABN": "998877665"
        },
        "url": "https://deseaisq.blob.core.windows.net/filedrop/valid2.pdf?sp=r&st=2021-10-19T22:53:46Z&se=2022-10-20T06:53:46Z&spr=https&sv=2020-08-04&sr=c&sig=XX",
        "page": 1,
        "result": {
          "outcome": "Success.",
          "isDocumentValid": true
        }
      }
    ],
    "total_amount": 593
  },
  "createdTime": "2021-10-26T06:03:00Z",
  "lastUpdatedTime": "2021-10-26T06:03:50Z"
}
```
# Getting started - developers

## Debug Functions Locally

Install VSCode
Install Function Core Tools

F5 to start debug session


## Sample App Locally
`
cd SampleApp
`

### Create Virtual Env and Activate:
`
python -m venv .venv
source .venv/Scripts/activate 
`

### Install dependencies:
`
pip install -r requirements.txt
`

### Run App:
`
: streamlit run app.py
`