# sliderule-docs

Repository for ICESat-2 SlideRule documentation.


## Building the SlideRule Website

The SlideRule **website** can be built and hosted locally for development purposes.

### Prerequisites

1. Sphinx

    See https://www.sphinx-doc.org/en/master/usage/installation.html for more details.

    ```bash
    $ pip install -U Sphinx docutils==0.16 sphinx_markdown_tables sphinx_panels sphinx_rtd_theme
    ```

    Note: docutils version 0.17.x breaks certain formatting in Sphinx (e.g. lists).  Therefore it is recommended that docutils version 0.16 be installed.

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

### Build Instructions

To build, in the root of the repository:
```bash
$ make
```

To run locally (exposed as http://localhost:4000) in the root of the repository:
```bash
$ make run
```
