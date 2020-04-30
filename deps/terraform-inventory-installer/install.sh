#!/usr/bin/env bash

TERRAFORM_INVENTORY_VERSION=0.9
TERRAFORM_INVENTORY_PREFIX=https://github.com/adammck/terraform-inventory/releases/download
TERRAFORM_INVENTORY_URI=${TERRAFORM_INVENTORY_PREFIX}/v${TERRAFORM_INVENTORY_VERSION}/terraform-inventory_${TERRAFORM_INVENTORY_VERSION}_linux_amd64.zip

wget "${TERRAFORM_INVENTORY_URI}" -O tf-inv.zip && \
unzip -o tf-inv.zip && chmod +x terraform-inventory && \
sudo mv terraform-inventory /usr/local/bin && rm -f tf-inv.zip
