FROM ubuntu:22.04



RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    python3 python3-pip make clang gdb zip unzip nano libssl-dev liblzma-dev \
    git build-essential python3-venv make libstdc++-12-dev libz-dev autotools-dev \
    automake autoconf autoconf-archive libtool libarchive-dev cmake libgss-dev\
	libglib2.0-dev libfdt-dev libpixman-1-dev zlib1g-dev ninja-build wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


# Set up MLFuzz
# MAYBE CHANGE THIS? Like mount this instead of baking it into the image?
RUN mkdir /mlfuzz
# We mount these instead now
# COPY scripts /mlfuzz/scripts/
# COPY README.md /mlfuzz/

# Download AFL
RUN git clone https://github.com/google/AFL /afl && \
    cd /afl && \
    git checkout 61037103ae3722c8060ff7082994836a794f978e

# Stable release as of 3/5/2026
# Download AFL++
RUN git clone https://github.com/AFLplusplus/AFLplusplus.git /aflpp && \
    cd /aflpp && \
    git checkout b449e4c544eaac1a0a9b7d1f2f15d5921907585e

# Download AFL fuzzing driver for libafl targets
RUN wget https://raw.githubusercontent.com/llvm/llvm-project/5feb80e748924606531ba28c97fe65145c65372e/compiler-rt/lib/fuzzer/afl/afl_driver.cpp -O /afl/afl_driver.cpp

# Build AFL++; use AFL_NO_X86 to skip flaky tests.
RUN cd /aflpp && unset CFLAGS && unset CXXFLAGS && \
    export CC=clang && export AFL_NO_X86=1 && \
    PYTHON_INCLUDE=/ make && make install && \
    make -C utils/aflpp_driver && \
    cp utils/aflpp_driver/libAFLDriver.a /

# Mount this instead
# COPY fuzzers/aflpp_experiments/run_aflpp.py /aflpp/

# Build AFL; use AFL_NO_X86 to skip flaky tests
COPY fuzzers/afl_experiments/afl-fuzz.c_fixed_seed.patch /afl/
RUN cd /afl && unset CFLAGS && unset CXXFLAGS \
    && patch afl-fuzz.c < afl-fuzz.c_fixed_seed.patch \
    && export CC=clang && export CXX=clang++ \
    && export AFL_NO_X86=1 && make \
    && cd llvm_mode && make


# Stuff for other fuzzers

# Install Havoc MAB
# RUN git clone https://github.com/MagicHavoc/Havoc-Study /havoc \
#     && cd /havoc \
#     && git checkout 7ed4805a2e09cc734ec47f88b3dab144db7195c8 \
#     && mv fuzzers/Havoc_DMA/* .

# WORKDIR "/havoc"
# COPY fuzzers/havoc_experiments/* .
# RUN chmod -R a+rwX . \
#     && patch afl-fuzz.c < afl-fuzz.c_fixed_seed.patch \
#     && make -j



# Install Darwin
# RUN git clone https://github.com/TUDA-SSL/DARWIN.git /darwin
# WORKDIR "/darwin"
# COPY fuzzers/darwin_experiments/* .
# RUN chmod -R a+rwX . \
#     && patch afl-fuzz.c < afl-fuzz.c_fixed_seed.patch \
#     && make \
#     && make install

# Install MOPT (based on AFL)
# RUN git clone https://github.com/puppet-meteor/MOpt-AFL.git /mopt \
#     && cd /mopt \
#     && mv MOpt/* .

# WORKDIR "/mopt"
# COPY fuzzers/mopt_experiments/* .
# RUN chmod -R a+rwX . \
#     && patch afl-fuzz.c < afl-fuzz.c_fixed_seed.patch \
#     && make \
#     && make install

# Install MOPT++ (based on AFL++)
# RUN git clone https://github.com/kupl/SeamFuzz-Artifact.git /moptpp \
#     && cd /moptpp \
#     && mv fuzzers/aflppmopt/afl/* .

# WORKDIR "/moptpp"
# COPY fuzzers/moptpp_experiments/run_moptpp.py .
# RUN chmod -R a+rwX . \
#     && make \
#     && make install

# Install PreFuzz
# RUN git clone https://github.com/PoShaung/program-smoothing-fuzzing.git /prefuzz \
#     && cd /prefuzz \
#     && git checkout 60d1c2cd1ee460dcc6facdab92e96df7f44fdb3a \
#     && mv fuzzers/RESuzz/RESuzz/* .

# # We need to run the prefuzz python script in the prefuzz folder :/
# WORKDIR "/prefuzz"
# COPY fuzzers/prefuzz_experiments/* .
# # Patch Prefuzz to fix port number for modules comms
# RUN chmod -R a+rwX . \
#     && patch nn.py < nn.py_add_asan.patch \
#     && patch fuzz.c < fuzz.c_all.patch \
#     && patch utils/utils.py < utils.py_add_asan.patch \
#     && clang -O3 -funroll-loops ./fuzz.c -o prefuzz
