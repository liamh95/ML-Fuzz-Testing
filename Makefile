.PHONY: images tf torch benchmarks

images: tf torch

tf:
	docker build -f mlfuzz/docker/tf/Dockerfile -t mlfuzz-tf:1.0 .

torch:
	docker build -f mlfuzz/docker/torch/Dockerfile -t mlfuzz-torch:1.0 .

benchmarks:
	cd mlfuzz/benchmarks && make
