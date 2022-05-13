---
layout: single
title: About
author_profile: true
permalink: /about/
---

The NASA/ICESat-2 program is investing in a collaboration between Goddard Space Flight Center and the University of Washington to develop a cloud-based on-demand science data processing system called SlideRule to lower the barrier of entry to using the ICESat-2 data for scientific discovery and integration into other data services. 

SlideRule is a server-side framework implemented in C++/Lua that provides REST APIs for processing science data and returning results. This enables researchers and other data systems to have low-latency access to generated data products using processing parameters supplied at the time of the request.  SlideRule is able to communicate with back-end data services like HSDS as well as directly access H5 data stored in AWS S3 through its H5Coro library.  This combination provides cloud-optimized access to the ICESat-2 source datasets while preserving the existing HDF5-based tooling the project has already heavily invested in.

The initial target application for SlideRule is processing the ICESat-2 point-cloud and atmospheric datasets for seasonal snow depth mapping and glacier research.  We chose this application because there is a growing interest in these areas of research across both universities and government, and because no high-level ICESat-2 data products targeting these communities currently exist.

