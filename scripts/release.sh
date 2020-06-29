#!/bin/bash

function check_error() {
    if [[ $? != "0" ]]; then
        echo "An error occurred. Release Canceled"
        exit
    fi
}

VERSION=$1
EXISTS=`git tag -l $VERSION`
BRANCH=`git branch --show-current`

# Semantic Regex
VERSION_REGEX=v[0-9]+.[0-9]+.[0-9]+

# Do we have version parameter? REQUIRED
if [ -z "$VERSION" ]; then
    echo "Missing Version (e.g. ./scripts/release.sh v0.0.1)"
    exit
fi

# Verify version
[[ $VERSION =~ ^$VERSION_REGEX$ ]]

if [[ $? == 1 ]]; then
    echo "Invalid version. Expecting semantic versioning string with 'v' prefix (e.g. v0.0.1). https://semver.org/"
    exit
fi

# Check our current branch
if [[ $BRANCH != "main" ]]; then
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

# Make sure the user has push capabilities to main
while true; do
    read -p "Are you an administrator who can push to main without a PR (if unsure type no) [yes|no]?" yn
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

# Make sure the user actually wants to craft a release
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

# Run the release!

# Check if we have the changelog directory, if not -- don't run it
if [ -d ".chglog" ]; then
    git-chglog --next-tag $VERSION -o CHANGELOG.md
    check_error

    # Commit the changelog file
    echo "Committing and pushing CHANGELOG.md"
    git commit -m 'changelog' CHANGELOG.md
    check_error

    # Push the changelog file to main
    git push
    check_error
fi

if [ -z "$NOTE" ]; then
    echo "Creating Tag"
    git tag $VERSION
else
    echo "Creating Annotated Tag"
    git tag -a $VERSION -m "$NOTE"
fi

echo "Pushing Release"
git push origin $VERSION
check_error
