#!/bin/bash

sudo -l > /dev/null

if [ -z $1 ]; then
    read -e -p "Specify workspace location: [~/workspace] " WORKSPACE
fi

[ -z ${WORKSPACE} ] && export WORKSPACE=${HOME}/workspace
mkdir -p ${WORKSPACE}
cd ${WORKSPACE}

echo "Location to put P4 packages: [${WORKSPACE}]"
read -rep "Press [Enter] to start the installation process" 

mkdir -p ${WORKSPACE}

set -xe

sudo apt-get update

KERNEL=$(uname -r)
DEBIAN_FRONTEND=noninteractive sudo apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade
sudo apt-get install -y --no-install-recommends \
  autoconf \
  automake \
  bison \
  build-essential \
  ca-certificates \
  cmake \
  cpp \
  curl \
  flex \
  git \
  libboost-dev \
  libboost-filesystem-dev \
  libboost-iostreams1.58-dev \
  libboost-program-options-dev \
  libboost-system-dev \
  libboost-test-dev \
  libboost-thread-dev \
  libc6-dev \
  libevent-dev \
  libffi-dev \
  libfl-dev \
  libgc-dev \
  libgc1c2 \
  libgflags-dev \
  libgmp-dev \
  libgmp10 \
  libgmpxx4ldbl \
  libjudy-dev \
  libpcap-dev \
  libreadline6 \
  libreadline6-dev \
  libssl-dev \
  libtool \
  linux-headers-$KERNEL\
  make \
  mktemp \
  pkg-config \
  python \
  python-dev \
  python-ipaddr \
  python-pip \
  python-scapy \
  python-setuptools \
  tcpdump \
  unzip \
  vim \
  wget

BMV2_COMMIT="7e25eeb19d01eee1a8e982dc7ee90ee438c10a05"
PI_COMMIT="219b3d67299ec09b49f433d7341049256ab5f512"
P4C_COMMIT="48a57a6ae4f96961b74bd13f6bdeac5add7bb815"
PROTOBUF_COMMIT="v3.2.0"
GRPC_COMMIT="v1.3.2"

NUM_CORES=`grep -c ^processor /proc/cpuinfo`

# Mininet
if [ ! -d ${WORKSPACE}/mininet ]; then
    git clone git://github.com/mininet/mininet mininet
fi
cd mininet
sudo ./util/install.sh -nwv
cd ..

# Protobuf
if [ ! -d ${WORKSPACE}/protobuf ]; then
    git clone https://github.com/google/protobuf.git
fi
cd protobuf
git checkout ${PROTOBUF_COMMIT}
export CFLAGS="-Os"
export CXXFLAGS="-Os"
export LDFLAGS="-Wl,-s"
./autogen.sh
./configure --prefix=/usr
make -j${NUM_CORES}
sudo make install
sudo ldconfig
unset CFLAGS CXXFLAGS LDFLAGS
# force install python module
cd python
sudo python setup.py install
cd ../..

# gRPC
if [ ! -d ${WORKSPACE}/grpc ]; then
    git clone https://github.com/grpc/grpc.git
fi
cd grpc
git checkout ${GRPC_COMMIT}
git submodule update --init --recursive
export LDFLAGS="-Wl,-s"
make -j${NUM_CORES}
sudo make install
sudo ldconfig
unset LDFLAGS
cd ..
# Install gRPC Python Package
sudo pip install grpcio

# BMv2 deps (needed by PI)
if [ ! -d ${WORKSPACE}/behavioral-model ]; then
    git clone https://github.com/p4lang/behavioral-model.git
fi
cd behavioral-model
git checkout ${BMV2_COMMIT}
# From bmv2's install_deps.sh, we can skip apt-get install.
# Nanomsg is required by p4runtime, p4runtime is needed by BMv2...
tmpdir=`mktemp -d -p .`
cd ${tmpdir}
bash ../travis/install-thrift.sh
bash ../travis/install-nanomsg.sh
sudo ldconfig
bash ../travis/install-nnpy.sh
cd ..
sudo rm -rf $tmpdir
cd ..

# PI/P4Runtime
if [ ! -d ${WORKSPACE}/PI ]; then
    git clone https://github.com/p4lang/PI.git
fi
cd PI
git checkout ${PI_COMMIT}
git submodule update --init --recursive
./autogen.sh
./configure --with-proto
make -j${NUM_CORES}
sudo make install
sudo ldconfig
cd ..

# Bmv2
cd behavioral-model
./autogen.sh
./configure --enable-debugger --with-pi
make -j${NUM_CORES}
sudo make install
sudo ldconfig
# Simple_switch_grpc target
cd targets/simple_switch_grpc
./autogen.sh
./configure --with-thrift
make -j${NUM_CORES}
sudo make install
sudo ldconfig
cd ..
cd ..
cd ..

# P4C
if [ ! -d ${WORKSPACE}/p4c ]; then
    git clone https://github.com/p4lang/p4c
fi
cd p4c
git checkout ${P4C_COMMIT}
git submodule update --init --recursive
mkdir -p build
cd build
cmake ..
make -j${NUM_CORES}
make -j${NUM_CORES} check
sudo make install
sudo ldconfig
cd ..
cd ..

echo "Bootstraped"
