=========
sliderule
=========

The SlideRule Python API ``sliderule.py`` is used to access the services provided by the base SlideRule server. From Python, the module can be imported via:

.. code-block:: python

    import sliderule



source
------

""""""""""""""""

.. py:function:: sliderule.source(api, parm={}, stream=False, callbacks={'eventrec': __logeventrec})

    Perform API call to SlideRule service

    :param str api: name of the SlideRule endpoint
    :param dict parm: dictionary of request parameters
    :keyword bool stream: whether the request is a **normal** service or a **stream** service (see `De-serialization <./SlideRule.html#de-serialization>`_ for more details)
    :keyword dict callbacks: record type callbacks (advanced use)
    :return: response data

    Example:

    .. code-block:: python

        >>> import sliderule
        >>> sliderule.set_url("icesat2sliderule.org")
        >>> rqst = {
        ...     "time": "NOW",
        ...     "input": "NOW",
        ...     "output": "GPS"
        ... }
        >>> rsps = sliderule.source("time", rqst)
        >>> print(rsps)
        {'time': 1300556199523.0, 'format': 'GPS'}


set_url
-------

""""""""""""""""

.. py:function:: sliderule.set_url(urls):

    Configure sliderule package with URL of service

    :param str urls: IP address or hostname of SlideRule service (note, there is a special case where the url is provided as a list of strings instead of just a string; when a list is provided, the client hardcodes the set of servers that are used to process requests to the exact set provided; this is used for testing and for local installations and can be ignored by most users)

    Example:

    .. code-block:: python

        >>> import sliderule
        >>> sliderule.set_url("service.my-sliderule-server.org")


update_available_servers
------------------------

""""""""""""""""

.. py:function:: sliderule.update_available_servers():

    Causes the SlideRule Python client to refresh the list of available processing nodes. This is useful when performing large processing requests where there is time for auto-scaling to change the number of nodes running.

    This function does nothing if the client has been initialized with a hardcoded list of servers.

    :return: the number of available processing nodes

    Example:

    .. code-block:: python

        >>> import sliderule
        >>> sliderule.update_available_servers()


set_verbose
-----------

""""""""""""""""

.. py:function:: sliderule.set_verbose(enable):

    Configure sliderule package for verbose logging

    :param bool enable: whether or not user level log messages received from SlideRule generate a Python log message

    Example:

    .. code-block:: python

        >>> import sliderule
        >>> sliderule.set_verbose(True)

    The default behavior of Python log messages is for them to be displayed to standard output.
    If you want more control over the behavior of the log messages being display, create and configure a Python log handler as shown below:

    .. code-block:: python

      # import packages
      import logging
      from sliderule import sliderule

      # Configure Logging
      sliderule_logger = logging.getLogger("sliderule.sliderule")
      sliderule_logger.setLevel(logging.INFO)

      # Create Console Output
      ch = logging.StreamHandler()
      ch.setLevel(logging.INFO)
      sliderule_logger.addHandler(ch)


set_max_errors
--------------

""""""""""""""""

.. py:function:: sliderule.set_max_errors(max_errors):

    Configure sliderule package's maximum number of errors per node setting.  When the client makes a request to a processing node, if there is an error, it will retry the request to a different processing node (if available), but will keep the original processing node in the list of available nodes and increment the number of errors associated with it.  But if a processing node accumulates up to the **max_errors** number of errors, then the node is removed from the list of available nodes and will not be used in future processing requests.

    A call to ``update_available_servers`` or ``set_url`` is needed to restore a removed node to the list of available servers.

    :param int max_errors: sets the maximum number of errors per node

    Example:

    .. code-block:: python

        >>> import sliderule
        >>> sliderule.set_max_errors(3)


set_rqst_timeout
----------------

""""""""""""""""

.. py:function:: sliderule.set_rqst_timeout(timeout):

    Sets the TCP/IP connection and reading timeouts for future requests made to sliderule servers.
    Setting it lower means the client will failover more quickly, but may generate false positives if a processing request stalls or takes a long time returning data.
    Setting it higher means the client will wait longer before designating it a failed request which in the presence of a persistent failure means it will take longer for the client to remove the node from its available servers list.

    :param tuple timeout: (<connection timeout in seconds>, <read timeout in seconds>)

    Example:

    .. code-block:: python

        >>> import sliderule
        >>> sliderule.set_rqst_timeout((10, 60))


gps2utc
-------

""""""""""""""""

.. py:function:: sliderule.gps2utc(gps_time, as_str=True, epoch=gps_epoch):

    Convert a GPS based time returned from SlideRule into a UTC time.

    :param int gps_time: number of seconds since GPS epoch (January 6, 1980)
    :param bool as_str: if True, returns the time as a string; if False, returns the time as datatime object
    :param datetime epoch: the epoch used in the conversion, defaults to GPS epoch (Jan 6, 1980)
    :return: UTC time (i.e. GMT, or Zulu time)

    Example:

    .. code-block:: python

        >>> import sliderule
        >>> sliderule.gps2utc(1235331234)
        '2019-02-27 19:34:03'


get_definition
--------------

""""""""""""""""

.. py:function:: sliderule.get_definition(rectype, fieldname):

    Get the underlying format specification of a field in a return record.

    :param str rectype: the name of the type of the record (i.e. "atl03rec")
    :param str fieldname: the name of the record field (i.e. "cycle")
    :return: dictionary describing field; entry in the `sliderule.basictypes` variable

    Example:

    .. code-block:: python

        >>> import sliderule
        >>> sliderule.set_url("icesat2sliderule.org")
        >>> sliderule.get_definition("atl03rec", "cycle")
        {'fmt': 'H', 'size': 2, 'nptype': <class 'numpy.uint16'>}


