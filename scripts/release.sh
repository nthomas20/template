#!/bin/bash

VERSION=$1
EXISTS=`git tag -l $VERSION`
BRANCH=`git branch --show-current`

# Do we have version parameter? REQUIRED
if [ -z "$VERSION" ]; then
    echo "Missing Version (e.g. release.sh v0.0.1)"
    exit
fi

# Check our current branch
if [[ $BRANCH != "master" ]]; then
    echo "Could not possibly release from $BRANCH"
    exit
else
    echo Pulling to make sure we have the latest
    git pull
fi

# Have we already made this release?
if [[ $VERSION == $EXISTS ]]; then
    echo Version already exists
    exit
fi

while true; do
    read -p "Are you sure you wish to release $VERSION [yes|no]?" yn
    case $yn in
        ["yes"]* )
            break;;
        ["no"]* )
            echo "Release Canceled";
            exit;;
        * )
            echo "Please answer only yes or no";;
    esac
done

read -p "Enter a one-line release note if you like, otherwise press enter: " NOTE

git-chglog --next-tag $VERSION -o CHANGELOG.md

echo Committing Changelog and pushing
git commit -m 'changelog' CHANGELOG.md
git push

if [ -z "$NOTE" ]; then
    echo "Creating Tag"
    git tag $VERSION
else
    echo "Creating Annotated Tag"
    git tag -a $VERSION -m "$NOTE"
fi

echo Pushing Release
git push origin $VERSION
