#!/bin/bash

echo "Updating release branch from remote"
git switch release
git pull
echo "Merging master to release"
git merge master
echo "Pushing release changes"
git push
echo "Switching back to master branch before FMTK version increment commit"
git switch master

echo "Done postpublishing."
