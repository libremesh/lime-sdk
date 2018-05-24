#!/bin/bash
. options.conf
OUTDIR="${1:-repository}"
[ ! -d $OUTDIR ] && mkdir -p $OUTDIR
echo "-> Output directory: $OUTDIR"
for link in $OUTDIR/*; do
    unlink $link 2>/dev/null
done
for arch in $release/*/*/sdk/bin/packages/*; do
    [ -d "$arch" ] && {
        echo "-> Creating symlink for $arch"
    ln -s $PWD/$arch $OUTDIR/ 2>/dev/null
}
done
