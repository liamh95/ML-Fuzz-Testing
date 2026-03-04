#!/usr/bin/env bash
set -e

cd "$(dirname "$0")"

TARGET=binaries/curl.neuzzpp_torch
INPUT_DIR=input
OUTPUT_DIR=output

MUTATOR_SO=../aflpp-plugins/ml-mutator.so

if [ ! -f "$TARGET" ]; then
    echo "[!] Target not built. Run ./build.sh first."
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

echo "[*] Starting AFL++ fuzzing..."

AFL_CUSTOM_MUTATOR_LIBRARY="$MUTATOR_SO" \
AFL_SKIP_CPUFREQ=1 \
afl-fuzz \
    -i "$INPUT_DIR" \
    -o "$OUTPUT_DIR" \
    -- "$TARGET" @@
