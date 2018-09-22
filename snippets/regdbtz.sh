#!/bin/bash
. options.conf

base_feed="$feeds_dir/base"
echo "Patch will be applied to $base_feed"

[ ! -d $base_feed ] && {
  echo "$base_feed does not exist. Before applying this snippet you must clone the feeds (option -f of cooker)"
  exit 1
}

patch_file="$PWD/$tmp_dir/999-tz_hack.patch"

cat > $patch_file << EOF

--- a/db.txt
+++ b/db.txt
@@ -1209,8 +1209,8 @@ country TW: DFS-FCC
 	(57000 - 66000 @ 2160), (40)
  
 country TZ:
-	(2402 - 2482 @ 40), (20)
-	(5735 - 5835 @ 80), (30)
+	(2402 - 2484 @ 40), (30)
+	(5150 - 5835 @ 80), (30)
 
 # Source:
 # #914 / 06 Sep 2007: http://www.ucrf.gov.ua/uk/doc/nkrz/1196068874
EOF

( cd $base_feed && mv $patch_file package/firmware/wireless-regdb/patches/ && {
  echo "Patch copied, now you can use the special channel TZ when you deploy a mesh network on International Waters"
} || echo "Patch copy error, maybe it is already applied or OpenWRT source has changed" )
