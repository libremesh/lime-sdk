#!/bin/bash
. options.conf
[ ! -d "$tmp_dir" ] && mkdir -p "$tmp_dir"

usage() {
	echo "Usage: $0 [-f <feeds.conf.default>] [-d <target>] [-b <target>] [-a]"
	echo "	-a		: download all SDK and IB"
	echo "	-f <file>	: download feeds based on feeds.conf file"
	echo "	-b <target>	: build for target"
	echo "	-d <target>	: build or download target"
}

build_packets() {
	target="$1"
	sdk="$release/$target/sdk"
	
	[ ! -d "$sdk" ] && { 
		echo "You must download first sdk"
		exit 1
	}
	
	cp $feeds_file $sdk/feeds.conf
	(cd $sdk && scripts/feeds update -a)
	(cd $sdk && scripts/feeds install -a)
	(cd $sdk && scripts/feeds uninstall -a)
	(cd $sdk && scripts/feeds install lime-full)
	cp $sdk_config $sdk/.config
	(cd $sdk && make defconfig)
	make -j5 -C $sdk
}

download_feeds() {
	feeds_template="$1"
	output="$feeds_dir"
	rm -f $feeds_file
	[ ! -d "$output" ] && mkdir -p "$output"
	echo "Downloading feeds into $output/"

	cat $feeds_template | grep ^src-git | while read feed; do
		name="$(echo $feed | awk '{print $2}')"
		full_url="$(echo $feed | awk '{print $3}')"
		[ -d $output/$name ] && rm -rf $output/$name
		if echo "$full_url" | grep \;; then
			url="$(echo $full_url | awk -F\; '{print $1}')"
			branch="$(echo $full_url | awk -F\; '{print $2}')"
			git clone $url -b $branch $output/$name
		elif echo "$full_url" | grep \^; then
			url="$(echo $full_url | awk -F\^ '{print $1}')"
			commit="$(echo $full_url | awk -F\^ '{print $2}')"
			git clone $url $output/$name
			( cd $output/$name && git checkout $commit )
		fi
		echo "src-link $name $PWD/$output/$name" >> $feeds_file
	done
	
	[ -d $output/libremesh ] && rm -rf $output/libremesh
	git clone $lime_repo -b $lime_branch $output/libremesh
	echo "src-link libremesh $PWD/$output/libremesh" >> $feeds_file
	
	[ -d $output/libremap ] && rm -rf $output/libremap
	git clone $limap_repo -b $limap_branch $output/libremap
	echo "src-link libremap $PWD/$output/libremap" >> $feeds_file
	
	[ -d $output/lime-ui-ng ] && rm -rf $output/lime-ui-ng
	git clone $limeui_repo -b $limeui_branch $output/lime-ui-ng
	echo "src-link limeui $PWD/$output/lime-ui-ng" >> $feeds_file
}

download_all() {
	cat $targets_list | while read t; do download $t; done
}

download() {
	target="$1"
	[ -z "$target" ] && {
		echo "Download SDK and ImageBuilder files"
		echo "Use: $0 <target>"
		exit 1
	}
	url="$base_url/$target"
	output="$release/$target"
	[ ! -d "$output" ] && mkdir -p "$output"
	
	sdk_file="$(wget -q -O- $url | grep lede-sdk | grep href | awk -F\> '{print $4}' | awk -F\< '{print $1}')"
	echo "Downloading $url/$sdk_file"
	wget -c "$url/$sdk_file" -O "$tmp_dir/$sdk_file"
	tar xxf $tmp_dir/$sdk_file -C $output/
	[ $? -eq 0 ] && {
		rm -rf $output/sdk
		mv $output/lede-sdk* $output/sdk
		#rm -f $TMP/$SDK_FILE
	} || echo "Error installing SDK"
	
	ib_file="$(wget -q -O- $url | grep lede-imagebuilder | grep href | awk -F\> '{print $4}' | awk -F\< '{print $1}')"
	echo "Downloading $url/$ib_file"
	wget -c "$url/$ib_file" -O "$tmp_dir/$ib_file"
	tar xxf $tmp_dir/$ib_file -C $output/
	[ $? -eq 0 ] && {
		rm -rf $output/ib
		mv $output/lede-imagebuilder* $output/ib
		#rm -f $TMP/$IB_FILE
	} || echo "Error installing ImageBuilder"
}



while getopts "ad:f:b:" opt; do
	case $opt in
	a) 
	  download_all
	;;
	d)
	  download $OPTARG
	;;
	f)
	  download_feeds $OPTARG
	;;
	b)
	  build_packets $OPTARG
	;;
	*)
	  echo "Invalid option: -$OPTARG"
	  usage
	;;
  esac
done

