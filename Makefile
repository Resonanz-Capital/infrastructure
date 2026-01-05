# Makefile for Terraform/Terragrunt Azure Infrastructure

# Variables
ENV ?= dev
ACTION ?= plan

# Help
help:
	@echo "Terraform/Terragrunt Azure Infrastructure Makefile"
	@echo ""
	@echo "Usage:"
	@echo "  make [command]"
	@echo ""
	@echo "Commands:"
	@echo "  help            Show this help message"
	@echo "  validate        Validate the Terraform configuration"
	@echo "  fmt             Format Terraform configuration files"
	@echo "  init            Initialize Terragrunt"
	@echo "  plan            Plan the infrastructure (default target)"
	@echo "  apply           Apply the infrastructure"
	@echo "  destroy         Destroy the infrastructure"
	@echo "  clean           Clean up Terraform files"
	@echo ""
	@echo "Environment variables:"
	@echo "  ENV=dev         Environment to use (dev, stage, prod)"
	@echo "  ACTION=plan     Action to perform (plan, apply, destroy)"

# Validate Terraform configuration
validate:
	@echo "Validating Terraform configuration..."
	terraform fmt -check
	terraform validate

# Format Terraform configuration files
fmt:
	@echo "Formatting Terraform configuration files..."
	terraform fmt -recursive

# Initialize Terragrunt
init:
	@echo "Initializing Terragrunt for $(ENV) environment..."
	cd live/$(ENV) && terragrunt init

# Plan the infrastructure
plan:
	@echo "Planning infrastructure for $(ENV) environment..."
	cd live/$(ENV) && terragrunt plan

# Apply the infrastructure
apply:
	@echo "Applying infrastructure for $(ENV) environment..."
	cd live/$(ENV) && terragrunt apply -auto-approve

# Destroy the infrastructure
destroy:
	@echo "Destroying infrastructure for $(ENV) environment..."
	cd live/$(ENV) && terragrunt destroy -auto-approve

# Clean up Terraform files
clean:
	@echo "Cleaning up Terraform files..."
	find . -type d -name ".terraform" -exec rm -rf {} +
	find . -type f -name ".terraform.lock.hcl" -delete
	find . -type f -name "terraform.tfstate" -delete
	find . -type f -name "terraform.tfstate.backup" -delete
	find . -type f -name "*.tfplan" -delete
	rm -rf .terragrunt-cache

.PHONY: help validate fmt init plan apply destroy clean
