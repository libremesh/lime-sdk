#!/bin/bash
. options.conf
RELEASE="$release"
[ ! -d $RELEASE ] && echo "Dir $RELEASE not found" && exit 1
[ ! -d keys ] && mkdir keys
[ ! -f keys/key-build ] || [ ! -f keys/key-build.pub ] && {
    echo "Signing keys not available. For signing packages you must create and copy them into keys/ directory."
    echo "File names must be keys/key-build (private) and keys/key-build.pub (public)"
    exit 0
}
find $RELEASE/ -maxdepth 3 -type d -name 'sdk' | while read d; do
    echo "Installing keys on $d..."
    cp -f keys/key-build* $d/
done
cat $sdk_config | sed s/CONFIG_SIGNED_PACKAGES=n/CONFIG_SIGNED_PACKAGES=y/g > ${sdk_config}.local
