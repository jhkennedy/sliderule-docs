Assumes Graviton3 processor running Ubuntu 20.04

(*) Logging in the first time

```bash
ssh -i .ssh/<mykey>.pem ubuntu@<ip address>
sudo apt update
sudo apt upgrade
```

(*) Creating User

```bash
sudo useradd -m -s /usr/bin/bash <username>
sudo passwd <username>
sudo usermod -aG sudo <username>
su - <username>
```

(*) Setup Bash

- replace the appropriate section in the .bashrc file with the contents below
```bash
force_color_prompt=yes

parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

if [ "$color_prompt" = yes ]; then
    PS1="\n${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]\[\033[33m\] [\$CONDA_DEFAULT_ENV]\$(parse_git_branch):\[\033[01;34m\]\w\[\033[00m\]\n\$ "
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi

unset color_prompt force_color_prompt
```

- setup core dumps by adding the following to the end of the .bashrc file
```bash
ulimit -c unlimited
```

- in order to get core dumps, make sure the apport service is enabled and running, and then look for them in `/var/lib/apport/coredump/`
```bash
sudo systemctl enable apport.service
```

(*) Managing Keys for Remote Login

- create a local key on your laptop or desktop for remote use: `ssh-keygen -t rsa -b 4096 -C "your_email@example.com"`
- your new key is located in `.ssh/id_rsa.pub`
- to log into a remote server with this key, while on the remote server copy and paste the key into the file `~/.ssh/authorized_keys`


(*) Managing Keys for GitHub

- create a key on the server, while logged into your account: `ssh-keygen -t rsa -b 4096 -C "your_email@example.com"`
- add the key as an ssh key to your github account

(*) Update and Install OS Packages

```bash
sudo apt install build-essential libreadline-dev liblua5.3-dev
sudo apt install git cmake
sudo apt install curl libcurl4-openssl-dev
sudo apt install zlib1g-dev
sudo apt install libgdal-dev
```

(*) Install RapidJson

```bash
git clone https://github.com/Tencent/rapidjson.git
cd rapidjson
mkdir build
cd build
cmake ..
make
sudo make install
```

(*) Install Pistache

```bash
$ sudo add-apt-repository ppa:pistache+team/unstable
$ sudo apt update
$ sudo apt install libpistache-dev
```

(*) Configure Git

Create the local file `~/.gitconfig` in the user's home directory with the following contents:

```yaml
[user]
	name = <name>
	email = <email>
	
[push]
    default = simple

[diff]
    tool = vimdiff

[merge]
    tool = vimdiff

[difftool]
    prompt = false

[mergetool]
    keepBackup = false

[difftool "vimdiff"]
    cmd = vimdiff "$LOCAL" "$REMOTE"

[alias]
    dd = difftool --dir-diff

[credential "https://github.com"]
	helper = 
	helper = !/usr/bin/gh auth git-credential

[credential "https://gist.github.com"]
	helper = 
	helper = !/usr/bin/gh auth git-credential
```

(*) Clone Project

```bash
mkdir meta
cd meta
git clone git@github.com:ICESat2-SlideRule/sliderule.git
git clone git@github.com:ICESat2-SlideRule/sliderule-python.git
git clone git@github.com:ICESat2-SlideRule/sliderule-docs.git
git clone git@github.com:ICESat2-SlideRule/sliderule-build-and-deploy.git
```

(*) Installing and Configuring Docker

```bash
sudo apt-get install ca-certificates curl gnupg lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo usermod -aG docker <username>
newgrp docker
```

(*) Installing Docker-Compose

```bash
wget https://github.com/docker/compose/releases/download/1.29.2/docker-compose-Linux-x86_64
sudo mv docker-compose-Linux-x86_64 /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

(*) Installing NGINX

- install nginx
```bash
sudo apt install nginx
```
- copy over the nginx configuration and restart nginx
```bash
sudo cp nginx.service /etc/nginx/sites-available/sliderule
sudo ln -s /etc/nginx/sites-available/sliderule /etc/nginx/sites-enabled/sliderule
sudo unlink /etc/nginx/sites-enabled/default
```

- need to create the self-signed certs
```bash
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt
sudo systemctl restart nginx
```

(*) Install and Configure Miniconda

```bash
wget https://repo.anaconda.com/miniconda/Miniconda3-py39_4.12.0-Linux-aarch64.sh
chmod +x Miniconda3-py39_4.12.0-Linux-aarch64.sh
./Miniconda3-py39_4.12.0-Linux-aarch64.sh
conda config --set changeps1 False
conda config --set auto_activate_base false
```

(*) Install GitHub Command Line Client

```bash
type -p curl >/dev/null || sudo apt install curl -y
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
&& sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
&& sudo apt update \
&& sudo apt install gh -y
```

(*) Install AWS Command Line Client

```bash
sudo apt install awscli
```

- make sure to scp the .aws/credentials file up to the remote server so that it has the sliderule profile access key and secret access key to start with

(*) Install Terraform & Packer

```bash
sudo apt install unzip

wget https://releases.hashicorp.com/terraform/1.3.1/terraform_1.3.1_linux_arm64.zip
unzip terraform_1.3.1_linux_arm64.zip
sudo mv terraform /usr/local/bin/

wget https://releases.hashicorp.com/packer/1.8.3/packer_1.8.3_linux_arm64.zip
unzip packer_1.8.3_linux_arm64.zip
sudo mv packer /usr/local/bin/
```



    
 
