#!/usr/bin/env bash
set -euo pipefail

## CONFIGURAÇÃO DO TERRAFORM
DOWNLOAD_URL="https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"

echo "Instalando Terraform ${TERRAFORM_VERSION}..."
curl -sfL "$DOWNLOAD_URL" -o /tmp/terraform.zip
unzip -q /tmp/terraform.zip -d ~/bin && export PATH="$HOME/bin:$PATH"

##########

cd ./iac/

echo "::group::Terraform initialization"
terraform init -backend=false
echo "::endgroup::"

echo "::add-mask::${AWS_ACCESS_KEY_ID:-LINUXTIPSTRIGUSGIRUS}"

if terraform validate -no-color; then
  echo "::notice::Terraform validation succeeded"
  echo "tf_result=success" >> "$GITHUB_OUTPUT"
else
  echo "::error file=ec2.tf,line=1,col=1::Terraform validation failed"
  echo "tf_result=failure" >> "$GITHUB_OUTPUT"
  exit 1
fi

echo "::warning::Remember to run 'terraform fmt -check' in a separate step."