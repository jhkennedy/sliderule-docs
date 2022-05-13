============
Installation
============

The SlideRule Python client is most easily installed using the Conda Python package manager.

.. code-block:: bash

    conda install -c conda-forge sliderule


Developer Install
-----------------

To get the latest unreleased version of the Python client, the contents of the `sliderule-python` repository can be cloned or download as a `zipped file <https://github.com/ICESat2-SlideRule/sliderule-python/archive/main.zip>`_.
If cloning, please consider forking into your own account before cloning onto your system.  To clone the repository:

.. code-block:: bash

    git clone https://github.com/ICESat2-SlideRule/sliderule-python.git

You can then install the `sliderule-python` client using `setuptools`:

.. code-block:: bash

    cd sliderule-python
    python3 setup.py install

For developer installs using conda, you can use the provided environment file to create an initial conda environment
that has the `sliderule-python` client installed along with all the dependencies necessary to run the included `sliderule` utilities and examples.

.. code-block:: bash

    cd sliderule-python
    conda env create -f environment.yml


JuypterLab
----------

To install and setup JupyterLab to run the provided example notebooks,
you must first install JupyterLab.

.. code-block:: bash

    conda install -c conda-forge jupyterlab

Then make sure the conda environment with the `sliderule-python` client installed in it is available to use as one of the Python kernels.
To gaurantee that JuypterLab is using the correct Python kernel, you can start JupyterLab from the conda environment with `sliderule-python` installed.

.. code-block:: bash

    conda activate sliderule
    jupyter lab

If you start JupyterLab from the base conda environment, then it will be necessary to select the correct kernel by using the kernel selection widget
in the upper-right hand corner of the Jupyter notebook you are running.  If you used the provided environment.yml file to create your conda environment
then the correct kernel will likely be something like `Python [conda env:sliderule]`.

.. warning::
    If your conda environment does not show up as an available kernel for your Jupyter Notebooks
    then install the `nb_conda_kernels` package in your base conda environment and then make sure
    your conda environment has the `ipykernel` package installed.  All environments with that
    package installed will automatically show up as available kernels.  Alternatively, see JupyterLab
    documentation for how to register and unregister individual conda environments.