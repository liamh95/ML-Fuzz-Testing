.PHONY: images base neuzzpp newzzpp

images: base neuzzpp newzzpp

base:
    docker build -f docker/base/Dockerfile -t mlfuzz-base:1.0 .

neuzzpp: base
    docker build -f docker/neuzzpp/Dockerfile -t mlfuzz-neuzzpp:1.0 .

newzzpp: base
    docker build -f docker/newzzpp/Dockerfile -t mlfuzz-newzzpp:1.0 .