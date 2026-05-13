FROM pytorch/pytorch:2.11.0-cuda13.0-cudnn9-runtime

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    make clang gdb zip unzip nano libssl-dev liblzma-dev \
    git build-essential libstdc++-12-dev libz-dev autotools-dev \
    automake autoconf autoconf-archive libtool libarchive-dev cmake libgss-dev \
    libglib2.0-dev libfdt-dev libpixman-1-dev zlib1g-dev ninja-build wget curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set up MLFuzz
RUN mkdir /mlfuzz

# Stable release as of 4/3/2026
# Download and build AFL++
RUN git clone https://github.com/AFLplusplus/AFLplusplus.git /aflpp && \
    cd /aflpp && \
    git checkout v4.40c

RUN cd /aflpp && unset CFLAGS && unset CXXFLAGS && \
    export CC=clang && export AFL_NO_X86=1 && \
    PYTHON_INCLUDE=/ make && make install && \
    make -C utils/aflpp_driver && \
    cp utils/aflpp_driver/libAFLDriver.a /

ENV AFL_PATH=/aflpp

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:${PATH}"

# Set up Newzz++
COPY newzzplusplus/ /newzzplusplus/

# Create venv and install Python deps separately from the base image's Python so
# the torch version in requirements-cuda.txt (2.9.1+cu130) doesn't conflict with
# whatever pytorch/pytorch ships.
RUN uv venv /venv
ENV PATH="/venv/bin:${PATH}"

RUN uv pip install --python /venv/bin/python \
        -r /newzzplusplus/requirements.in \
        -r /newzzplusplus/requirements-cuda.txt && \
    uv pip install --python /venv/bin/python -e /newzzplusplus

# Build Newzz++ AFL++ custom mutator plugin
ENV NEUZZPP_PATH=/newzzplusplus
RUN cd /newzzplusplus/aflpp-plugins && make

WORKDIR /workspace
CMD ["bash"]
