---
layout: single
title: "Installing SRDS"
date: 2020-01-01 12:00:00 -0400
toc: true
toc_sticky: true
category: developer
---


## Install Python:

Install pyenv:

`curl https://pyenv.run | bash`

Add the following lines to your ~/.bashrc:

`export PATH="~/.pyenv/bin:$PATH"`

`eval "$(pyenv init -)"`

`eval "$(pyenv virtualenv-init -)"`

Open a new shell, or source ~/.bashrc in your current shell:

`source ~/.bashrc`

Install the Python build dependencies (Ubuntu):
```
sudo apt update && sudo apt install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev python-openssl git
```

Install the latest Python releases. This may take a while:

`pyenv install 3.8.3`

Make your fresh Pythons available inside the repository:

`pyenv local 3.8.3`

`$ python --version`

**Output:** Python 3.8.3

Note: pip is installed as part of the python install but you may want to upgrade to the latest:

`pip install --upgrade pip`

## Dependencies:

`pip install h5pyd`

`pip install h5py` - needed for hsload

`pip install awscli` - AWS command line util [optional]

## Install Docker:

Update and upgrade your existing packages:

`sudo apt update`

`sudo apt upgrade`

Next, install a few prerequisite packages which let apt use packages over HTTPS:

`sudo apt install apt-transport-https ca-certificates curl software-properties-common`

Then add the GPG key for the official Docker repository to your system:

`curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -`

Add the Docker repository to APT sources:

`sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"`

Update the package database with the Docker packages from the newly added repo:

`sudo apt update`

Install from the Docker repo instead of the default Ubuntu repo:

`apt-cache policy docker-ce`

**Output:**
```
docker-ce:
  Installed: (none)
  Candidate: 5:19.03.9~3-0~ubuntu-focal
  Version table:
     5:19.03.9~3-0~ubuntu-focal 500
        500 https://download.docker.com/linux/ubuntu focal/stable amd64 Packages
```

(Notice that docker-ce is not installed, but the candidate for installation is from the Docker repository for Ubuntu 20.04 (focal).)

Install Docker:

`sudo apt install docker-ce`

Docker should now be installed, the daemon started, and the process enabled to start on boot. 

Check that it’s running:

`sudo systemctl status docker`

Example output:
```docker.service - Docker Application Container Engine
     Loaded: loaded (/lib/systemd/system/docker.service; enabled; vendor preset: enabled)
     Active: active (running) since ...
TriggeredBy: docker.socket
       Docs: https://docs.docker.com
   Main PID: 50703 (dockerd)
      Tasks: 25
     Memory: 43.1M
     CGroup: /system.slice/docker.service
             └─50703 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
```

Avoid using sudo, add your username to the docker group:

`sudo usermod -aG docker ${USER}`

To apply the new group membership, log out and back in, or type the following:

`su - ${USER}`

You will be prompted to enter your user’s password to continue.

Confirm that your user is now added to the docker group by typing:

`id -nG`

**Example Output:**
`ubuntu adm dialout cdrom floppy sudo audio dip video plugdev netdev lxd docker`

If you need to add another user to the docker group:

`sudo usermod -aG docker username`

Going forward it is assumed you are running the docker command as a user in the docker group. If not, prepend commands with `sudo`.

`pip install docker-compose`
