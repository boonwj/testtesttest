#!/bin/bash

function rotate_keys_w_kv {
    sst_name=$1
    sst_resource_group=$2
    kv_name=$3
    kv_secret_name=$4

    echo "Key vault: ${kv_name}, Secret Name: ${kv_secret_name}"
    echo "Storage account: ${sst_name}, Resource Group: ${sst_resource_group}"

    echo "- Refreshing and updating secret with secondary key"
    key2=$(az storage account keys renew --account-name "${sst_name}" --resource-group "${sst_resource_group}" --key secondary --query "[?keyName=='key2'].value" -o tsv)
    az keyvault secret set --name "${kv_secret_name}" --vault-name "${kv_name}" --description "Access key for ${sst_name}" --value "${key2}" -o none

    echo "- Refreshing and updating secret with primary key"
    key1=$(az storage account keys renew --account-name "${sst_name}" --resource-group "${sst_resource_group}" --key primary --query "[?keyName=='key1'].value" -o tsv)
    az keyvault secret set --name "${kv_secret_name}" --vault-name "${kv_name}" --description "Access key for ${sst_name}" --value "${key1}"
}

function rotate_keys {
    sst_name=$1
    sst_resource_group=$2
    echo "Storage account: ${sst_name}, Resource Group: ${sst_resource_group}"
    echo "- Refreshing secondary key"
    key2=$(az storage account keys renew --account-name "${sst_name}" --resource-group "${sst_resource_group}" --key secondary --query "[?keyName=='key2'].value" -o tsv)
    echo "- Refreshing primary key"
    key1=$(az storage account keys renew --account-name "${sst_name}" --resource-group "${sst_resource_group}" --key primary --query "[?keyName=='key1'].value" -o tsv)
}

rotate_keys_w_kv "sstaccount001" "rg-kv-sst-rotate-test" "kv-sst-rotate" "sst-account001-key"
rotate_keys "sstaccount002" "rg-kv-sst-rotate-test"
