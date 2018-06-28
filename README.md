# p4env

**p4env** is an utility for installing dependencies required by P4 automatically. 

Currently, it works for Ubuntu 16.04 LTS.


### Requirements

* sudo
* Ubuntu 16.04
* a workspace for placing P4 source code for compiling


### Usage

Simply run the script with the `path ` of workspace as the only argument:

    ./bootstrap.sh [workspace]

Then this script will prompt for sudo password and confirm to get started.


### Suggestions

* It would be better to run this utility in a clean VM or docker.

* It's not recommended to run in your daily working OS since it will install a lot of packages that are only used for compiling P4 components.


### Credits

* [P4 tutorials](https://github.com/p4lang/tutorials/tree/master/vm)
