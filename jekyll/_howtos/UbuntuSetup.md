---
layout: single
title: "Setting Up Ubuntu for SlideRule Development"
date: 2021-04-22 11:35:14 -0400
toc: true
toc_sticky: true
category: developer
---


## 1. Install Needed Packages

Install the basic packages needed to build the code
```bash
$ sudo apt install build-essential libreadline-dev git liblua5.3-dev
```

Install analysis and utility packages
```bash
$ sudo apt install curl meld cppcheck valgrind kcachegrind clang clang-tools lcov
```


## 2. Install CMake (>= 3.13.0)

Navigate to https://cmake.org/download/ and grab the latest stable binary installer for linux.  (As of this writing: cmake-3.17.2-Linux-x86_64.sh).

Install cmake into /opt with the commands below (assuming the install script is in Downloads):
```bash
$ cd /opt
$ sudo sh cmake-3.17.2-Linux-x86_64.sh # accept license and default install location
$ sudo ln -s cmake-3.17.2-Linux-x86_64 cmake
```
### Update .bashrc
```bash
export PATH=$PATH:/opt/cmake/bin
```


## 3. Install Docker

The official Docker installation instructions found at https://docs.docker.com/engine/install/ubuntu/ go up to Ubuntu 19.10.

For Ubuntu 20.04, Docker can be installed with the following commands:
```bash
$ sudo apt install docker.io
```

In order to run docker without having to be root, use the following commands:
```bash
$ sudo usermod -aG docker {username}
$ newgrp docker # apply group to user
```


## 4. Getting core Files

Later versions of Ubuntu run the `apport` crash reporting service on system boot which intercepts core dumps and makes them difficult to find and use in gdb.
In order to disable this service and get normal core dumps in the directory you are running from, perform the following steps:

* Verify that apport is intercepting core files by cat'ing the contents of `/proc/sys/kernel/core_pattern`
* Edit `/etc/default/apport` and set `enabled=0`
* Add the file `60-core-pattern.conf` to the directory `/etc/sysctl.d` with the contents: `kernel.core_pattern = core`
* Restart your system or run: `sudo sysctl --system`
