# lime-sdk
LibreMesh software development kit. Uses Lede SDK and ImageBuilder to generate LibreMesh packages and firmware.

    Usage: ./build.sh [-f <feeds.conf.default>] [-d <target>] [-b <target>] [--download-all|build-all]
              [--targets|flavors|profiles] [-c <target> --profile=<profile> --flavor=<flavor>]
    
        --download-all            : download all SDK and ImageBuilders
        --build-all	              : build SDK for all available tagets
        --cook-all	              : cook firmwares for all available targets (TBD)
        --targets                 : list all officialy supported targets
        --profiles=<target>       : list available hardware profiles for a specific target
        --profile=<profile>       : use <profile> when cooking firmware (default is all available target profiles)
        --flavors                 : list available LibreMesh flavors for cooking
        --flavor=<flavor>         : use <flavor> when cooking firmware (default generic)
        --update-feeds            : update previously downloaded feeds (only works with Git feeds)
        -f <feeds.conf>           : download feeds based on feeds.conf file. Feeds will be shared among all targets
        -b <target>               : build specific target SDK
        -d <target>               : download SDK and IB for specific target
        -c <target>               : cook the firmware for specific target. Can be used with --profile and --flavor
    
    Example of usage for building ar71xx target:
    
        ./build.sh -d ar71xx/generic
        ./build.sh -f feeds.conf.default
        ./build.sh -b ar71xx/generic
        ./build.sh -c ar71xx/generic --profile=tl-wdr3500-v1 --flavor=generic
    


Status: Alpha
