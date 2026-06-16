#!/bin/bash

CHANGELOG="changelog.txt"

echo "Changing date format from ISO to 'dd. mm. yyyy'"
if test -f ./$CHANGELOG; then
	sed -b -i -e 's/\([0-9]\{4\}\)-\([0-9][0-9]\)-\([0-9][0-9]\)/\3\. \2\. \1/' ./$CHANGELOG
fi
