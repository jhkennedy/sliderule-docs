---
layout: single
title: "Loading New Data through HSDS"
date: 2021-04-22 11:35:14 -0400
toc: true
toc_sticky: true
category: developer
---

## I. Create a List of New Files to Upload

1. Create a json file {region.json} containing the region of interest.
    * The format of the json file is
    ```
    {
        "region": [ {"lon": <lon1>, "lat": <lat1>}, 
                    {"lon": <lon2>, "lat": <lat2>},
                                  ... 
                    {"lon": <lonN>, "lat": <latN>} ]
    }
    ```
    * The points of the polygon must go in counter-clockwise order (a requirement of the NASA CMR system)
    * The last point in the array must be identical to the first point in the array

2. Run the [get_files_in_region.py](https://github.com/ICESat2-SlideRule/sliderule-python/blob/main/utils/get_files_in_region.py) utility to create the file list.  Note the utility uses the icesat2.py package and therefore must execute in an environment where icesat2.py has been installed.  See https://github.com/ICESat2-SlideRule/sliderule-python for more details.
```bash
$ python get_files_in_region.py {region.json} > {filelist.txt}
```


## II. Download New Data from NSIDC

To download ATL03 and ATL06 data from NSIDC, use Python scripts provided by the tsutterley/read-ICESat-2 repository.  Alternatively, the data can be downloaded manually from the [NSIDC website](https://nsidc.org/data/atl03) either by the `Download Via HTTPS` option (reached through Other Access Options) or the `Download Script`.

1. Checkout the read-ICESat-2 repository (https://github.com/tsutterley/read-ICESat-2.git) and setup a python environment with any necessary dependencies.  For example, if using conda, the following packages are needed:   
    * `conda install lxml`
    * `conda install numpy`

2. Use the {filelist.txt} created in the section above, OR create a file containing a list of the ATL03 and ATL06 files you want to download.  Each file name is provided on its own line.

3. Setup a netrc file with your Earth Data Login username and password.  It should have the following contents with {username} and {password} filled out with your credentials:
```
machine urs.earthdata.nasa.gov login {username} password {password}
```

4. Run the [nsidc_icesat2_sync.py](https://github.com/tsutterley/read-ICESat-2/blob/master/scripts/nsidc_icesat2_sync.py) script to download the files.
```bash
$ python nsidc_icesat2_sync.py --netrc=~/.netrc --index={filelist.txt}
```


## III. Rechunk Data for Optimized Cloud Access

1. Go to sliderule/plugins/icesat2/utils and run the script that performs a parallel rechunk of the files.

If rechunking ATL03 data:
```bash
$ ./rechunk_atl03_dir.sh {source directory} {destination directory}
```

If rechunking ATL06 data:
```bash
$ ./rechunk_atl06_dir.sh {source directory} {destination directory}
```


## IV. Upload New Data to S3

1. Log into AWS console.

2. Using the `S3` service, navigate to the `icesat2-sliderule` bucket.

3. Upload the files using the web interface.

If loading ATL03 data, upload to the `/data/ATL03` folder.

If loading ATL06 data, upload to the `/data/ATL06` folder.


## V. Index Data using "hsload --link"

1. Log in to sliderule-icesat2-beta and verify that HSDS is running (e.g. `hsinfo` or `docker ps`)

2. Go to sliderule/plugins/icesat2/utils and run the script that performs a parallel linked load of the files.

If loading ATL03 data:
```bash
$ ./load_atl03_files.sh ~/{filelist.txt}
```

If loading ATL06 data:
```bash
$ ./load_atl06_files.sh ~/{filelist.txt}
```
