======
icepyx
======

The icepyx Python API ``ipxapi.py`` is used to access the services provided by the **sliderule-icesat2** plugin for SlideRule using the ``icepyx`` library.
It mirrors functions provided in the ``icesat2.py`` module, and provides a simplified interface that accepts icepyx Query objects (regions).

The module can be imported via:

.. code-block:: python

    from sliderule import ipxapi

For more information about icepyx, go to `icepyx GitHub <https://github.com/icesat2py/icepyx>`_ or `icepyx ReadTheDocs <https://icepyx.readthedocs.io/en/latest/>`_.



atl06p
------

""""""""""""""""

.. py:function:: ipxapi.atl06p(ipx_region, parm, asset=icesat2.DEFAULT_ASSET)

    Performs ATL06-SR processing in parallel on ATL03 data and returns gridded elevations.  The list of granules to be processed is identified by the ipx_region object.

    See the `atl06p <ICESat-2.html#atl06p>`_ function for more details.

    :param Query ipx_region: icepyx region object defining the query of granules to be processed
    :param dict parm: parameters used to configure ATL06-SR algorithm processing (see `Parameters <ICESat-2.html#parameters>`_)
    :keyword str asset: data source asset (see `Assets <ICESat-2.html#assets>`_)
    :return: GeoDataFrame of gridded elevations (see `Elevations <ICESat-2.html#elevations>`_)



atl03sp
-------

""""""""""""""""

.. py:function:: ipxapi.atl03sp(ipx_region, parm, asset=icesat2.DEFAULT_ASSET)

    Performs ATL03 subsetting in parallel on ATL03 data and returns photon segment data.

    See the `atl03sp <ICESat-2.html#atl03sp>`_ function for more details.

    :param Query ipx_region: icepyx region object defining the query of granules to be processed
    :param dict parms: parameters used to configure ATL03 subsetting (see `Parameters <ICESat-2.html#parameters>`_)
    :keyword str asset: data source asset (see `Assets <ICESat-2.html#assets>`_)
    :return: list of ATL03 segments (see `Photon Segments <ICESat-2.html#photon-segments>`_)

