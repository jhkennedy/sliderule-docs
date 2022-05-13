---
layout: single
title: "Installing HSDS"
date: 2021-04-22 11:35:14 -0400
toc: true
toc_sticky: true
category: developer
---


## Setup Python Evnironment

1. Make sure you have the necessary build environment.  For Ubuntu 20.04:
```
$ sudo apt install build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev python-openssl
```

2. Install pyenv - this is to manage potentially different python versions
```bash
$ curl https://pyenv.run | bash
```

3. Copy and paste the following lines into your .bashrc (and then source it):
```bash
export PATH="~/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
```

4. Install Python 3.8.3 - note that HSDS wants python version 3.8.3 and other versions may not work.
```bash
$ pyenv install 3.8.3
$ pyenv local 3.8.3
```

5. Install S3FS - this is necessary for hsload using the --link option
```bash
$ pip install --upgrade pip
$ pip install s3fs
```

-------------------------------
## Install HSDS

1. Clone, build, and install the HDF5 library.  In order to use hsload with the --link option, the 1.10.x version of the library needs to be built, and the threadsafe option cannot be specified.
```bash
$ git clone https://github.com/HDFGroup/hdf5.git
$ cd hdf5
$ git checkout 1.10/master
$ mkdir build; cd build
$ ../configure --prefix=/usr/local --enable-build-mode=production
$ make -j4
$ sudo make install
```

2. Clone, build, and install the H5 python library using the HDF5 library built above.
```bash
$ git clone https://github.com/h5py/h5py.git
$ cd h5py
$ python setup.py configure --hdf5=/usr/local
$ python setup.py install
```

3. Clone, build, and install the H5 python rest client (v0.8.1).
```bash
$ git clone https://github.com/HDFGroup/h5pyd.git
$ cd h5pyd
$ python setup.py install
```

4. Install Docker (Community Edition):
```bash
$ sudo apt install apt-transport-https ca-certificates curl software-properties-common
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
$ sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
$ sudo apt update
$ apt-cache policy docker-ce
$ sudo apt install docker-ce
$ sudo usermod -aG docker ${USER}
$ su - ${USER}
```

5. Clone, and install the HSDS service (v0.6.2).
```bash
$ git clone https://github.com/HDFGroup/hsds.git
$ cd hsds
$ python setup.py install
$ docker build -t hdfgroup/hsds .
```
note that HSDS wants python version 3.8.3 and other versions may not work.

6. Install Docker Compose (to launch the HSDS service)
```bash
$ sudo curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
$ sudo chmod +x /usr/local/bin/docker-compose
```

-------------------------------
## Configure Environment

1. Create a file in your home directory called `~/.hscfg` and place the following contents in it:
```
hs_endpoint = http://hsds.sliderule.beta
hs_username = {username}
hs_password = {password}
hs_api_key = None
```
2. Make sure the `hsds.sliderule.beta` hostname is added to your /etc/hosts file and points to the local IP address of the server running hsds.

3. Add the following lines to your .bashrc file (and then source it). Note that the order of precedence for parameters being used by HSDS is: (1) command line, (2) environment variables, (3) override.yml, (4) config.yml.  But, the following environment variables are needed even if they are supplied in either of the yml files.
```
export BUCKET_NAME=icesat2-sliderule
export AWS_REGION=us-west-2
export AWS_S3_GATEWAY=https://s3.us-west-2.amazonaws.com
export HSDS_ENDPOINT=http://hsds.sliderule.beta
```

4. Copy the project specific HSDS configuration into the HSDS repository and rebuild the docker image.
```bash
$ git clone https://github.com/ICESat2-SlideRule/devops.git
$ cd devops
$ sudo cp srds/config/groups.txt  {path_to_hsds}/admin/config
$ sudo cp srds/config/passwd.txt  {path_to_hsds}/admin/config
$ cp srds/config/override.yml {path_to_hsds}/admin/config
$ cp srds/scripts/runall.sh {path_to_hsds}
```

5. Rebuild HSDS
```bash
$ cd {path_to_hsds}
$ python setup.py install
$ docker build -t hdfgroup/hsds .
```

6. Run HSDS - __NOTE__: must be in the hsds root directory; this is because the config.yml and docker-compose file need to have the admin/config folder mounted
```bash
$ ./runall.sh {CORES}
```

7. To stop HSDS
```bash
$ ./stopall.sh
```

-------------------------------
## Testing Out Your Setup

On a fresh S3 bucket, before doing anything else, HSDS wants there to be a `/home/` domain. To create this domain, run:
```bash
$ hstouch /home/
```

To see if your system is up and running, run:
```bash
$ hsinfo
```

Look to see that the state is __READY__ and not __WAITING__.  You may have to wait a few seconds after starting HSDS for it to go to the ready state.  Note that some errors will not appear when in the waiting state and only occur when in the ready state.


-------------------------------
## Running `hsload`

Before loading any files, make sure that the domain you are loading to exists.  This only needs to be done once per bucket:
```bash
$ hstouch /hsds/
$ hstouch /hsds/ATLAS/
```

To run hsload from the command line, use the following command:
```bash
$ hsload -v --link s3://icesat2-sliderule/data/ATLAS/ATL03_20181019065445_03150111_003_01.h5 /hsds/ATLAS/
```

To run hsload using the docker container provided by the HDF group, run the following command, and then once you are running in the container, make sure the /etc/hosts file includes the entry for hsds.sliderule.beta:
```bash
$ docker run --rm -v ~/.hscfg:/root/.hscfg -v ~/data:/data -it hdfgroup/hdf5lib:1.10.6 bash
# echo "{local ip address} hsds.sliderule.beta" >> /etc/hosts
```

To delete a file or domain that you no longer want:
```bash
$ hsdel -v /data/ATLAS/file_I_dont_want.h5`
```

### Issues with the `hsload` utility

In order to run the hsload command with the --link option:
1. You must build/install your own version of h5py that links to a 1.10.6 version of the hdf5 library.  The pip h5py package includes an older version of hdf5 library.
2. When building/installing the hdf5 library, the threadsafe option cannot be used, as it will cause the h5py package to fail on import.
3. The latest s3fs code cannot be used as it will error out when the hsload script calls into it.  Using the prebuilt conda package worked fine.
4. When using the latest version hsload in h5pyd, note that the s3 link option changes from --s3link to --link.
5. When using the latest version hsload in h5pyd, note that the version is hardcoded to only allow 1.10.x series 6 or greater.  1.12.x will not work.
6. You may need to run hsload multiple times on the same file because there are intermittent errors where it will fail out


--------------------------------
## Configuring HSDS


### Sample .bashrc
```
export BUCKET_NAME=slideruledemo                            # set to the name of the bucket you will be using
export AWS_REGION=us-west-2                                 # for S3 region the bucket is in
export AWS_S3_GATEWAY=https://s3.us-west-2.amazonaws.com    # AWS endpoint for region where bucket is
export HSDS_ENDPOINT=http://hsds.sliderule.demo             # use https protocol if SSL is desired

## DO NOT set the following if using EC2 AWS_IAM_ROLE
export AWS_ACCESS_KEY_ID=1234567890                         # access key for S3
export AWS_SECRET_ACCESS_KEY=ABCDEFGHIJKL                   # access secret key for S3

```
Source ~/.bashrc again: `source ~/.bashrc`

Add `hsds.sliderule.demo` to /etc/hosts file or use DNS: `sudo vim /etc/hosts`

`git clone https://github.com/ICESat2-SlideRule/devops.git`

`git clone https://github.com/HDFGroup/hsds`

Copy the override.yml file into the hsds/admin/config directory.  
`cp devops/srds/config/config.yml hsds/admin/config`

Copy the password and group configurations into hsds/admin/config.  
`cp devops/srds/config/passwd.txt hsds/admin/config/`  
`cp devops/srds/config/groups.txt hsds/admin/config/`  

From the hsds root directory, build the latest docker image: `docker build -t hdfgroup/hsds .`

Copy the modified runall.sh script into the hsds directory.  
`cp devops/srds/scripts/runall.sh hsds/`

From the hsds root directory, start the service: `$ ./runall.sh <n>`

The first time this is run the docker images will be built.

Check docker cluster: `docker ps`

## Post-install tests:

Check SRDS configuration: `hsconfigure`

Update any information that needs to be updated.

Run `hsinfo` to verify cluster is up and running

Create domain:

`hstouch -v -u admin -p PASSWORD -b slideruledemo /data/`

Verify domain created:

`hsls -b slideruldemo /data/`

Add subdomain:

`hstouch -v -u admin -p PASSWWORD -b slideruldemo -o user1 /data/ATLAS/`

Verify subdomain created:

`hsls -b slideruledemo /data/ATLAS/`

Create test subdomain:

`hstouch -v -u user1 -p PASSWORD -b slideruledemo /data/ATLAS/test/`

Verify test subdomain created:

`hsls -b slideruledemo /data/ATLAS/test/`

`hsload -v -u user1 -p PASSWORD -b slideruledemo pathToFILENAME.h5 /data/ATLAS/test/`

Remove test file and subdomain:

`hsdel -v -u admin -p PASSWORD /data/ATLAS/test/FILENAME.h5`

`hsdel -v -u admin -p PASSWORD /data/ATLAS/test/`

Install s3fs to access s3 directly from hsload:

`pip install s3fs`

`hsload -v -u admin -p PASSWORD --s3link s3://slideruledemo/atl03samples/ATL09_20181019054657_03150101_003_01.h5 /data/ATLAS/`

Command to shut down the service: `$ ./stopall.sh`

## Options and future enhancements

In the future, it may be desirable to have the override configuration installed at the system level.  
`sudo mkdir /etc/hsds`  
`sudo cp devops/srds/config/config.yml /etc/hsds/`  
`sudo cp devops/srds/config/override.yml /etc/hsds/`  

In the future, if AWS access keys need to be used, then unset the AWS env keys if using MFA and EC2 IAM_ROLE:  
`unset AWS_ACCESS_KEY_ID`  
`unset AWS_SECRET_ACCESS_KEY`


  

