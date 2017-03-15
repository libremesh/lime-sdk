# lime-sdk
Lime software development kit. Uses Lede SDK and ImageBuilder to generate LibreMesh packages and firmware.

    Usage: ./build.sh [-f <feeds.conf.default>] [-d <target>] [-b <target>] [-a]
    	-a		: download all SDK and IB
    	-f <file>	: download feeds based on feeds.conf file
    	-b <target>	: build target
    	-d <target>	: download SDK and IB for target
    
    Example of usage for building ar71xx target:
      ./build.sh -d ar71xx/generic
      ./build.sh -f feeds.conf.default
      ./build.sh -b ar71xx/generic

Status: In development
