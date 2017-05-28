#!/bin/bash
. options.conf

patch_dir="$feeds_dir/base"
patch_file="mac80211-backports.patch"

echo '
From 135bfb1154b7afa7a814bfeb780b82563c8d0da9 Mon Sep 17 00:00:00 2001
From: Nick Lowe <nick.lowe@gmail.com>
Date: Mon, 27 Mar 2017 10:50:23 +0100
Subject: [PATCH 1/2] hostapd: add legacy_rates option to disable 802.11b data
 rates.

Setting legacy_rates to 0 disables 802.11b data rates.
Setting legacy_rates to 1 enables 802.11b data rates. (Default)

The basic_rate option and supported_rates option are filtered based on this.

The rationale for the change, stronger now than in 2014, can be found in:

https://mentor.ieee.org/802.11/dcn/14/11-14-0099-00-000m-renewing-2-4ghz-band.pptx

The balance of equities between compatibility with b clients and the
detriment to the 2.4 GHz ecosystem as a whole strongly favors disabling b
rates by default.

Signed-off-by: Nick Lowe <nick.lowe@gmail.com>
Signed-off-by: Felix Fietkau <nbd@nbd.name> [cleanup, defaults change]
---
 package/network/services/hostapd/files/hostapd.sh | 28 ++++++++++++++++-------
 1 file changed, 20 insertions(+), 8 deletions(-)

diff --git a/package/network/services/hostapd/files/hostapd.sh b/package/network/services/hostapd/files/hostapd.sh
index 988ebc7757..6fb902e376 100644
--- a/package/network/services/hostapd/files/hostapd.sh
+++ b/package/network/services/hostapd/files/hostapd.sh
@@ -64,6 +64,7 @@ hostapd_common_add_device_config() {
 	config_add_string country
 	config_add_boolean country_ie doth
 	config_add_string require_mode
+	config_add_boolean legacy_rates
 
 	hostapd_add_log_config
 }
@@ -75,12 +76,15 @@ hostapd_prepare_device_config() {
 	local base="${config%%.conf}"
 	local base_cfg=
 
-	json_get_vars country country_ie beacon_int doth require_mode
+	json_get_vars country country_ie beacon_int doth require_mode legacy_rates
 
 	hostapd_set_log_options base_cfg
 
 	set_default country_ie 1
 	set_default doth 1
+	set_default legacy_rates 1
+
+	[ "$hwmode" = "b" ] && legacy_rates=1
 
 	[ -n "$country" ] && {
 		append base_cfg "country_code=$country" "$N"
@@ -88,25 +92,33 @@ hostapd_prepare_device_config() {
 		[ "$country_ie" -gt 0 ] && append base_cfg "ieee80211d=1" "$N"
 		[ "$hwmode" = "a" -a "$doth" -gt 0 ] && append base_cfg "ieee80211h=1" "$N"
 	}
-	[ -n "$hwmode" ] && append base_cfg "hw_mode=$hwmode" "$N"
 
 	local brlist= br
 	json_get_values basic_rate_list basic_rate
-	for br in $basic_rate_list; do
-		hostapd_add_rate brlist "$br"
-	done
+	local rlist= r
+	json_get_values rate_list supported_rates
+
+	[ -n "$hwmode" ] && append base_cfg "hw_mode=$hwmode" "$N"
+	[ "$legacy_rates" -eq 0 ] && set_default require_mode g
+
+	[ "$hwmode" = "g" ] && {
+		[ "$legacy_rates" -eq 0 ] && set_default rate_list "6000 9000 12000 18000 24000 36000 48000 54000"
+		[ -n "$require_mode" ] && set_default basic_rate_list "6000 12000 24000"
+	}
+
 	case "$require_mode" in
-		g) brlist="60 120 240" ;;
 		n) append base_cfg "require_ht=1" "$N";;
 		ac) append base_cfg "require_vht=1" "$N";;
 	esac
 
-	local rlist= r
-	json_get_values rate_list supported_rates
 	for r in $rate_list; do
 		hostapd_add_rate rlist "$r"
 	done
 
+	for br in $basic_rate_list; do
+		hostapd_add_rate brlist "$br"
+	done
+
 	[ -n "$rlist" ] && append base_cfg "supported_rates=$rlist" "$N"
 	[ -n "$brlist" ] && append base_cfg "basic_rates=$brlist" "$N"
 	[ -n "$beacon_int" ] && append base_cfg "beacon_int=$beacon_int" "$N"
-- 
2.12.2

From b6b8851395c24e4cef40e6b25b2f558131543706 Mon Sep 17 00:00:00 2001
From: Matthias Schiffer <mschiffer@universe-factory.net>
Date: Sat, 13 May 2017 16:17:44 +0200
Subject: [PATCH 2/2] mac80211, hostapd: always explicitly set beacon interval

One of the latest mac80211 updates added sanity checks, requiring the
beacon intervals of all VIFs of the same radio to match. This often broke
AP+11s setups, as these modes use different default intervals, at least in
some configurations (observed on ath9k).

Instead of relying on driver or hostapd defaults, change the scripts to
always explicitly set the beacon interval, defaulting to 100. This also
applies the beacon interval to 11s interfaces, which had been forgotten
before. VIF-specific beacon_int setting is removed from hostapd.sh.

Fixes FS#619.

Signed-off-by: Matthias Schiffer <mschiffer@universe-factory.net>
---
 package/kernel/mac80211/Makefile                              |  2 +-
 package/kernel/mac80211/files/lib/netifd/wireless/mac80211.sh | 10 ++++++----
 package/network/services/hostapd/Makefile                     |  2 +-
 package/network/services/hostapd/files/hostapd.sh             |  5 ++---
 4 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/package/kernel/mac80211/Makefile b/package/kernel/mac80211/Makefile
index 47f4aa270f..8ec05a343a 100644
--- a/package/kernel/mac80211/Makefile
+++ b/package/kernel/mac80211/Makefile
@@ -11,7 +11,7 @@ include $(INCLUDE_DIR)/kernel.mk
 PKG_NAME:=mac80211
 
 PKG_VERSION:=2017-01-31
-PKG_RELEASE:=1
+PKG_RELEASE:=2
 PKG_SOURCE_URL:=http://mirror2.openwrt.org/sources
 PKG_BACKPORT_VERSION:=
 PKG_HASH:=75e6d39e34cf156212a2509172a4a62b673b69eb4a1d9aaa565f7fa719fa2317
diff --git a/package/kernel/mac80211/files/lib/netifd/wireless/mac80211.sh b/package/kernel/mac80211/files/lib/netifd/wireless/mac80211.sh
index baa023ecf6..82c374353e 100644
--- a/package/kernel/mac80211/files/lib/netifd/wireless/mac80211.sh
+++ b/package/kernel/mac80211/files/lib/netifd/wireless/mac80211.sh
@@ -268,7 +268,7 @@ mac80211_hostapd_setup_base() {
 			vht_max_mpdu_hw=11454
 		[ "$vht_max_mpdu_hw" != 3895 ] && \
 			vht_capab="$vht_capab[MAX-MPDU-$vht_max_mpdu_hw]"
-			
+
 		# maximum A-MPDU length exponent
 		vht_max_a_mpdu_len_exp_hw=0
 		[ "$(($vht_cap & 58720256))" -ge 8388608 -a 1 -le "$vht_max_a_mpdu_len_exp" ] && \
@@ -566,7 +566,7 @@ mac80211_setup_adhoc() {
 	[ -n "$mcast_rate" ] && wpa_supplicant_add_rate mcval "$mcast_rate"
 
 	iw dev "$ifname" ibss join "$ssid" $freq $ibss_htmode fixed-freq $bssid \
-		${beacon_int:+beacon-interval $beacon_int} \
+		beacon-interval $beacon_int \
 		${brstr:+basic-rates $brstr} \
 		${mcval:+mcast-rate $mcval} \
 		${keyspec:+keys $keyspec}
@@ -646,7 +646,9 @@ mac80211_setup_vif() {
 				esac
 
 				freq="$(get_freq "$phy" "$channel")"
-				iw dev "$ifname" mesh join "$mesh_id" freq $freq $mesh_htmode ${mcval:+mcast-rate $mcval}
+				iw dev "$ifname" mesh join "$mesh_id" freq $freq $mesh_htmode \
+					${mcval:+mcast-rate $mcval} \
+					beacon-interval $beacon_int
 			fi
 
 			for var in $MP_CONFIG_INT $MP_CONFIG_BOOL $MP_CONFIG_STRING; do
@@ -698,7 +700,7 @@ drv_mac80211_setup() {
 		country chanbw distance \
 		txpower antenna_gain \
 		rxantenna txantenna \
-		frag rts beacon_int htmode
+		frag rts beacon_int:100 htmode
 	json_get_values basic_rate_list basic_rate
 	json_select ..
 
diff --git a/package/network/services/hostapd/Makefile b/package/network/services/hostapd/Makefile
index f3aa94b6ea..b7cc6b9c34 100644
--- a/package/network/services/hostapd/Makefile
+++ b/package/network/services/hostapd/Makefile
@@ -7,7 +7,7 @@
 include $(TOPDIR)/rules.mk
 
 PKG_NAME:=hostapd
-PKG_RELEASE:=2
+PKG_RELEASE:=3
 
 PKG_SOURCE_URL:=http://w1.fi/hostap.git
 PKG_SOURCE_PROTO:=git
diff --git a/package/network/services/hostapd/files/hostapd.sh b/package/network/services/hostapd/files/hostapd.sh
index 6fb902e376..32c09c647b 100644
--- a/package/network/services/hostapd/files/hostapd.sh
+++ b/package/network/services/hostapd/files/hostapd.sh
@@ -76,7 +76,7 @@ hostapd_prepare_device_config() {
 	local base="${config%%.conf}"
 	local base_cfg=
 
-	json_get_vars country country_ie beacon_int doth require_mode legacy_rates
+	json_get_vars country country_ie beacon_int:100 doth require_mode legacy_rates
 
 	hostapd_set_log_options base_cfg
 
@@ -121,7 +121,7 @@ hostapd_prepare_device_config() {
 
 	[ -n "$rlist" ] && append base_cfg "supported_rates=$rlist" "$N"
 	[ -n "$brlist" ] && append base_cfg "basic_rates=$brlist" "$N"
-	[ -n "$beacon_int" ] && append base_cfg "beacon_int=$beacon_int" "$N"
+	append base_cfg "beacon_int=$beacon_int" "$N"
 
 	cat > "$config" <<EOF
 driver=$driver
@@ -710,7 +710,6 @@ wpa_supplicant_add_network() {
 	}
 	local beacon_int brates mrate
 	[ -n "$bssid" ] && append network_data "bssid=$bssid" "$N$T"
-	[ -n "$beacon_int" ] && append network_data "beacon_int=$beacon_int" "$N$T"
 
 	local bssid_blacklist bssid_whitelist
 	json_get_values bssid_blacklist bssid_blacklist
-- 
2.12.2
' > $patch_dir/$patch_file

[ ! -f $patch_dir/$patch_file ] && echo "-> Patch $patch_dir/$patch_file not found" && exit 1
(cd $patch_dir  && git apply $patch_file) && echo "Patches applied"

rm $patch_dir/$patch_file 2>/dev/null
