# lime-sdk cooker
LibreMesh **software development kit** uses the [OpenWRT](https://openwrt.org) SDK and ImageBuilder to generate (**cook**) LibreMesh packages and firmware. If you want to create your own LibreMesh flavor because you need some specific configuration or you just want to have control over your binaries, the cooker is your friend!

Basic usage example for cooking a firmware for TpLink 4300:

`./cooker -c ar71xx/generic --flavor=lime_default --profile=tl-wdr4300-v1`

## Using cooker online with Chef

cooker can be used also via [Chef](https://chef.libremesh.org/) web interface. Its source code can be found [here](https://github.com/libremesh/chef/). 

## Preparing the local environment

### Building in running system

Before using lime-sdk, make sure your Linux system has the required dependencies installed. 

Install build dependencies, for example on a Debian/Ubuntu based Linux distribution install the following packages:

```
sudo apt-get install subversion zlib1g-dev gawk flex unzip bzip2 gettext build-essential libncurses5-dev libncursesw5-dev libssl-dev binutils cpp psmisc docbook-to-man wget git
```

For other systems, you might follow these instructions (look for _Examples of Package Installations_) https://lede-project.org/docs/guide-developer/install-buildsystem

### Building in docker container

Install [Docker](https://www.docker.com/get-docker) and run the following command:

	cd lime-sdk
	sudo docker build -t cooker .
	sudo docker run -v "$(pwd)":/app cooker --<parameters>

## Targets, profiles and flavors
LibreMesh can be used on many different devices (target and profile) and can be packed in many different ways (flavors), depending on your needs. To this end, it is important to choose the right options for building your firmware.

To generate a firmware, the _-c_ option must be used (**c**ook). But it requires to specify at least the target and subtarget of your router and optionally (recommended) the profile and flavor.

`./cooker -c <target/subtarget> --profile=<profile name> --flavor=<flavor name>`

For instance, this will work for a TpLink WDR4300:

`./cooker -c ar71xx/generic --profile=tl-wdr4300-v1 --flavor=lime_default`

##### Target 
Target references to the router architecture, usually depends on the manufactor and the set of chips used for building the hardware. Therefore, you must know the target and subtarget before using cooker. As we use OpenWRT, this information can be found here https://wiki.openwrt.org/toh/start. The most common targets are currently _ar71xx/generic_ (Atheros) and _ramips/mt7620_ (Ramips). Once we know the target, we must find the specific profile.

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

#### Using custom SDK and/or IB files
Custom local SDK and IB files can be used (instead of fetching official OpenWRT sources). Must be specified before building or cooking ("-b" or "-c").

`./cooker -f`
`./cooker -i ar71xx/generic --ib-file=myOwnImageBuilder.tar.xz --sdk-file=myOwnSDK.tar.xz`
`./cooker -b ar71xx/generic --force-local`
`./cooker -c ar71xx/generic --profile=tl-wdr4300-v1 --flavor=lime_default --force-local`

Do not forget to use _force-local_ option to use your own SDK target packages (kernel signature will be different from remote sources).


## Communities
It is not required to create and/or use a community profile. But if you are constantly cooking LibreMesh for your network and you need a specific configuration, you might want to spend some time creating a community profile. This will make things easier and better coordinated for your community.

A community is mainly a set of files you want to include in the output firmware. For instance, if you want to pre-configure the WiFi SSID, mode or channels, you might want to include a specific _/etc/config/lime-defaults_ file as shown in this article http://libremesh.org/docs/en_config.html.

Also _/etc/shadow_ for setting an initial root password or _/etc/uci-defaults/_ one-time executed scripts might be useful for your setup.

The default way to create or use a community is to use this Git repository https://github.com/libremesh/network-profiles (ask for writing access in the users mailing list). The directory structure of the Git repository is: 

`/<community name>/<device profile name>/<files and directories>`

Both community and device profile names can be any of your choice (must exist!) , since they are only used for identifying it. When executing a cook order, you can specify the community profile like this:

`./cooker -c ar71xx/generic --profile=tl-wdr4300-v1 --flavor=lime_default --community=CommunityName/ProfileName`

A community profile might include a special file named PACKAGES on the root of the profile directory (_CommunityName/ProfileName/PACKAGES_) to specify a list of extra packages which must be added to the firmware image.

## Using development branch

If you want to get the last OpenWRT source because it includes some new feature or it supports some new hardware, you can use the lime-sdk branch named _develop_. However as OpenWRT source is changing daily, we cannot assure the correct working of the firmware.
It is recommended to start with a new Git clone instead of reuse an existing one. Once the lime-sdk source is cloned, change the branch: `git checkout develop`

## Add your own feed repository

If you want to compile and/or cook your own feed package repository, you can follow one of the following methods.

##### For a permanent build environment

If it is a permanent change on your cooker setup, better add your repository (or modify the existing ones) to the feeds file

    cp feeds.conf.default feeds.conf.default.local
    vim feeds.conf.default.local

Edit and save the new created file _feeds.conf.default.local_ and force the reinstall of the feeds

    ./cooker -f --force

Crete and add to the SDK config file the new packages you want to include (if any)

    cp libremesh.sdk.config libremesh.sdk.config.local
    echo "CONFIG_PACKAGE_myNewPackage=m" >> libremesh.sdk.config.local

Add your new flavor (or modify the existing ones)

    cp flavors.conf flavors.conf.local
    vim flavors.conf.local

Finally build and cook as usual but adding also your new packages

    ./cooker -b ar71xx/generic
    ./cooker -c ar71xx/generic --profile=tl-wdr4300-v1 --flavor=lime_new_flavor

##### For a casual cooking on a existing feed repository

Download the standard feeds (if not previously downloaded)

    ./cooker -f

Modify the source code of the existing feed

    cd feeds/libremesh
    git checkout feature/somethingToTest

Build the code and cook as usual

    ./cooker -b ar71xx/generic
    ./cooker -c ar71xx/generic --profile=tl-wdr4300-v1 --flavor=lime_default --extra-pkg="someExtraPackage?"

## Forking lime-sdk for your community

If you like to manage your own set of flavors, options and/or repositories, you might fork the lime-sdk code to your own Git repository. To preserve the compatibility with the official source (so merges can be easily done), none of the original files must be modified.

To this end, _cooker_ will look first for the files named _.local_ and will use them instead. Therefore make a copy of _options_ and _flavors_.

    cp options.conf options.conf.local
    cp flavors.conf flavors.conf.local

Modify them as your own wish and add them to the Git repository.

    git add *.local
    git commit -m 'Add local options and flavors'
    git push

Time to time, if you want to update the code with the official one you might add a new remote and perform a merge.

    git remote add official https://github.com/libremesh/lime-sdk.git
    git fetch official
    git merge official/master
    git push origin/master

## Advanced help

    Usage: ./cooker [-f [--force]] [-d <target> [--sdk|ib|force]] [-i <target> [--sdk-file=<file>|ib-file=<file>]] 
                    [--download-all|build-all|update-feeds] [--targets|flavors|communities|update-communities|profiles=<target>] 
                    [-b <target> [-j<N>] [--no-update|no-link-ib|remote|clean|force-local|package=<pkg>]]
                    [-c <target> [--profile=<profile>|no-update|remote|flavor=<flavor>|community=<path>|extra-pkg=<list>]] 
                    [--help]
    
        --help                     : show full help with examples
        --download-all             : download all SDK and ImageBuilders
        --build-all	               : build SDK for all available tagets
        --cook-all	               : cook firmwares for all available targets and profiles
        --targets                  : list all officialy supported targets
        --profiles=<target>        : list available hardware profiles for a specific target
        --flavors                  : list available LibreMesh flavors for cooking
        --communities              : list available community profiles
        --update-communities       : update or download community profiles
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
           -j<N>                   : number of threads to use when building (recommended N=#cores+1)
           --no-link-ib            : do not download and link ImageBuilder when building the SDK
           --no-update             : do not update feeds when building SDK
           --clean                 : clean sources before compiling
           --package=<pkg_name>    : build only a package (and its dependencies)
           --force-local           : force installation of all local SDK compiled packages when cooking firmware
        -c <target>                : cook the firmware for specific target. Can be used with next options
           --profile=<profile>     : use <profile> when cooking firmware (default is all available target profiles)
           --flavor=<flavor>       : use <flavor> when cooking firmware (default lime_default)
           --extra-pkg=<pkg_list>  : specify extra packages (separated by spaces) for including into the output firmware
           --remote                : instead of building local SDK packages. Use only remote repositories for cooking
           --community=<name/prof> : specify which network community and profile device to use (if any)
           --no-update             : do not update package list when cooking (requires patch_ib_no_update.sh snippet)
    
    Examples:
    
     - Build packages using the SDK and cook the firmware for target tl-wdr3500-v1 and flavor generic (all in one command)
    
        ./cooker -c ar71xx/generic --flavor=lime_default --profile=tl-wdr3500-v1
    
     - Cook the firmware without compiling the SDK but using only remote precompiled binaries
    
        ./cooker -c ar71xx/generic --remote --flavor=lime_mini --profile=tl-wdr3500-v1
    
     - Build SDK and cook ar71xx target with all available profiles (step by step)
    
        ./cooker -d ar71xx/generic                        # download SDK and IB 
        ./cooker -f                                       # download and prepare feeds
        ./cooker -b ar71xx/generic                        # build the SDK and link it to IB
        ./cooker -c ar71xx/generic --flavor=lime_default  # cook all firmwares for target ar71xx/generic
    
     - If you want to use an existing community network profile, specify it when cooking (in addition to the device profile)
    
        ./cooker -c ar71xx/generic --flavor=lime_default --community=quintanalibre.org.ar/comun --profile=tl-wdr3500-v1
    
     - If not profile defined, cook all profiles of target. Also --extra-pkg option can be used to add extra packages when cooking
    
        ./cooker -c ar71xx/generic --flavor=lime_zero --extra-pkg="luci-proto-3g iperf"
    
     - To see/debug build errors use J (number of threads) and V (verbose) system vars
    
        J=1 V=s ./cooker -b ar71xx/generic --profile=tl-wdr3500-v1

## Testing on QEMU

While developing new features, or just testing out fixes, being able to see them in action without having to reflash a device can be useful. To
achieve this you can spin a [QEMU](https://en.wikipedia.org/wiki/QEMU) virtual machine and boot the image with your edits.
These instruction are based on this [document](https://lede-project.org/docs/guide-developer/test-virtual-image-using-armvirt) but are a bit more specific to LibreMesh building process.

First of all you need to create your cooked version of LibreMesh firmware for the `armvirt` target, see [up here](#preparing-the-local-environment).

    cd lime-sdk
    ./cooker -c armvirt/generic --flavor=lime_default --update-feeds

Once `cooker` finishes to build the image you'll find the needed files in the `output` folder of `lime-sdk`, they will be located in a subfolder
accordingly to the architecture and profile chosen. The interesting files are:

 * lede-17.01.2-lime-XXXX-zImage
 * lede-17.01.2-lime-XXXX-root.ext4.gz

Uncompress `lede-17.01.2-lime-XXXX-root.ext4.gz` using `gunzip -k lede-17.01.2-lime-XXXX-root.ext4.gz`

Now you need to install qemu in order to boot the image, usually it's available inside the repositories of the distribution. Here some quick links
documenting how to install it on [Debian](https://wiki.debian.org/QEMU) or [ArchLinux](https://wiki.archlinux.org/index.php/QEMU).

Note that if you
want to use an image built for arm you should have `qemu-system-arm` command available, often provided by `qemu-system-arm` or `qemu-arch-extra` package.

Now it's time to spin the virtual machine.


### Using plain QEMU
Plain qemu can be launched straight from the command line, if you don't need to access LibreMesh web interface and just want to have a shell you can issue

`qemu-system-arm -nographic -M virt -m 64 -kernel lede-17.01.2-lime-XXXX-armvirt-zImage -drive file=lede-17.01.2-lime-XXXX-armvirt-root.ext4,format=raw,if=virtio -append 'root=/dev/vda rootwait'`

Press enter and you will find yourself inside the VM booted.

You can also have access to the web interface configuring a tap device on the host as follows.

TODO

### Using Virt-Manager

[VirtManager](https://github.com/virt-manager/virt-manager) is an higher level way to deal with virtualization using libvirt. Libvirt supports several
virtualization technologies, not only Qemu. It's a quick'n'easy way to setup a test environment.

Many distributions provide packages for Virt-Manager, you have to install it together with qemu:

* **ArchLinux**: `sudo pacman -S virt-manager`
* **Debian** and **Ubuntu**: `sudo apt-get install virt-manager`

If you plan to use networking functions, like accessing the web interface, you'll need to install also `iptables` and `ebtables` packages.

The setup is a bit longer but is persistent and you will only need to rebuild the images from `cooker` and re-spin the VM to see your changes.

What you need to do is to start the libvirtd and virtlogd daemons (if not already started start them with `sudo systemctl start libvirtd.service virtlogd.service`), open Virt-Manager and ensure you are connected to the
libvirt socket.

Now you have to create a new virtual machine: click on *File/New Virtual Machine*, select *Import existing disk image* and choose the *arm* architecture under *Architecture options* and *virt* machine type.

Taking arm as an example you'll have to choose (clicking *Browse* and *Browse Local* buttons) the `lede-17.01.2-lime-XXXX-armvirt-root.ext4` file as storage disk and the `lede-17.01.2-lime-XXXX-armvirt-zImage` file as Kernel path. Insert `root=/dev/vda rootwait` as Kernel args. You can leave *OS type* as *Generic*.

Assign resources (64 MB of RAM memory should be enough) and, under *Network selection*, choose `NAT` as network type. In this way you will be able to connect to the web interface and the device will have internet access.

If you started the VM at this point, it will hang, you can shut it down from the menu *Virtual Machine/Shut Down/Force off*.

What is missing is to change the disk bus mode: open the VM windows without starting the VM, click on *View/Details* open the *SATA disk 1* tab and change *Disk bus* from *SATA* to *VirtIO*. You should now be able to start the VM.

Libvirt automatically create a bridge interface for you to which the VMs are connected to. Assign your bridge device a network address inside LibreMesh subnet
and you should be good to go, something like:

`sudo ip address add 10.13.246.1/16 dev virbr0`

Or get one via DHCP with: `sudo dhcpcd --metric 9999 virbr0` or `sudo dhclient -e IF_METRIC=9999 -i virbr0`

Should be good, you can be sure about the address opening the VM and issuing an `ip address show dev br-lan` once the interfaces are correctly set-up.

You can access the router web interface in a browser with the router IP or anygw IP which could be something like `10.13.0.1`

If the router has just one ethernet interface, like in our VM, LibreMesh by default doesn't use that interface as WAN. If you need the router to have access to the internet, using the VM console interface edit `/etc/config/lime` adding a specific interface configuration like:

    config net manualwan
        option linux_name 'eth0'
        list protocols 'wan'

applying the new settings with the command `lime-config; service network reload`. A drawback is that in this way the web interface can not be accessed anymore because of LibreMesh firewall blocking connections incoming from the WAN interface.
