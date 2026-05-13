FROM tensorflow/tensorflow:2.10.0-gpu

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    python3 python3-pip make clang gdb zip unzip nano libssl-dev liblzma-dev \
    git build-essential libstdc++-10-dev libz-dev autotools-dev \
    automake autoconf autoconf-archive libtool libarchive-dev cmake libgss-dev \
    libglib2.0-dev libfdt-dev libpixman-1-dev zlib1g-dev ninja-build wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*



# Set up MLFuzz
RUN mkdir /mlfuzz

# Download AFL
RUN git clone https://github.com/google/AFL /afl && \
    cd /afl && \
    git checkout 61037103ae3722c8060ff7082994836a794f978e

# Stable release as of 4/3/2026
# Download AFL++
RUN git clone https://github.com/AFLplusplus/AFLplusplus.git /aflpp && \
    cd /aflpp && \
    git checkout v4.40c

# Download AFL fuzzing driver for libafl targets
RUN wget https://raw.githubusercontent.com/llvm/llvm-project/5feb80e748924606531ba28c97fe65145c65372e/compiler-rt/lib/fuzzer/afl/afl_driver.cpp -O /afl/afl_driver.cpp

# Build AFL++; use AFL_NO_X86 to skip flaky tests.
RUN cd /aflpp && unset CFLAGS && unset CXXFLAGS && \
    export CC=clang && export AFL_NO_X86=1 && \
    PYTHON_INCLUDE=/ make && make install && \
    make -C utils/aflpp_driver && \
    cp utils/aflpp_driver/libAFLDriver.a /

# Build AFL; use AFL_NO_X86 to skip flaky tests
COPY mlfuzz/fuzzers/afl_experiments/afl-fuzz.c_fixed_seed.patch /afl/
RUN cd /afl && unset CFLAGS && unset CXXFLAGS \
    && patch afl-fuzz.c < afl-fuzz.c_fixed_seed.patch \
    && export CC=clang && export CXX=clang++ \
    && export AFL_NO_X86=1 && make \
    && cd llvm_mode && make



# Set up Neuzz++
RUN git clone https://github.com/boschresearch/neuzzplusplus.git /neuzzpp
COPY mlfuzz/fuzzers/neuzzpp_experiments/neuzzpp_deps.patch /tmp/
COPY mlfuzz/fuzzers/neuzzpp_experiments/neuzzpp_aflpp_compat.patch /tmp/

# Install poetry into the base image's Python environment so it sits alongside
# the already-installed tensorflow rather than in a separate venv.
ENV POETRY_VIRTUALENVS_CREATE=false
RUN pip3 install poetry
RUN cd /neuzzpp && \
    patch -p1 < /tmp/neuzzpp_deps.patch && \
    patch -p1 < /tmp/neuzzpp_aflpp_compat.patch && \
    poetry lock --no-update && \
    poetry install --no-dev --no-interaction


# Build Neuzz++ plugin for AFL++
ENV AFL_PATH=/aflpp
ENV NEUZZPP_PATH=/neuzzpp
RUN cd /neuzzpp/aflpp-plugins && make

# Install Neuzz
RUN git clone https://github.com/ammaraskar/neuzz.git /neuzz \
    && cd /neuzz \
    && git checkout e93c7a4c625aa1a17ae2f99e5902d62a46eaa068

WORKDIR "/neuzz"
COPY mlfuzz/fuzzers/neuzz_experiments/* .
RUN chmod -R a+rwX . \
    && patch neuzz.c < neuzz.c_fixed_seed.patch \
    && clang -O3 -funroll-loops ./neuzz.c -o neuzz \
    && patch nn.py < nn.py_tf2.patch
