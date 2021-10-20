from azure.core.credentials import AzureKeyCredential
from azure.ai.formrecognizer import DocumentAnalysisClient

endpoint = "https://deseaifr.cognitiveservices.azure.com/"
key = "86eef64f98fc4c1eb55b0bdd8e9c391f"
model_id = "testtrain"

formUrl = "https://deseaisq.blob.core.windows.net/filedrop/payslip.pdf?sp=r&st=2021-10-19T22:53:46Z&se=2022-10-20T06:53:46Z&spr=https&sv=2020-08-04&sr=c&sig=O%2Fypezh%2BvnVbaOEiSK1UtLEb9dyjsDecSOvg29VUdEA%3D"


document_analysis_client = DocumentAnalysisClient(
    endpoint=endpoint, credential=AzureKeyCredential(key)
)

# Make sure your document's type is included in the list of document types the custom model can analyze
poller = document_analysis_client.begin_analyze_document_from_url(model_id, formUrl)
result = poller.result()

for idx, document in enumerate(result.documents):
    print("--------Analyzing document #{}--------".format(idx + 1))
    print("Document has type {}".format(document.doc_type))
    print("Document has confidence {}".format(document.confidence))
    print("Document was analyzed by model with ID {}".format(result.model_id))
    for name, field in document.fields.items():
        field_value = field.value if field.value else field.content
        print("......found field of type '{}' with value '{}' and with confidence {}".format(field.value_type, field_value, field.confidence))


# iterate over tables, lines, and selection marks on each page
for page in result.pages:
    print("\nLines found on page {}".format(page.page_number))
    for line in page.lines:
        print("...Line '{}'".format(line.content.encode('utf-8')))
    for word in page.words:
        print(
            "...Word '{}' has a confidence of {}".format(
                word.content.encode('utf-8'), word.confidence
            )
        )
    for selection_mark in page.selection_marks:
        print(
            "...Selection mark is '{}' and has a confidence of {}".format(
                selection_mark.state, selection_mark.confidence
            )
        )

for i, table in enumerate(result.tables):
    print("\nTable {} can be found on page:".format(i + 1))
    for region in table.bounding_regions:
        print("...{}".format(i + 1, region.page_number))
    for cell in table.cells:
        print(
            "...Cell[{}][{}] has content '{}'".format(
                cell.row_index, cell.column_index, cell.content.encode('utf-8')
            )
        )
print("-----------------------------------")
