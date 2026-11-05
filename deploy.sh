#!/bin/bash
#
# Builds the package zip. With the paths of a plugin (codeling/bfstop) and a
# component (codeling/com_bfstop) checkout, it first builds their zips with
# their own deploy.sh and puts them into packages/ - check out the tags of the
# release there. Either way, the zips in packages/ must be of the version of
# this package, or nothing is built: a package must never ship the extensions
# of an earlier release.
#
# Usage: ./deploy.sh [<plugin checkout> <component checkout>]
set -euo pipefail

name=bfstop
version=2.0.0

pkg_name=pkg_${name}
zipfile_name=${pkg_name}-${version}.zip
src_files="${pkg_name}.xml script.php packages"
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$here"

build() {
	# $1: checkout, $2: name of its zip (deploy.sh zip), $3: name in packages/
	local checkout
	checkout="$(cd "$1" && pwd)"
	rm -f "$checkout/$2"
	(cd "$checkout" && ./deploy.sh zip > /dev/null)
	mv "$checkout/$2" "packages/$3"
}

if [ $# -eq 2 ]; then
	build "$1" "bfstop-${version}.zip" plg_sys_bfstop.zip
	build "$2" "com_bfstop-${version}.zip" com_bfstop.zip
elif [ $# -ne 0 ]; then
	echo "Usage: $0 [<plugin checkout> <component checkout>]" >&2
	exit 1
fi

for zip in packages/plg_sys_bfstop.zip packages/com_bfstop.zip; do
	zip_version="$(unzip -p "$zip" bfstop.xml | sed -n 's:.*<version>\(.*\)</version>.*:\1:p' | head -n 1)"
	if [ "$zip_version" != "$version" ]; then
		echo "$zip is version '$zip_version', not $version: build it from the checkouts (see the usage above)" >&2
		exit 1
	fi
done

rm -f ${zipfile_name}
zip -r ${zipfile_name} ${src_files}
