SHELL := /bin/bash

PWD := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

TERRAFORM_INVENTORY_VERSION ?= 0.9
TERRAFORM_INVENTOR_PREFIX ?= https://github.com/adammck/terraform-inventory/releases/download
TERRAFORM_INVENTORY_URI ?= $(TERRAFORM_INVENTOR_PREFIX)/v$(TERRAFORM_INVENTORY_VERSION)/terraform-inventory_$(TERRAFORM_INVENTORY_VERSION)_linux_amd64.zip

.PHONY: fetch-terraform-inventory
fetch-terraform-inventory:
	wget $(TERRAFORM_INVENTORY_URI) -O tf-inv.zip && \
	unzip -o tf-inv.zip && chmod +x terraform-inventory && \
	sudo mv terraform-inventory /usr/local/bin && rm -f tf-inv.zip

