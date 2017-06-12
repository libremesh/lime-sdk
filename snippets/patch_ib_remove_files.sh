#!/bin/bash
. options.conf
RELEASE="$release"

echo '--- Makefile2	2017-03-30 07:44:01.402299190 +0300
+++ Makefile	2017-03-30 07:43:19.065015108 +0300
@@ -123,6 +123,14 @@
 ifneq ($(USER_FILES),)
 	$(MAKE) copy_files
 endif
+ifneq ($(FILES_REMOVE),)
+	@echo
+	@echo Remove useless files
+
+	while read filename; do	\
+	    rm -rfv "$(TARGET_DIR)$$filename"; \
+	done < $(FILES_REMOVE);
+endif
 	$(MAKE) package_postinst
 	$(MAKE) build_image
 	$(MAKE) checksum
' > tmp/ib_remove_files.patch

[ ! -d $RELEASE ] && echo "Dir $RELEASE not found" && exit 1
find $RELEASE/ -maxdepth 3 -type d -name 'ib' | while read d; do
    echo "Patching $d..."
    patch -p1 $d/Makefile < tmp/ib_remove_files.patch
done
