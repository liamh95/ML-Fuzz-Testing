FROM mlfuzz-base:1.0

# Fix CUDA keys if using GPU base - not needed since we're using our own base
# Install Python deps for neuzz++
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    python3-venv \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set up Neuzz++
RUN git clone https://github.com/boschresearch/neuzzplusplus.git /neuzzpp
WORKDIR "/neuzzpp"

# Apply compatibility patch for newer AFL++
COPY patches/neuzzpp_aflpp_compat.patch /tmp/
RUN patch -p1 < /tmp/neuzzpp_aflpp_compat.patch

RUN python3 -m venv /venv && \
    /venv/bin/pip install --upgrade pip && \
    /venv/bin/pip install poetry && \
    /venv/bin/poetry install --no-dev --no-interaction
ENV PATH=/venv/bin:$PATH

# Build Neuzz++ plugin for AFL++
ENV AFL_PATH=/aflpp
ENV NEUZZPP_PATH=/neuzzpp
RUN cd /neuzzpp/aflpp-plugins && make

# Install Neuzz
RUN git clone https://github.com/ammaraskar/neuzz.git /neuzz \
    && cd /neuzz \
    && git checkout e93c7a4c625aa1a17ae2f99e5902d62a46eaa068

WORKDIR "/neuzz"
COPY fuzzers/neuzz_experiments/* .
RUN chmod -R a+rwX . \
    && patch neuzz.c < neuzz.c_fixed_seed.patch \
    && clang -O3 -funroll-loops ./neuzz.c -o neuzz \
    && patch nn.py < nn.py_tf2.patch