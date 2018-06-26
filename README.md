# p4env

### Requirements

* sudo
* Ubuntu 16.04 (and higher)
* a workspace for placing P4 source code for compiling

### Suggestions

* It would be better to run this utility in a clean VM or docker.

* It's not recommended to run on your daily working OS since it will install a lot of packages that are used for compiling P4 components.

### Usage

Simply run the script with the `path ` of workspace as the only argument:

    ./bootstrap.sh [workspace]

You will be asked password for sudo and answering questions, then the process will be started.

If `workspace` is not specified, then you will be asked:

    ./bootstrap.sh


### Credits

* [P4 tutorials](https://github.com/p4lang/tutorials/tree/master/vm)
