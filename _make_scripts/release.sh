#!/bin/bash
SCRIPT=`realpath $0`
SCRIPT_PATH=`dirname $SCRIPT`
BUILD_PATH=$SCRIPT_PATH/../build
if [[ $# -lt 1 ]]
then
    >&2 echo must give release version as argument
    exit 1
fi
RELEASE_VERSION=$1

if GIT_DIR=$SCRIPT_PATH/../.git git rev-parse $RELEASE_VERSION >/dev/null 2>&1
then
    >&2 echo tag $RELEASE_VERSION already exists
    exit 1
fi

rm -rf ../build

github-release release \
    --user byrnedo \
    --repo dockdash \
    --tag $RELEASE_VERSION	\
    --name "$RELEASE_VERSION" \
    --description "$RELEASE_VERSION" \
    --pre-release

git pull origin

$SCRIPT_PATH/create_release_artifacts.sh

for artifact in $(ls -1 -d $BUILD_PATH/dockdash-$RELEASE_VERSION-*.{zip,deb})
do
    github-release upload \
        --user byrnedo \
        --repo dockdash \
        --tag $RELEASE_VERSION \
        --file $artifact \
        --name $(basename $artifact)
done
