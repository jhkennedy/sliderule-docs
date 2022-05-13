=======
icesat2
=======

The ICESat-2 Python API ``icesat2.py`` is used to access the services provided by the **sliderule-icesat2** plugin for SlideRule. From Python, the module can be imported via:

.. code-block:: python

    from sliderule import icesat2



init
----

""""""""""""""""

.. py:function:: icesat2.init (url, verbose=False, max_resources=DEFAULT_MAX_REQUESTED_RESOURCES, max_errors=3, loglevel=logging.CRITICAL)

    Mainly a convenience function for initializing the underlying SlideRule module.  Must be called before other ICESat-2 API calls.
    This function is the same as calling the underlying sliderule functions: ``set_url``, ``set_verbose``, ``set_max_errors``, along with the local ``set_max_resources`` function.

    :param str url: the IP address or hostname of the SlideRule service (note, there is a special case where the url is provided as a list of strings instead of just a string; when a list is provided, the client hardcodes the set of servers that are used to process requests to the exact set provided; this is used for testing and for local installations and can be ignored by most users)
    :param bool verbose: whether or not user level log messages received from SlideRule generate a Python log message (see `sliderule.set_verbose <./SlideRule.html#set_verbose>`_)
    :param int max_errors: the number of errors returned by a SlideRule server before the client drops it from the available server list
    :param int max_resources: the maximum number of resources that are allowed to be processed in a single request
    :param int loglevel: minimum severity of log message to output

    Example:

    .. code-block:: python

        >>> from sliderule import icesat2
        >>> icesat2.init("my-sliderule-service.my-company.com", True)


set_max_resources
-----------------

""""""""""""""""

.. py:function:: icesat2.set_max_resources (max_resources)

    Sets the maximum allowed number of resources to be processed in one request.  This is mainly provided as a sanity check for the user.

    :param int max_resources: the maximum number of resources that are allowed to be processed in a single request

    Example:

    .. code-block:: python

        >>> from sliderule import icesat2
        >>> icesat2.set_max_resources(1000)


cmr
---

""""""""""""""""

.. py:function:: icesat2.cmr(polygon=None, time_start=None, time_end=None, version='003', short_name='ATL03')

    Query the `NASA Common Metadata Repository (CMR) <https://cmr.earthdata.nasa.gov/search>`_ for a list of data within temporal and spatial parameters

    :param list polygon: polygon defining region of interest (see `polygons <#polygons>`_)
    :param str time_start: starting time for query in format ``<year>-<month>-<day>T<hour>:<minute>:<second>Z``
    :param str time_end: ending time for query in format ``<year>-<month>-<day>T<hour>:<minute>:<second>Z``
    :param str version: dataset version as found in the `NASA CMR Directory <https://cmr.earthdata.nasa.gov/search/site/collections/directory/eosdis>`_
    :param str short_name: dataset short name as defined in the `NASA CMR Directory <https://cmr.earthdata.nasa.gov/search/site/collections/directory/eosdis>`_
    :return: list of files (granules) for the dataset fitting the spatial and temporal parameters

    Example:

    .. code-block:: python

        >>> from sliderule import icesat2
        >>> region = [ {"lon": -108.3435200747503, "lat": 38.89102961045247},
        ...            {"lon": -107.7677425431139, "lat": 38.90611184543033},
        ...            {"lon": -107.7818591266989, "lat": 39.26613714985466},
        ...            {"lon": -108.3605610678553, "lat": 39.25086131372244},
        ...            {"lon": -108.3435200747503, "lat": 38.89102961045247} ]
        >>> granules = icesat2.cmr(polygon=region)
        >>> granules
        ['ATL03_20181017222812_02950102_003_01.h5', 'ATL03_20181110092841_06530106_003_01.h5', ... 'ATL03_20201111102237_07370902_003_01.h5']



atl06
-----

""""""""""""""""

.. py:function:: icesat2.atl06(parms, resource, asset=DEFAULT_ASSET)

    Performs ATL06-SR processing on ATL03 data and returns gridded elevations

    :param dict parms: parameters used to configure ATL06-SR algorithm processing (see `Parameters <#parameters>`_)
    :param str resource: ATL03 HDF5 filename
    :keyword str asset: data source asset (see `Assets <#assets>`_)
    :return: GeoDataFrame of gridded elevations (see `Elevations <#elevations>`_)

    Example:

    .. code-block:: python

        >>> from sliderule import icesat2
        >>> icesat2.init("icesat2sliderule.org", True)
        >>> parms = { "cnf": 4, "ats": 20.0, "cnt": 10, "len": 40.0, "res": 20.0, "maxi": 1 }
        >>> resource = "ATL03_20181019065445_03150111_003_01.h5"
        >>> atl03_asset = "atlas-local"
        >>> rsps = icesat2.atl06(parms, resource, atl03_asset)
        >>> rsps
                dh_fit_dx  w_surface_window_final  ...                       time                     geometry
        0        0.000042               61.157661  ... 2018-10-19 06:54:46.104937  POINT (-63.82088 -79.00266)
        1        0.002019               61.157683  ... 2018-10-19 06:54:46.467038  POINT (-63.82591 -79.00247)
        2        0.001783               61.157678  ... 2018-10-19 06:54:46.107756  POINT (-63.82106 -79.00283)
        3        0.000969               61.157666  ... 2018-10-19 06:54:46.469867  POINT (-63.82610 -79.00264)
        4       -0.000801               61.157665  ... 2018-10-19 06:54:46.110574  POINT (-63.82124 -79.00301)
        ...           ...                     ...  ...                        ...                          ...
        622407  -0.000970               61.157666  ... 2018-10-19 07:00:29.606632  POINT (135.57522 -78.98983)
        622408   0.004620               61.157775  ... 2018-10-19 07:00:29.250312  POINT (135.57052 -78.98983)
        622409  -0.001366               61.157671  ... 2018-10-19 07:00:29.609435  POINT (135.57504 -78.98966)
        622410  -0.004041               61.157748  ... 2018-10-19 07:00:29.253123  POINT (135.57034 -78.98966)
        622411  -0.000482               61.157663  ... 2018-10-19 07:00:29.612238  POINT (135.57485 -78.98948)

        [622412 rows x 16 columns]


atl06p
------

""""""""""""""""

.. py:function:: icesat2.atl06p(parm, asset=DEFAULT_ASSET, max_workers=DEFAULT_MAX_WORKERS, version=DEFAULT_ICESAT2_SDP_VERSION, callback=None)

    Performs ATL06-SR processing in parallel on ATL03 data and returns gridded elevations.  Unlike the `atl06 <#atl06>`_ function,
    this function does not take a resource as a parameter; instead it is expected that the **parm** argument includes a polygon which
    is used to fetch all available resources from the CMR system automatically.

    Note, it is often the case that the list of resources (i.e. granules) returned by the CMR system includes granules that come close, but
    do not actually intersect the region of interest.  This is due to geolocation margin added to all CMR ICESat-2 resources in order to account
    for the spacecraft off-pointing.  The consequence is that SlideRule will return no data for some of the resources and issue a warning statement to that effect; this can be ignored and indicates no issue with the data processing.

    :param dict parms: parameters used to configure ATL06-SR algorithm processing (see `Parameters <#parameters>`_)
    :keyword str asset: data source asset (see `Assets <#assets>`_)
    :keyword int max_workers: the number of threads to use when making concurrent requests to SlideRule (when set to 0, the number of threads is automatically and optimally determined based on the number of SlideRule server nodes available)
    :keyword str version: the version of the ATL03 data to use for processing
    :keyword bool callback: a callback function that is called for each resource and its results; when set, the API does not return anything (see `Callbacks <#callbacks>`_)
    :return: GeoDataFrame of gridded elevations (see `Elevations <#elevations>`_)


atl03s
------

""""""""""""""""

.. py:function:: icesat2.atl03s (parm, resource, asset=DEFAULT_ASSET)

    Subsets ATL03 data given the polygon and time range provided and returns segments of photons

    :param dict parms: parameters used to configure ATL03 subsetting (see `Parameters <#parameters>`_)
    :param str resource: ATL03 HDF5 filename
    :keyword str asset: data source asset (see `Assets <#assets>`_)
    :return: GeoDataFrame of ATL03 extents (see `Photon Segments <#photon-segments>`_)


atl03sp
-------

""""""""""""""""

.. py:function:: icesat2.atl03sp(parm, asset=DEFAULT_ASSET, max_workers=DEFAULT_MAX_WORKERS, version=DEFAULT_ICESAT2_SDP_VERSION, callback=None)

    Performs ATL03 subsetting in parallel on ATL03 data and returns photon segment data.  Unlike the `atl03s <#atl03s>`_ function,
    this function does not take a resource as a parameter; instead it is expected that the **parm** argument includes a polygon which
    is used to fetch all available resources from the CMR system automatically.

    Note, it is often the case that the list of resources (i.e. granules) returned by the CMR system includes granules that come close, but
    do not actually intersect the region of interest.  This is due to geolocation margin added to all CMR ICESat-2 resources in order to account
    for the spacecraft off-pointing.  The consequence is that SlideRule will return no data for some of the resources and issue a warning statement to that effect; this can be ignored and indicates no issue with the data processing.

    :param dict parms: parameters used to configure ATL03 subsetting (see `Parameters <#parameters>`_)
    :keyword str asset: data source asset (see `Assets <#assets>`_)
    :keyword int max_workers: the number of threads to use when making concurrent requests to SlideRule (when set to 0, the number of threads is automatically and optimally determined based on the number of SlideRule server nodes available)
    :keyword str version: the version of the ATL03 data to return
    :keyword bool callback: a callback function that is called for each resource and its results; when set, the API does not return anything (see `Callbacks <#callbacks>`_)
    :return: GeoDataFrame of ATL03 segments (see `Photon Segments <#photon-segments>`_)


h5
--

""""""""""""""""

.. py:function:: icesat2.h5 (dataset, resource, asset=DEFAULT_ASSET, datatype=sliderule.datatypes["REAL"], col=0, startrow=0, numrows=ALL_ROWS)

    Reads a dataset from an HDF5 file and returns the values of the dataset in a list

    This function provides an easy way for locally run scripts to get direct access to HDF5 data stored in a cloud environment.
    But it should be noted that this method is not the most efficient way to access remote H5 data, as the data is accessed one dataset at a time.
    Future versions may provide the ability to read multiple datasets at once, but in the meantime, if the user finds themselves needing direct
    access to a lot of HDF5 data residing in the cloud, then use of the H5Coro Python package is recommended as it provides a native Python package
    for performant direct access to HDF5 data in the cloud.

    One of the difficulties in reading HDF5 data directly from a Python script is converting format of the data as it is stored in the HDF5 to a data
    format that is easy to use in Python.  The compromise that this function takes is that it allows the user to supply the desired data type of the
    returned data via the **datatype** parameter, and the function will then return a **numpy** array of values with that data type.

    The data type is supplied as a ``sliderule.datatypes`` enumeration:

    - ``sliderule.datatypes["TEXT"]``: return the data as a string of unconverted bytes
    - ``sliderule.datatypes["INTEGER"]``: return the data as an array of integers
    - ``sliderule.datatypes["REAL"]``: return the data as an array of double precision floating point numbers
    - ``sliderule.datatypes["DYNAMIC"]``: return the data in the numpy data type that is the closest match to the data as it is stored in the HDF5 file

    :param str dataset: full path to dataset variable (e.g. ``/gt1r/geolocation/segment_ph_cnt``)
    :param str resource: HDF5 filename
    :keyword str asset: data source asset (see `Assets <#assets>`_)
    :keyword int datatype: the type of data the returned dataset list should be in (datasets that are naturally of a different type undergo a best effort conversion to the specified data type before being returned)
    :keyword int col: the column to read from the dataset for a multi-dimensional dataset; if there are more than two dimensions, all remaining dimensions are flattened out when returned.
    :keyword int startrow: the first row to start reading from in a multi-dimensional dataset (or starting element if there is only one dimension)
    :keyword int numrows: the number of rows to read when reading from a multi-dimensional dataset (or number of elements if there is only one dimension); if **ALL_ROWS** selected, it will read from the **startrow** to the end of the dataset.
    :return: numpy array of dataset values

    Example:

    .. code-block:: python

        segments    = icesat2.h5("/gt1r/land_ice_segments/segment_id",  resource, asset)
        heights     = icesat2.h5("/gt1r/land_ice_segments/h_li",        resource, asset)
        latitudes   = icesat2.h5("/gt1r/land_ice_segments/latitude",    resource, asset)
        longitudes  = icesat2.h5("/gt1r/land_ice_segments/longitude",   resource, asset)

        df = pd.DataFrame(data=list(zip(heights, latitudes, longitudes)), index=segments, columns=["h_mean", "latitude", "longitude"])


h5p
---

""""""""""""""""

.. py:function:: icesat2.h5p (datasets, resource, asset=DEFAULT_ASSET)

    Reads a list of datasets from an HDF5 file and returns the values of the dataset in a dictionary of lists.

    This function is considerably faster than the ``icesat2.h5`` function in that it not only reads the datasets in
    parallel on the server side, but also shares a file context between the reads so that portions of the file that
    need to be read multiple times do not result in multiple requests to S3.

    For a full discussion of the data type conversion options, see `h5 <ICESat-2.html#h5>`_.

    :param dict datasets: list of full paths to dataset variable (e.g. ``/gt1r/geolocation/segment_ph_cnt``); see below for additional parameters that can be added to each dataset
    :param str resource: HDF5 filename
    :keyword str asset: data source asset (see `Assets <#assets>`_)
    :return: dictionary of numpy arrays of dataset values, where the keys are the dataset names

    The ``datasets`` dictionary can optionally contain the following elements per entry:

    :keyword int valtype: the type of data the returned dataset list should be in (datasets that are naturally of a different type undergo a best effort conversion to the specified data type before being returned)
    :keyword int col: the column to read from the dataset for a multi-dimensional dataset; if there are more than two dimensions, all remaining dimensions are flattened out when returned.
    :keyword int startrow: the first row to start reading from in a multi-dimensional dataset (or starting element if there is only one dimension)
    :keyword int numrows: the number of rows to read when reading from a multi-dimensional dataset (or number of elements if there is only one dimension); if **ALL_ROWS** selected, it will read from the **startrow** to the end of the dataset.

    Example:

    .. code-block:: python

        >>> from sliderule import icesat2
        >>> icesat2.init(["127.0.0.1"], False)
        >>> datasets = [
        ...         {"dataset": "/gt1l/land_ice_segments/h_li", "numrows": 5},
        ...         {"dataset": "/gt1r/land_ice_segments/h_li", "numrows": 5},
        ...         {"dataset": "/gt2l/land_ice_segments/h_li", "numrows": 5},
        ...         {"dataset": "/gt2r/land_ice_segments/h_li", "numrows": 5},
        ...         {"dataset": "/gt3l/land_ice_segments/h_li", "numrows": 5},
        ...         {"dataset": "/gt3r/land_ice_segments/h_li", "numrows": 5}
        ...     ]
        >>> rsps = icesat2.h5p(datasets, "ATL06_20181019065445_03150111_003_01.h5", "atlas-local")
        >>> print(rsps)
        {'/gt2r/land_ice_segments/h_li': array([45.3146427 , 45.27640582, 45.23608027, 45.21131015, 45.15692304]),
         '/gt2l/land_ice_segments/h_li': array([45.35118977, 45.33535027, 45.27195617, 45.21816889, 45.18534204]),
         '/gt1l/land_ice_segments/h_li': array([45.68811156, 45.71368944, 45.74234326, 45.74614113, 45.79866465]),
         '/gt3l/land_ice_segments/h_li': array([45.29602321, 45.34764226, 45.31430979, 45.31471701, 45.30034622]),
         '/gt1r/land_ice_segments/h_li': array([45.72632446, 45.76512574, 45.76337375, 45.77102473, 45.81307948]),
         '/gt3r/land_ice_segments/h_li': array([45.14954134, 45.18970635, 45.16637644, 45.15235916, 45.17135806])}



toregion
--------

""""""""""""""""

.. py:function:: icesat2.toregion (filename, tolerance=0.0, cellsize=0.01)

    Convert a GeoJSON representation of a set of geospatial regions into a list of lat,lon coordinates and raster image recognized by SlideRule

    :param str filename: file name of GeoJSON formatted regions of interest, file **must** have named with the .geojson suffix
    :param float tolerance: tolerance used to simplify complex shapes so that the number of points is less than the limit (a tolerance of 0.001 typically works for most complex shapes)
    :param float cellsize: size of pixel in degrees used to create the raster image of the polygon
    :return: a raster image and a list of longitudes and latitudes containing the region of interest that can be used for the **poly** and **raster** parameters in a processing request to SlideRule

    region = {
        "poly": [{"lat": <lat1>, "lon": <lon1>, ... }],
        "raster": {
            "image": <base64 encoded geotiff image string>,
            "imagelength": <length of base64 encoded image>,
            "dimension": (<number of rows>, <number of columns>),
            "bbox": (<minimum longitutde>, <minimum latitude>, <maximum longitude>, <maximum latitude>),
            "cellsize": <cell size in degrees>
        }
    }

    Example:

    .. code-block:: python

        from sliderule import icesat2

        # Region of Interest #
        region_filename = sys.argv[1]
        region = icesat2.toregion(region_filename)

        # Configure SlideRule #
        icesat2.init("icesat2sliderule.org", False)

        # Build ATL06 Request #
        parms = {
            "poly": region["poly"],
            "srt": icesat2.SRT_LAND,
            "cnf": icesat2.CNF_SURFACE_HIGH,
            "ats": 10.0,
            "cnt": 10,
            "len": 40.0,
            "res": 20.0,
            "maxi": 1
        }

        # Get ATL06 Elevations
        atl06 = icesat2.atl06p(parms)


get_version
-----------

""""""""""""""""

.. py:function:: icesat2.get_version ()

    Get the version information for the running servers and Python client


