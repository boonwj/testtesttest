#!/bin/bash

function rotate_keys {
    kv_name=$1
    kv_resource_group=$2
    kv_secret_name=$3
    sst_name=$4
    sst_resource_group=$5

    echo "Key vault: ${kv_name}"
    echo "Key vault RG: ${kv_resource_group}"
    echo "Key vault secret name: ${kv_secret_name}"
    echo "Storage account: ${sst_name}"
    echo "Storage account RG: ${sst_resource_group}"

    echo "- Refreshing and updating secret with secondary key"
    key2=$(az storage account keys renew --account-name "${sst_name}" --resource-group "${sst_resource_group}" --key secondary --query "[?keyName=='key2'].value" -o tsv)
    az keyvault secret set --name "${kv_secret_name}" --vault-name "${kv_name}" --description "Access key for ${sst_name}" --value "${key2}" -o none

    echo "- Refreshing and updatign secret with primary key"
    key1=$(az storage account keys renew --account-name "${sst_name}" --resource-group "${sst_resource_group}" --key primary --query "[?keyName=='key1'].value" -o tsv)
    az keyvault secret set --name "${kv_secret_name}" --vault-name "${kv_name}" --description "Access key for ${sst_name}" --value "${key1}" -o none
}

rotate_keys "kv-sst-rotate" "rg-kv-sst-rotate-test" "sst-account001-key" "sstaccount001" "rg-kv-sst-rotate-test"
rotate_keys "kv-sst-rotate" "rg-kv-sst-rotate-test" "sst-account002-key" "sstaccount002" "rg-kv-sst-rotate-test"
