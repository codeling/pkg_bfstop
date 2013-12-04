#!/bin/bash
name=bfstop
version=1.1.1

pkg_name=pkg_${name}
zipfile_name=${pkg_name}-${version}.zip
src_files="${pkg_name}.xml packages"

rm -f ${zipfile_name}
zip -r ${zipfile_name} ${src_files}

