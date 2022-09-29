---
layout: single
title: "Overview"
date: 2021-04-23 10:35:00 -0400
author_profile: true
toc: true
toc_sticky: true
permalink: /overview/
category: user
---

## What Is ICESat-2 SlideRule?

___SlideRule___ is a server-side framework implemented in C++/Lua that provides REST APIs for processing science data and returning results. _SlideRule_ can be used by researchers and other data systems for low-latency access to customized data products generated using processing parameters supplied at the time of the request.

_SlideRule_ runs in AWS us-west-2 and has access to the official ICESat-2 datasets hosted by the NSIDC. While its web services can be accessed by any http client (e.g. curl), a [Python client](https://github.com/ICESat2-SlideRule/sliderule-python) is provided that makes it easier to interact with _SlideRule_.  The ICESat-2 SlideRule deployment is accessed at [slideruleearth.io](/).

The development of _SlideRule_ is led by The University of Washington in conjunction with the  ICESat-2 program.  The initial use of SlideRule is to support science investigations using ICESat-2's ATL03, ATL06, and ATL08 datasets.

For a quick start guide that walks you through using SlideRule right away, see the [Getting Started Guide](/gettingstarted/).  What follows is a detailed look at SlideRule's architecture and the various components that make up the system.

## System Block Diagram

![system block diagram](/assets/images/system_block_diagram.png){: .align-center}

User Python Scripts

:   This is where the user lives; they write Python scripts that use SlideRule to process portions of the ICESat-2 data and analyze the results.

SlideRule Python Client

:   While SlideRule can be accessed by any http client (e.g. curl) by making GET and POST requests to the SlideRule service, the provided Python packages (`icesat2.py` and `sliderule.py`) contain higher-level functions which accept and return basic python variable types (e.g. dictionaries, lists, numbers), abstract away a lot of the complexity involved in interacting with SlideRule, and perform the necessary GET and POST requests for the user.

SlideRule Server(s)

:   SlideRule servers are the heart of the data system and do all the heavy lifting of reading the source datasets, executing the science processing algorithms,and returning the results.  Each instance of the server runs inside a Docker container, which runs inside an Elastic Cloud Compute (EC2) instance, which belongs to an Auto-Scaling Group (ASG).  The Python client interacts directly with the server instances, sending them processing requests, and reading back results.  All communication is with the server is performed over port `9081`, and is `HTTP`.

Consul Service Discovery

:   All SlideRule servers are ephemeral: new ones are added as processing requirements grow, and existing ones are brought down and removed as demand diminishes.  In order to know which servers are available at any one time, each SlideRule instance runs a Consul agent which registers on startup and de-registers on shutdown with the Consul server.  Prior to accessing the SlideRule servers directly, any client must first make a request to Consul to retrieve a list of available servers to which to make processing requests.

Common Metadata Repository (CMR)

:   NASA maintains a database of the metadata associated with all NASA datasets which can be used to retrieve dataset granules that match a geospatial or temporal query.  While SlideRule does support maintaining its own dataset indexes, since the CMR system is full-featured and externally maintained, and since ICESat-2's data is fully indexed by the CMR system, SlideRule relies upon it for all initial dataset queries.

Grafana / Prometheus / Loki

:   These applications are used internally by developers to aggregate and display operating logs and metrics for the running SlideRule instances.

Node Manager

:   Functionality under development...

Data Lake

:   All source datasets accessible by SlideRule are treated as unstructured data lakes.  SlideRule does not maintain any databases or metadata associated with the data it reads.  Instead, it uses a simple _asset directory_ which lists which datasets SlideRule has access to, and provides the name of the software driver needed to access the data.  For ICESat-2, the ATL03/ATL06/ATL08 datasets are listed in the asset directory as `nsidc-s3`, and include the software driver needed to read HDF5 data from S3, along with the bucket and subfolder in which the data is held.

## Example Data Flow for Processing Request

![request data flow](/assets/images/request_data_flow.png){: .align-center}

__(1)__ User makes call to SlideRule Python client package (e.g. `icesat2.py`) from Python script they are developing.

__(2)__ Python client makes request to CMR system and retrieves list of granules matching user's temporal and geospatial query.

>
> For example, the user could request all ICESat-2 ATL03 data that was collected from 2018 to 2020 and is in the Grand Mesa region of Colorado.  The Python client formats a corresponding query issues it as a request to the CMR system.  THe CMR system then returns a list of ICESat-2 ATL03 granules that matches the query.
>

__(3)__  Python client makes request to Consul and retrieves a list of the running SlideRule servers.

>
> The list is the set of public IP addresses of the SlideRule servers.  This step could be skipped if the server IP addresses were known in advance, but because SlideRule is dynamic and servers come and go, the Consul service is the recommended way to obtain the list of available SlideRule servers for any given request.
>

__(4)__ Python client fans out processing of granules in parallel across all available SlideRule servers.

__(5)__ SlideRule servers read source datasets from S3, and subsets and processes them according to the parameters supplied in the request.

__(6)__ SlideRule servers return results back to Python client as they are completed.

__(7)__ Python client parses and reconstructs the results into native Python data structures (_dictionaries_, _lists_, _numbers_), and returns it to the user.


## Next Steps

* If you are looking to get started processing ICESat-2 data right away, take a look at the [Getting Started Guide](/gettingstarted/).
* If you want to learn about the available Python API functions for SlideRule, see the [Documentation](/rtd/).
* If you are interested in how SlideRule efficiently accesses HDF5 data in S3, see the [H5Coro](/h5coro/) detailed description.