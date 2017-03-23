#!/bin/bash
. options.conf

base_feed="$feeds_dir/base"
echo "Patch will be applied to $base_feed"

[ ! -d $base_feed ] && {
  echo "$base_feed does not exist. Before applying this snippet you must clone the feeds (option -f of cooker)"
  exit 1
}

patch_file="$PWD/$tmp_dir/regdb.patch"

cat > $patch_file << EOF
diff --git a/package/kernel/mac80211/files/regdb.txt b/package/kernel/mac80211/files/regdb.txt
index c4a9b2d15f..ec2c21543a 100644
--- a/package/kernel/mac80211/files/regdb.txt
+++ b/package/kernel/mac80211/files/regdb.txt
@@ -1180,8 +1180,8 @@ country TW: DFS-FCC
 	(5725 - 5850 @ 80), (30)
  
 country TZ:
-	(2402 - 2482 @ 40), (20)
-	(5735 - 5835 @ 80), (30)
+       (2402 - 2484 @ 40), (30)
+       (5150 - 5835 @ 80), (30)
 
 # Source:
 # #914 / 06 Sep 2007: http://www.ucrf.gov.ua/uk/doc/nkrz/1196068874
EOF

( cd $base_feed && git apply $patch_file && {
  echo "Patch applied, now you can use the special channel TZ when you deploy a mesh network on International Waters"
} || echo "Patch does not apply, maybe it is already applied orLEDE source has changed" )
