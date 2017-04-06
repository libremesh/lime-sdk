#!/bin/bash
. options.conf
OUTDIR="${1:-repository}"
[ ! -d $OUTDIR ] && mkdir -p $OUTDIR
echo "-> Output directory: $OUTDIR"
for link in $OUTDIR/*; do
  unlink $link 2>/dev/null
done
for target in $(cat $targets_list); do
  for arch in $release/$target/sdk/bin/packages/*; do
    [ -d "$arch" ] && {
      echo "-> Creating symlink for $arch"
      ln -s $PWD/$arch $OUTDIR/ 2>/dev/null
    }
  done
done
