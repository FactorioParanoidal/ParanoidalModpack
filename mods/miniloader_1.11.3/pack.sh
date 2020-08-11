#!/bin/sh

ZIP='7z'

function canon_name() {
	dir="$(realpath "$(dirname "$0")")"

	parse_info() {
		v=`grep \"$1\" "$dir"/info.json | head -1`
		v="${v%%\",}"
		v="${v##*\"}"
		echo $v
	}

	name=`parse_info name`
	version=`parse_info version`
	echo "${name}_${version}"
}


moddir="$(realpath $(dirname "$0"))"
tmpdir=$(mktemp -d)
canon_name="$(canon_name)"
zipfile="$PWD/$canon_name.zip"
ln -nsf "$moddir" "$tmpdir/$canon_name"
cd "$tmpdir"

include=$(
cat <<- END
	$canon_name/LICENSE
	$canon_name/changelog.txt
	$canon_name/info.json
	$canon_name/thumbnail.png
	$canon_name/*.lua
	$canon_name/*.md
END
)


dirs=$(ls -d "$canon_name"/*/ | grep -vF "$canon_name/$canon_name" | grep -vF resources)

echo "Zipping to $zipfile:"
for f in $include $dirs
do
	echo $f
done
echo

"$ZIP" a "$zipfile" $include $dirs
