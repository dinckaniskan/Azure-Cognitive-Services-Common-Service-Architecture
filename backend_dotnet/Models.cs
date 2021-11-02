using System;
using System.Collections.Generic;
using System.Text.Json;
using System.Text.Json.Serialization;
using Newtonsoft.Json.Linq;

namespace Contoso.Example {


    public class OcrRequest {
        [JsonPropertyName("documents")]
        public List<Document> Documents { get; set; }

    }

    public class Document {
        public string url { get; set; }
        public string pages { get; set; }
    }



    public class ResultsCollection {

        public ResultsCollection(){
            this.Extracts = new List<Extract>();
        }

        public List<Extract> Extracts { get; set; }


        public JObject AsJson(){
            return JObject.Parse(JsonSerializer.Serialize(this));
        }  
    }




    public class Extract {

        private string _business;
        private string _abn;
        private string _employee;
        private DateTime _periodFrom;
        private DateTime _periodTo;
        private Double _amount;
        private string _extactResult;


        public string rawBusiness {get; set; }
        public string rawAbn {get; set; }
        public string rawEmployee {get; set; }
        public string rawPeriodFrom {get; set; }
        public string rawPeriodTo {get; set; }
        public string rawAmount {get; set; }


        public string Business {
            get { return _business; }
            set { 
                _business = value; 
                rawBusiness = value;
            }
        }
        public string ABN {
            get { return _abn; }
            set { 
                _abn = value; 
                rawAbn = value;
            }
        }
        public string Employee {
            get { return _employee; }
            set { 
                _employee = value; 
                rawEmployee = value;
            }
        }
        public Double Amount {
            get { return _amount; }
            set { _amount = value; }
        }
        public string ExtactResult {
            get { return _extactResult; }
            set { 
                _extactResult = value;                
            }
        }

        public DateTime PeriodFrom {
            get { return _periodFrom; }
            set { _periodFrom = value; }
        }

        public DateTime PeriodTo {
            get { return _periodTo; }
            set { _periodTo = value; }
        }


        public void SetAmount(string amount) {
            this.rawAmount = amount;            
            
            Double parsed;
            var result = Double.TryParse(StripSpecialChars(amount), out parsed);
            if(result)
                this._amount = parsed;
            else
                this._amount = -9999999;
        }


        public void SetPeriodFrom(string periodFrom) {            
            this.rawPeriodFrom = periodFrom;
            
            DateTime parsed;
            var result = DateTime.TryParse(periodFrom, out parsed);
            if(result)
                this._periodFrom = parsed;
        }

        public void SetPeriodTo(string periodTo) {
            this.rawPeriodTo = periodTo;
            
            DateTime parsed;
            var result = DateTime.TryParse(periodTo, out parsed);
            if(result)
                this._periodTo = parsed;
        }

   
        
        private static string StripSpecialChars(string value) {
            
            return value.Replace("$","").Replace(" ","").Replace(",","");
        }
    }
}