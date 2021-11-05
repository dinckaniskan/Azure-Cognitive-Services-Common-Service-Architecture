import os
import streamlit as st
import requests

if 'queryUrl' not in st.session_state:
    st.session_state['queryUrl'] = ''

sasToken = os.environ.get('sasToken')
documentRootUri = os.environ.get('documentRootUri')
documentContainer = os.environ.get('documentContainer')
functionRequestToken = os.environ.get('functionRequestToken')


st.set_page_config(
    layout="wide"
)

st.header('OCR with Durable Functions Demo')

useAzure = st.checkbox('Use Azure Endpoint', True)

if useAzure:
    baseUrl = os.environ.get('functionBaseUri')
    st.caption('Requests targeting Azure Durable Functions deployed to Azure')
else:
    baseUrl = 'http://localhost:7071'
    st.caption('Requests targeting local Azure Durable Functions debug session')

selections = [    
    {
        'name': 'Valid Payslip - Single file with single payslip',
        'req_body': {
            "documents": [
                {
                    "url": f"{documentRootUri}/{documentContainer}/valid2.pdf?{sasToken}",
                    "pages": 1
                }
            ]
        }
    },
    {
        'name': 'Invalid Payslip (abn too short) - Single File with single payslip',
        'req_body': {
            "documents": [
                {     
                    "url": f"{documentRootUri}/{documentContainer}/invalid_abn_short.pdf?{sasToken}",
                    "pages": 1
                }
            ]
        }
    },    
    {
        'name': 'Invalid Payslip (abn madeup, not in list of valid abns) - Single File with single payslip',
        'req_body': {
            "documents": [
                {     
                    "url": f"{documentRootUri}/{documentContainer}/invalid_abn_madeup.pdf?{sasToken}",
                    "pages": 1
                }
            ]
        }
    },    
    {
        'name': 'Multiple Paylips - Single file with multiple payslips',
        'req_body': {
            "documents": [
                {
                    "url": f"{documentRootUri}/{documentContainer}/filedrop/valid_multi_page.pdf?{sasToken}",
                    "pages": 2
                }
            ]
        }
    },
    {
        'name': 'Multiple Paylips - Multiple files with single payslip',
        'req_body': {
            "documents": [
                {
                    "url": f"{documentRootUri}/{documentContainer}/filedrop/valid2.pdf?{sasToken}",
                    "pages": 1
                },
                {
                    "url": f"{documentRootUri}/{documentContainer}/filedrop/invalid_abn_madeup.pdf?{sasToken}",
                    "pages": 1
                }
            ]
        }
    },
    {
        'name': 'Upside Down Paylip',
        'req_body': {
            "documents": [
                {
                    "url": f"{documentRootUri}/{documentContainer}/filedrop/upside_down.pdf?{sasToken}",
                    "pages": 1
                }
            ]
        }
    }
]


with st.form("my_form_trigger"):
    selected = st.selectbox('Select sample operation:', selections, format_func=lambda x: x['name'])
    
    # Every form must have a submit button.
    submitted = st.form_submit_button("Start OCR")
    if submitted:
        
        resp = requests.post(f'{baseUrl}/api/PayslipExtractor?code={functionRequestToken}', json=selected['req_body'])
        resp = resp.json()
        
        st.subheader('Started OCR on selected document')
        
        resp

        st.session_state.queryUrl = resp['statusQueryGetUri']

        


with st.form("my_form_poll"):        
    submitted = st.form_submit_button("Poll for Status")
    
    if submitted:

        headers = {
            'Content-Type': 'application/json'
        }

        resp = requests.get(url=st.session_state.queryUrl, headers=headers)
        resp = resp.json()

        if resp['runtimeStatus'] == 'Completed':

            test = []
            for doc in resp['output']['Extracts']:

                test.append(
                    {
                        'Business': doc['Business'],
                        'Employee': doc['Employee'],
                        'ABN': doc['ABN'],
                        'Period From': doc['PeriodFrom'],
                        'Period To': doc['PeriodTo'],
                        'Amount': doc['Amount'],
                        'Result': doc['ExtactResult']
                    })

            # total = resp['output']['total_amount']
            # st.subheader(f'Aggregated Total Amount: {total}')

            
            st.dataframe(test)            
        
        
        st.subheader('RECEIVED RESPONSE')
        resp