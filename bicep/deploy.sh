rgName=servicesexample1
az group create -n $rgName -l australiaeast
az deployment group create --template-file ./main.bicep --resource-group $rgName