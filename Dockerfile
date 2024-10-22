# SPDX-FileCopyrightText: 2024, Carles Fernandez-Prades <cfernandez@cttc.es>
# SPDX-License-Identifier: MIT

FROM ubuntu:oracular
LABEL version="1.0" description="GNSS-SDR image for the Telecorenta Workshop" maintainer="cfernandez@cttc.es"

WORKDIR /build_dir

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive && apt-get install -y --no-install-recommends \
  bison\
  build-essential \
  ca-certificates \
  cmake \
  curl \
  flex \
  gir1.2-gtk-3.0 \
  git \
  gnuradio-dev \
  libad9361-dev \
  libarmadillo-dev \
  libblas-dev \
  libboost-chrono-dev \
  libboost-date-time-dev \
  libboost-dev \
  libboost-serialization-dev \
  libboost-system-dev \
  libboost-thread-dev \
  libgflags-dev \
  libgoogle-glog-dev \
  libgtest-dev \
  libiio-dev \
  liblapack-dev \
  libmatio-dev \
  libssl-dev \
  libsndfile1-dev \
  liborc-0.4-dev \
  libpcap-dev \
  libprotobuf-dev \
  libuhd-dev \
  libpugixml-dev \
  libusb-1.0-0-dev \
  libxml2-dev \
  nano \
  protobuf-compiler \
  python3-mako \
  texlive-latex-base \
  texlive-fonts-recommended \
  texlive-font-utils \
  texlive-pictures \
  epstool \
  fig2dev \
  octave \
  pstoedit \
  gnuplot-x11 \
  fonts-freefont-otf \
  wget \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV APPDATA=/root
ENV PYTHONPATH=/usr/lib/python3/dist-packages

RUN git config --global http.postBuffer 52428800 && \
  git clone https://github.com/rtlsdrblog/rtl-sdr-blog.git && \
  cd rtl-sdr-blog && mkdir -p build && cd build && cmake -DCMAKE_INSTALL_PREFIX=/usr .. && make && make install && ldconfig && \
  cd /build_dir && rm -rf *

RUN git clone https://github.com/osmocom/gr-osmosdr.git && \
  cd gr-osmosdr && mkdir -p build && cd build && cmake -DCMAKE_INSTALL_PREFIX=/usr .. && make && make install && ldconfig && \
  cd /build_dir && rm -rf *

ARG GITHUB_USER=gnss-sdr
ARG GITHUB_REPO=gnss-sdr
ARG GITHUB_BRANCH=next

RUN git config --global http.postBuffer 157286400 && git clone https://github.com/${GITHUB_USER}/${GITHUB_REPO}.git --depth 1 && \
  cd gnss-sdr && git fetch --unshallow && git remote set-branches origin ${GITHUB_BRANCH} && git fetch origin ${GITHUB_BRANCH} && git checkout ${GITHUB_BRANCH} && \
  cmake -S . -B build-docker -DENABLE_OSMOSDR=ON -DENABLE_FMCOMMS2=ON -DENABLE_PLUTOSDR=ON -DENABLE_RAW_UDP=ON -DENABLE_ZMQ=ON -DENABLE_PACKAGING=ON -DENABLE_INSTALL_TESTS=ON && \
  cmake --build build-docker && \
  cmake --install build-docker && cd /home && rm -rf /build_dir

WORKDIR /home
RUN /usr/bin/volk_profile -v 8111
RUN /usr/local/bin/volk_gnsssdr_profile

