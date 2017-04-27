# lime-sdk cooker
LibreMesh **software development kit** uses the [LEDE](https://lede-project.org/docs/start) SDK and ImageBuilder to generate (**cook**) LibreMesh packages and firmware. If you want to create your own LibreMesh flavor because you need some specific configuration or you just want to have control over your binaries, the cooker is your friend!

Basic usage example for cooking a firmware for TpLink 4300:
`./cooker -c ar71xx/generic --flavor=lime_default --profile=tl-wdr4300-v1`

## Targets, profiles and flavors
LibreMesh can be used on many different devices (target and profile) and can be packed in many different ways (flavors), depending on your needs. To this end, it is important to choose the right options for building your firmware.

To generate a firmware, the _-c_ option must be used (**c**ook). But it requires to specify at least the target and subtarget of your router and optionally (recommended) the profile and flavor.
`./cooker -c <target/subtarget> --profile=<profile name> --flavor=<flavor name>`

For instance, this will work for a TpLink WDR4300:
`./cooker -c ar71xx/generic --profile=tl-wdr4300-v1 --flavor=lime_default`

##### Target 
Target references to the router architecture, usually depends on the manufactor and the set of chips used for building the hardware. Therefore, you must know the target and subtarget before using cooker. As we use LEDE, this information can be found here https://lede-project.org/toh/start. The most common targets are currently _ar71xx/generic_ (Atheros) and _ramips/mt7620_ (Ramips). Once we know the target, we must find the specific profile.

To see the list of available targets execute:
`./cooker --targets`

##### Profile
The profile is the specific brand/model of the router. Each target has a list of hardware profiles than can be choosed. Cooker build all profiles from a target by default, but it is better if your find and choose the specific profile.

To see the list of available profiles for a specific target execute: 
`./cooker --profiles=<target/subtarget>`

For instance: 
`./cooker --profiles=ar71xx/generic`

##### Flavor
LibreMesh is a modular system, so it can be cooked on many different ways. There are some predefined that we call _flavor_, however anyone can create its own set of packets and options (for instance the default flavors include _bmx6_ and _batman-adv_ as routing protocols, but you might create other kinds of setup).

One of the most important things regarding the flavor is the internal flash size of your router. This must be taken into account when choosing a flavor.

Currently there are three main flavors:
  * **lime_default:** the recommended for routers with more than 4MB of flash. It includes all required and optional software.
  * **lime_mini:** the recommended for routers of 4MB, made for end-users, includes a minimal web interface, but new software cannot be installed (opkg is not available).
  * **lime_zero:** for advanced users, it does not include web interface, just the basic software to mesh the network but it does include opkg, so new software can be installed.

## Building and cooking
These are two different steps. **Building** means to compile and prepare all the required packages for LibreMesh. To **cook** means taking the packages (depending on the flavor) and generating the firmware ready to install on your device.

The standard steps to generate a firmware would be: firstly build and secondly cook, like this:
`./cooker -b ar71xx/generic`
`./cooker -c ar71xx/generic --profile=tl-wdr4300-v1 --flavor=lime_default`

However, cooker is smart enough to detect the missing steps and transparently execute them. If we choose to cook before building, it will automatically build before cooking. Therefore, for debugging purposes it is better to execute the steps separately.

On the other hand, if you do not want to build locally (since it requires some special software installed on your Linux machine), you can just cook using the online precompiled binaries.

##### Building locally or fetch remote?
Cooker can locally build the LibreMesh packages or fetch the remote precompiled ones. For most users there is no real need for building, since using the remote ones might be a better (and fast) option. To remotelly fetch the packages the special option _--remote_ must be used when cooking, like this:

`./cooker -c ar71xx/generic --profile=tl-wdr4300-v1 --flavor=lime_default --remote`

## Communities
It is not required to create and/or use a community profile. But if you are constantly cooking LibreMesh for your network and you need a specific configuration, you might want to spend some time creating a community profile. This will make things easier and better coordinated for your community.

A community is mainly a set of files you want to include in the output firmware. For instance, if you want to pre-configure the WiFi SSID, mode or channels, you might want to include a specific _/etc/config/lime-defaults_ file as shown in this article http://libremesh.org/docs/config.html.

Also _/etc/shadow_ for setting an initial root password or _/etc/uci-defaults/_ one-time executed scripts might be useful for your setup.

The default way to create or use a community is to use this Git repository https://github.com/libremesh/network-profiles (ask for writing access in the users mailing list). The directory structure of the Git repository is: 
`/<community name>/<device profile name>/<files and directories>`

Both community and device profile names can be any of your choice (must exist!) , since they are only used for identifying it. When executing a cook order, you can specify the community profile like this:
`./cooker -c ar71xx/generic --profile=tl-wdr4300-v1 --flavor=lime_default --community=CommunityName/ProfileName`

## Advanced help

    Usage: ./cooker [-f [--force]] [-d <target> [--sdk|ib|force]] [-i <target> [--sdk-file=<file>|ib-file=<file>]] 
                    [-b <target> [--no-update|no-link-ib|remote] [--profile=<profile>] [--flavor=<flavor>]]
                    [--download-all|build-all|update-feeds] [--targets|flavors|communities|profiles=<target>] 
                    [-c <target> [--profile=<profile>] [--flavor=<flavor>] [--community=<name/profile>]] [--help]
    
        --help                     : show full help with examples
        --download-all             : download all SDK and ImageBuilders
        --build-all	               : build SDK for all available tagets
        --cook-all	               : cook firmwares for all available targets (TBD)
        --targets                  : list all officialy supported targets
        --profiles=<target>        : list available hardware profiles for a specific target
        --flavors                  : list available LibreMesh flavors for cooking
        --communities              : list available community profiles
        --update-feeds             : update previously downloaded feeds (only works for Git feeds)
        -f                         : download feeds based on feeds.conf.default file. Feeds will be shared among all targets
           --force                 : force reinstall of feeds (remove old if exist)
        -d <target>                : download SDK and ImageBuilder for specific target
           --sdk                   : download only SDK
           --ib                    : download only ImageBuilder
           --force                 : force reinstall of SDK and/or ImageBuilder (remove old if exist)
        -i <target>                : install local/custom SDK or ImageBuilder
           --sdk-file=<file>       : specify SDK file to unpack
           --ib-file=<file>        : specify ImageBuilder file to unpack
        -b <target>                : build SDK for specific target and link it to the ImageBuilder
           --no-link-ib            : do not download and link ImageBuilder when building the SDK
           --no-update             : do not update feeds when building SDK
        -c <target>                : cook the firmware for specific target. Can be used with next options
           --profile=<profile>     : use <profile> when cooking firmware (default is all available target profiles)
           --flavor=<flavor>       : use <flavor> when cooking firmware (default lime_default)
           --remote                : instead of building local SDK packages. Use only remote repositories for cooking
           --community=<name/prof> : specify which network community and profile device to use (if any)


    Examples:
    
     - Build packages using the SDK and cook the firmware for target tl-wdr3500-v1 and flavor generic (all in one command)
    
        ./cooker -c ar71xx/generic --flavor=lime_default --profile=tl-wdr3500-v1
    
     - Cook the firmware without compiling the SDK but using only remote precompiled binaries
    
        ./cooker -c ar71xx/generic --remote --flavor=lime_basic --profile=tl-wdr3500-v1
    
     - Build SDK and cook ar71xx target with all available profiles (step by step)
    
        ./cooker -d ar71xx/generic                        # download SDK and IB 
        ./cooker -f                                       # download and prepare feeds
        ./cooker -b ar71xx/generic                        # build the SDK and link it to IB
        ./cooker -c ar71xx/generic --flavor=lime_default  # cook the firmware
    
     - If you want to use an existing community network profile, specify it when cooking (in addition to the device profile)
    
        ./cooker -c ar71xx/generic --flavor=lime_default --community=quintanalibre.org.ar/comun --profile=tl-wdr3500-v1
    
     - PKG can be used to add extra packages when cooking. Also J to parallelize and V to verbose
    
        PKG="luci-app-3g iperf" J=4 V=s ./cooker -c ar71xx/generic

