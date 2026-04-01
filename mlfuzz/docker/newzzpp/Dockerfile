FROM mlfuzz-base:1.0

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# System stuff
RUN apt-get update && apt-get install -y --no-install-recommends \
    llvm-dev \
    libtool-bin \
    bison \
    flex \
    curl \
    ca-certificates \
    python3 \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*



COPY newzzplusplus/ /newzzplusplus/

# Python Stuff
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:${PATH}"




WORKDIR /newzzplusplus
RUN uv venv .venv && \
    . .venv/bin/activate && \
    uv pip install --upgrade pip && \
    uv pip install -r requirements.in && \
    uv pip install -r requirements-cuda.txt && \
    uv pip install -e /newzzplusplus

ENV PATH="/newzzplusplus/.venv/bin:${PATH}"

# Development stuff
WORKDIR /workspace


CMD ["bash"]
