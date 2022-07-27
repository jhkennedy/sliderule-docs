FROM ubuntu:20.04
MAINTAINER JP Swinski (jp.swinski@nasa.gov)

RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  ruby-full \
  build-essential \
  zlib1g-dev \
  python3 \
  python3-pip \
  && rm -rf /var/lib/apt/lists/*

# Install RTD Dependencies
RUN pip3 install -U Sphinx docutils==0.16 sphinx_markdown_tables sphinx_panels sphinx_rtd_theme
RUN pip3 install recommonmark

# Install Jekyll
RUN gem install webrick
RUN gem install jekyll bundler

# Copy Over RTD Source
COPY rtd /rtd
RUN chmod -R 777 /rtd

# Build RTD Website
RUN make -C /rtd html

# Copy Over Jekyll Source
COPY jekyll /jekyll
RUN chmod -R 777 /jekyll

# Build Jekyll Website
RUN cd /jekyll && bundle install
RUN cd /jekyll && bundle exec jekyll build

# Set Permissions
RUN chmod -R 744 /jekyll
RUN chmod -R 744 /rtd

# Combine Outputs to Well Known Jekyll Directory
RUN mkdir -p /srv/jekyll/_site \
 && cp -R /jekyll/_site/* /srv/jekyll/_site \
 && cp -R /rtd/build/html /srv/jekyll/_site/rtd

WORKDIR /jekyll
ENTRYPOINT bundle exec jekyll serve -d /srv/jekyll/_site --host=0.0.0.0 --skip-initial-build