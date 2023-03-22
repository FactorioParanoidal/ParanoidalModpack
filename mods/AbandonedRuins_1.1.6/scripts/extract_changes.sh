#!/usr/bin/bash
# TLDR: Take the changelog of the latest version and convert it into a format that github markdown understands.
#
# ignore first 3 lines and match until line starts with ----, remove said line, remove two spaces at start of all lines,
#  add linebreak in front of line if it starts with a non-space but ignore the first line
sed -n -e '4,/^----/p' changelog.txt | sed -e '/^----/d' | sed 's/^\s\s//g' | sed -E '2,$s/^(\S)/\n\1/g' >> changes.txt 
