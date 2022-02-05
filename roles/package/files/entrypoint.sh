#!/bin/bash
# set -e
red=$'\e[1;31m'
grn=$'\e[1;32m'
yel=$'\e[1;33m'
blu=$'\e[1;34m'
mag=$'\e[1;35m'
cyn=$'\e[1;36m'
end=$'\e[0m'

if [[ -z "${MYUSER}" ]]; then
	MYUSER=$(id -u)
fi
if [[ -z "${APP_DIR}" ]]; then
	APP_DIR="/apps"
fi
if [[ -z "${PKG_DIR}" ]]; then
	PKG_DIR="/dist/apps"
fi
if [[ -z "${SPL_IGNORE}" ]]; then
	SPL_IGNORE=".git* *azure-pipelines.yml .pre-commit-config.yaml local.meta *.rst LICENSE __pycache__"
fi

printf "\n\n${grn}Splunk${end} - ${mag}Application Packaging & Validation${end}.\n"
printf "\n%-30s \t'${yel}%s${end}'\n%-30s \t'${yel}%s${end}'\n\n" \
	"- Packaging directory:" "${PKG_DIR}" \
	"- Application directory:" "${APP_DIR}"

apps=$(find "$APP_DIR" -type f -wholename '**/default/app.conf' -exec echo {} \; | sed 's/\/default\/app.conf//g')

printf "\n${grn}Applications${end} to process:\n"
