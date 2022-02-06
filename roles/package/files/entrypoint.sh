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
for app in $apps; do printf "\t- ${blu}%s${end}\n" "$(basename $app)"; done

mkdir -p "$PKG_DIR"

for app in $apps; do
	app_name=$(basename "$app")
	printf "\n\nWorking on ${cyn}%-20s${end} (located at '${grn}%s${end}')\n" "$app_name" "$app"
	package="$PKG_DIR/$app_name"
	printf "  - Preparing distribution directory ${cyn}%s${end}\n" "$package"
	# Ensure existing & empty target dir
	rm -rf "$package"
	mkdir -p "$package"
	# Copy plain app content to distribution dir
	cp -r "$app" "$PKG_DIR"
	# Remove stuff thats ignored for packages
	for ignore in $SPL_IGNORE; do
		find "$package" -name "$ignore" ! -wholename "**/README.md" | xargs rm -rf {} \;
	done
	# For non-Agent applications (not placed on forwarders) remove the local folder
	if [[ "$app_name" != *"Agent"* ]]; then
		find "$package" -name "local" -type d | xargs rm -rf {} \;
	fi
	# Fix ownership and baseline mod for fresh copied apps
	chown -R splunk. $package
	find $package -type d -exec chmod 755 {} \;
	find $package -type d -exec chmod -R 700 {} \;
	find $package -type f -exec chmod -R 644 {} \;
	find $package/default $package/static -type f -exec chmod -R 600 {} \; >/dev/null 2>&1 # supress, as it must not exist
	find $package/bin/ -type f -exec chmod 655 -R {} \; >/dev/null 2>&1 # supress, as it must not exist
	find $package -type d -name static -exec chmod 710 {} \; >/dev/null 2>&1 # supress, as it must not exist
	find $package -type f -name app.manifest -exec chmod 600 {} \;

	# Regenerate app manifest based on information of app.conf
	slim --quiet generate-manifest --update -o "$package/app.manifest" "$package"
	# describe app and its dependencies
	slim --quiet describe -o "${package}_description.txt" "$package" # >/dev/null 2>&1
	# Validate the application with appinspect
	slim --quiet validate "${package}"
	slim --quiet package -o "$PKG_DIR" "$package" || continue
	if [[ "$app_name" == *"Agent"* ]]; then
		splunk-appinspect inspect "$package" \
			--excluded-tags cloud \
			--data-format junitxml \
			--output-file "$package"_appinspect.xml \
			--generate-feedback \
			--log-file "$package"_appinspect.log >"$package"_appinspect.log
		result=$?
	else
		splunk-appinspect inspect "$package" \
			--data-format junitxml \
			--output-file "$package"_appinspect.xml \
			--generate-feedback \
			--log-file "$package"_appinspect.log >"$package"_appinspect.log
		result=$?
	fi
	if [ "$result" != 0 ]; then
		printf "  - Appinspect ${red}FAILED${end} processing.\n"
		continue
	else
		printf "  - Appinspect ${grn}finished${end} processing.\n    See the ${blu}results${end} here:\n\n"
	fi
	cat "$package"_appinspect.log | sed 's/^/      /g'
	sed -i 's/testsuite name="Splunk AppInspect"/testsuite name="'$app_name' AppInspect"/g' "$package"_appinspect.xml
	junit2html "$package"_appinspect.xml "$package"_appinspect.html
	printf "  - About to delete files in application folder.\n"
	rm -rf "$package"/*
	printf "  - Moving packaging and vetting result files to app directory\n"
	find $PKG_DIR -name "$app_name*" -type f -exec mv "{}" "$package"/ \; >/dev/null 2>&1
	mv inspect.yml "$package"/AppInspect.yml
	chmod -R 755 $package
	chown $MYUSER:$MYUSER -R /dist/
done
