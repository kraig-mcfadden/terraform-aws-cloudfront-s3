.PHONY: default
default:
	terraform init -backend=false
	terraform validate
	rm -rf .terraform
	rm .terraform.lock.hcl
	terraform fmt --recursive
	terraform-docs markdown --output-file README.md .
