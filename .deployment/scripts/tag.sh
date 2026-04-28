#!/bin/bash
TAG_STYLE="$1"
TAG_PARAMETER="$2"

if [ $TAG_STYLE == 'delta' ]; then
    TARGET=$TAG_PARAMETER
    TAG_NAME=$TARGET"_"$(date +%Y%m%d)
    TAG_MESSAGE="Release for $TARGET released on $(date +%Y%m%d)."
else
    RELEASE_VERSION="$TAG_PARAMETER"
    TAG_NAME="$RELEASE_VERSION"
    TAG_MESSAGE="Release $RELEASE_VERSION released on $(date +%Y%m%d)."
fi

git tag -a "$TAG_NAME" -m "$TAG_MESSAGE"
git push origin "$TAG_NAME"
