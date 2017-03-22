# lime-sdk
LibreMesh software development kit. Uses Lede SDK and ImageBuilder to generate LibreMesh packages and firmware.

    Usage: ./cooker [-f ] [-d <target> [--sdk|ib|force]] [-i <target> [--sdk-file=<file>|ib-file=<file>]] 
                    [-b <target> [--no-update|no-link-ib|remote] [--profile=<profile>] [--flavor=<flavor>]]
                    [--download-all|build-all|update-feeds] [--targets|flavors|profiles=<target>] 
                    [-c <target> [--profile=<profile>] [--flavor=<flavor>]] [--help]
    
        --help                    : show full help with examples
        --download-all            : download all SDK and ImageBuilders
        --build-all	              : build SDK for all available tagets
        --cook-all	              : cook firmwares for all available targets (TBD)
        --targets                 : list all officialy supported targets
        --profiles=<target>       : list available hardware profiles for a specific target
        --flavors                 : list available LibreMesh flavors for cooking
        --update-feeds            : update previously downloaded feeds (only works for Git feeds)
        -f                        : download feeds based on feeds.conf.default file. Feeds will be shared among all targets
        -d <target>               : download SDK and ImageBuilder for specific target
           --sdk                  : download only SDK
           --ib                   : download only ImageBuilder
           --force                : force reinstall of SDK and/or ImageBuilder (remove old if exist)
        -i <target>               : install local/custom SDK or ImageBuilder
           --sdk-file=<file>      : specify SDK file to unpack
           --ib-file=<file>       : specify ImageBuilder file to unpack
        -b <target>               : build SDK for specific target and link it to the ImageBuilder
           --no-link-ib           : do not download and link ImageBuilder when building the SDK
           --no-update            : do not update feeds when building SDK
        -c <target>               : cook the firmware for specific target. Can be used with --profile and --flavor
           --profile=<profile>    : use <profile> when cooking firmware (default is all available target profiles)
           --flavor=<flavor>      : use <flavor> when cooking firmware (default generic)
           --remote               : instead of building local SDK packages. Use only remote repositories for cooking
    
    Examples:
    
     - Build packages using the SDK and cook the firmware for target tl-wdr3500-v1 and flavor generic (all in one command)
    
        ./cooker -c ar71xx/generic --flavor=generic --profile=tl-wdr3500-v1
    
     - Cook the firmware without compiling the SDK but using only remote precompiled binaries
    
        ./cooker -c ar71xx/generic --remote --flavor=basic --profile=tl-wdr3500-v1
    
     - Build SDK and cook ar71xx target with all available profiles (step by step)
    
        ./cooker -d ar71xx/generic                    # download SDK and IB 
        ./cooker -f                                   # download and prepare feeds
        ./cooker -b ar71xx/generic --no-update        # build the SDK and link it to IB
        ./cooker -c ar71xx/generic --flavor=generic   # cook the firmware
    
     - PKG can be used to add extra packages when cooking. Also J to parallelize and V to verbose
    
        PKG="luci-app-3g iperf" J=4 V=s ./cooker -c ar71xx/generic

Status: Alpha
