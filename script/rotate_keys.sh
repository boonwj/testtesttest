#!/bin/bash

function rotate_keys {
    kv_name=$1
    kv_secret_name=$2
    sst_name=$3
    sst_resource_group=$4

    echo "Key vault: ${kv_name}, Secret Name: ${kv_secret_name}"
    echo "Storage account: ${sst_name}, Resource Group: ${sst_resource_group}"

    echo "- Refreshing and updating secret with secondary key"
    key2=$(az storage account keys renew --account-name "${sst_name}" --resource-group "${sst_resource_group}" --key secondary --query "[?keyName=='key2'].value" -o tsv)
    az keyvault secret set --name "${kv_secret_name}" --vault-name "${kv_name}" --description "Access key for ${sst_name}" --value "${key2}" -o none

    echo "- Refreshing and updating secret with primary key"
    key1=$(az storage account keys renew --account-name "${sst_name}" --resource-group "${sst_resource_group}" --key primary --query "[?keyName=='key1'].value" -o tsv)
    az keyvault secret set --name "${kv_secret_name}" --vault-name "${kv_name}" --description "Access key for ${sst_name}" --value "${key1}"
}

rotate_keys "kv-sst-rotate" "sst-account001-key" "sstaccount001" "rg-kv-sst-rotate-test"
rotate_keys "kv-sst-rotate-fail" "sst-account002-key" "sstaccount002" "rg-kv-sst-rotate-test"
