from os import write
import streamlit as st
import requests

if 'queryUrl' not in st.session_state:
    st.session_state['queryUrl'] = ''

st.set_page_config(
    layout="wide"
)

st.header('OCR with Durable Functions Demo')

useAzure = st.checkbox('Use Azure Endpoint', True)

if useAzure:
    baseUrl = 'https://ocrdurablesample.azurewebsites.net'
    st.caption('Requests targeting Azure Durable Functions deployed to Azure')
else:
    baseUrl = 'http://localhost:7071'
    st.caption('Requests targeting local Azure Durable Functions debug session')

selections = [    
    {
        'name': 'Valid Payslip - Single file with single payslip',
        'req_body': {
            'url': 'https://deseaisq.blob.core.windows.net/filedrop/valid2.pdf?sp=r&st=2021-10-19T22:53:46Z&se=2022-10-20T06:53:46Z&spr=https&sv=2020-08-04&sr=c&sig=O%2Fypezh%2BvnVbaOEiSK1UtLEb9dyjsDecSOvg29VUdEA%3D',
            'pages': 1
        }
    },
    {
        'name': 'Invalid Payslip (abn too short) - Single File with single payslip',
        'req_body': {        
            'url': 'https://deseaisq.blob.core.windows.net/filedrop/invalid_abn_short.pdf?sp=r&st=2021-10-19T22:53:46Z&se=2022-10-20T06:53:46Z&spr=https&sv=2020-08-04&sr=c&sig=O%2Fypezh%2BvnVbaOEiSK1UtLEb9dyjsDecSOvg29VUdEA%3D',
            'pages': 1
        }
    },    
    {
        'name': 'Invalid Payslip (abn madeup, not in list of valid abns) - Single File with single payslip',
        'req_body': {        
            'url': 'https://deseaisq.blob.core.windows.net/filedrop/invalid_abn_madeup.pdf?sp=r&st=2021-10-19T22:53:46Z&se=2022-10-20T06:53:46Z&spr=https&sv=2020-08-04&sr=c&sig=O%2Fypezh%2BvnVbaOEiSK1UtLEb9dyjsDecSOvg29VUdEA%3D',
            'pages': 1
        }
    },    
    {
        'name': 'Multiple Paylips - Single file with multiple payslips',
        'req_body': {
            'url': 'https://deseaisq.blob.core.windows.net/filedrop/valid_multi_page.pdf?sp=r&st=2021-10-19T22:53:46Z&se=2022-10-20T06:53:46Z&spr=https&sv=2020-08-04&sr=c&sig=O%2Fypezh%2BvnVbaOEiSK1UtLEb9dyjsDecSOvg29VUdEA%3D',
            'pages': 2 
        }   
    },
    {
        'name': 'Multiple Paylips - Multiple files with single payslip',
        'req_body': [
            {
                "url": "https://deseaisq.blob.core.windows.net/filedrop/valid2.pdf?sp=r&st=2021-10-19T22:53:46Z&se=2022-10-20T06:53:46Z&spr=https&sv=2020-08-04&sr=c&sig=O%2Fypezh%2BvnVbaOEiSK1UtLEb9dyjsDecSOvg29VUdEA%3D",
                "pages": 1
            },
            {
                'url': 'https://deseaisq.blob.core.windows.net/filedrop/invalid_abn_madeup.pdf?sp=r&st=2021-10-19T22:53:46Z&se=2022-10-20T06:53:46Z&spr=https&sv=2020-08-04&sr=c&sig=O%2Fypezh%2BvnVbaOEiSK1UtLEb9dyjsDecSOvg29VUdEA%3D',
                "pages": 1
            }
        ]
    }
]


with st.form("my_form_trigger"):
    selected = st.selectbox('Select sample operation:', selections, format_func=lambda x: x['name'])
    
    # Every form must have a submit button.
    submitted = st.form_submit_button("Start OCR")
    if submitted:
        
        resp = requests.post(f'{baseUrl}/api/orchestrators/Orchestrator', json=selected['req_body'])
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
            for doc in resp['output']['processed_docs']:

                test.append(
                    {
                        'business_name': doc['extracted_attributes']['Business Name'],
                        'employee': doc['extracted_attributes']['Employee'],
                        'abn': doc['extracted_attributes']['ABN'],
                        'period_from': doc['extracted_attributes']['Period']['From'],
                        'period_to': doc['extracted_attributes']['Period']['To'],
                        'amount': doc['extracted_attributes']['Amount'],
                        'result': doc['result']['outcome']
                    })

            total = resp['output']['total_amount']
            st.subheader(f'Aggregated Total Amount: {total}')

            
            st.dataframe(test)            
        
        
        st.subheader('RECEIVED RESPONSE')
        resp