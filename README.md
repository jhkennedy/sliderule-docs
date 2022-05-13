# sliderule-project

Project repository for ICESat-2 SlideRule.


## I. Building the SlideRule Node

The SlideRule **node** can be built and run locally for development purposes, and also built as a Docker image for deployment.

### Prerequisites

1. SlideRule (see https://github.com/ICESat2-SlideRule/sliderule) with following packages:
   * aws
   * h5
   * netsvc

2. ICESat-2 Plugin (see https://github.com/ICESat2-SlideRule/sliderule-icesat2)

3. Docker (see [UbuntuSetup](jekyll/_howtos/UbuntuSetup.md))

### Instructions

To build and run locally (exposed as http://localhost:9081), in the root of the repository:
```bash
$ make sliderule-config
$ make sliderule
$ make sliderule-local-run
```

To build and run as a Docker container (exposed as http://localhost:9081), in the root of the repository:
```bash
$ make sliderule-docker
$ make sliderule-docker-run
```

### Changing how SlideRule is run in a Docker container

```bash
$ docker run -it --rm --name=sliderule-app -v /data:/data -p 9081:9081 sliderule-application /usr/local/scripts/apps/server.lua {config.json}
```

The command above runs the server application inside the Docker container and can be configured in the following ways:
* A script other than `/usr/local/scripts/apps/server.lua` can be passed to the SlideRule executable running inside the Docker container
* The {config.json} file provided to the server.lua script can be used to change server settings
* Environment variables can be passed via `-e {parameter=value}` on the command line to docker
* Different local files and directories can be mapped in via `-v {source abs. path}:{destination abs. path}` on the command line to docker


## II. Building the SlideRule Website

The SlideRule **website** can be built and hosted locally for development purposes, and also built as a Docker image for deployment.

### Prerequisites

1. Sphinx

    See https://www.sphinx-doc.org/en/master/usage/installation.html for more details.

    ```bash
    $ pip install -U Sphinx
    ```

    Note: docutils version 0.17.x breaks certain formatting in Sphinx (e.g. lists).  Therefore it is recommended that docutils version 0.16 be installed.

    ```bash
    $ pip install docutils==0.16
    $ pip install sphinx_markdown_tables
    $ pip install sphinx_panels
    $ pip install sphinx_rtd_theme
    ```

2. Jekyll

    See https://jekyllrb.com/docs/installation/ for more details.

    ```bash
    $ sudo apt-get install ruby-full build-essential zlib1g-dev
    $ echo 'export GEM_HOME="$HOME/gems"' >> ~/.bashrc
    $ echo 'export PATH="$HOME/gems/bin:$PATH"' >> ~/.bashrc
    $ source ~/.bashrc
    $ gem install jekyll bundler
    ```

    Then go into the `jekyll` directory and install all depedencies.

    ```bash
    $ bundle install
    ```

    In the same Python environment that you installed `Sphinx` and its dependencies, you will also need to install the following dependencies.

    ```bash
    $ pip install recommonmark
    ```

3. Docker (see [UbuntuSetup](jekyll/_howtos/UbuntuSetup.md))

### Instructions

To build, in the root of the repository:
```bash
$ make website
```

To run locally (exposed as http://localhost:4000) in the root of the repository:
```bash
$ make website-local-run
```

To run as a Docker container (exposed as http://localhost), in the root of the repository:
```bash
$ make website-docker-run
```


## III. Building the SlideRule Monitor

The SlideRule **monitor** can only be built as a Docker image, but the image can be run locally as well as used for deployment.

### Prerequisites

1. Docker (see [UbuntuSetup](jekyll/_howtos/UbuntuSetup.md))

### Instructions

To build, in the root of the repository:
```bash
$ make monitor-docker
```

To run as a Docker container (exposed as http://localhost:3000), in the root of the repository:
```bash
$ make monitor-docker-run
```


## IV. Deploying the SlideRule Cluster

### Step 1: Release Software

The software is tagged through release scripts located in each repository and invoked through a local makefile target.  The makefile then builds the software and the docker images and pushes them to DockerHub.

The following docker repositories are tagged:
* ICESat2-SlideRule/sliderule
* ICESat2-SlideRule/sliderule-icesat2
* ICESat2-SlideRule/sliderule-python
* ICESat2-SlideRule/sliderule-project

The following docker images are built, tagged, and pushed:
* icesat2sliderule/sliderule:{tag}
* icesat2sliderule/monitor:{tag}
* icesat2sliderule/website:{tag}
* icesat2sliderule/python:{tag}

```bash
$ make VERSION=x.y.z release # where x is major version, y is minor version, and z is incremental release
```

### Step 2: Build AMI

When terraform deploys the cluster to AWS, it uses a pre-built Amazon Machine Image (AMI) for the EC2 instances.  This AMI is manually built using `packer` and should be rebuilt often in order to get the latest security patches.  Note - in order for terraform to use the latest AMI, the terraform code must be updated (or a command line parameter used) to set the AMI id.

The first time you use packer you need to intialize the packer environment.  This only needs to be done once.

```bash
$ cd sliderule-project/packer
$ packer init .
```

All runs of packer should be performed from a terminal while in the `sliderule-project/packer` directory.

```bash
$ packer validate .
$ packer build sliderule-base.pkr.hcl
```
### Step 3: Deploy Cluster

The first time you use terraform from an environment, you need to initialize the terraform subsystem.  This will read the terraform files in the local directory and (if necessary) go out to S3 to retrieve existing workspaces.  This only needs to be done once.

```bash
$ cd sliderule-project/terraform
$ terraform init
```

All runs of terraform should be performed in a well-named workspace from a terminal while in the `sliderule-project/terraform` directory.  Workspaces can be thought of as Python environments or Git branches - they represent a single configuration and deployment of the system that is kept separate from all other workspaces.  Use the commands below to create, manage, and delete workspaces. ***A good practice is to name the workspace after the Git branch or tag that the deployment represents.***

```bash
$ terraform workspace new {workspace-name} # create new workspace
$ terraform workspace list {workspace-name} # display list of existing workspaces
$ terraform workspace select {workspace-name} # go to existing workspace
$ terraform workspace delete {workspace-name} # delete existing workspace
```

To deploy the terraform configuration, run one of the following commands.  The first version is the simple way to deploy for development purposes and uses the ***:latest*** docker images.  The second version is the typical deployment command and should always be used for official releases.

```bash
$ terraform apply -var cluster_name={cluster-name} # simply deployment for development
$ terraform apply -var cluster_name=v{version number} -var sliderule_image=icesat2sliderule/sliderule:v{version number} -var website_image=icesat2sliderule/website:v{version number} -var python_image=icesat2sliderule/python:v{version number} -var monitor_image=icesat2sliderule/monitor:v{version number} -var ami_name=sliderule-node-v{version number}
```

Once a deployment is superceded by another release or needs to be cleaned up for any other reason, the following commands can be used to delete all the resources associated with a deployment.

```bash
$ terraform workspace select {workspace-name} # make sure you are in the right workspace!
$ terraform destroy # delete all resources associated with deployment
```