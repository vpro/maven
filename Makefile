TAG := $(shell git symbolic-ref -q --short HEAD || git describe --tags --exact-match)
IMAGE := vpro/maven:$(TAG)
MMIMAGE:=mmbase/maven:$(TAG)

TARGET=vpro/maven:dev
.PHONY: help explore magnolia

help:     ## Show this help.
	@sed -n 's/^##//p' $(MAKEFILE_LIST)
	@grep -E '^[/%a-zA-Z._-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


docker: Dockerfile after_maven.sh ## Build the docker file
	docker build -t $(TARGET) .
	touch $@

explore: docker    ## Just give bash on it
	docker run -v `pwd`:/build  --entrypoint bash -it $(TARGET)


exploremaven:      ## just run the maven docker image
	docker run --entrypoint bash -it $$(awk '$$1 == "FROM" {print $$2}' Dockerfile)

magnolia:          ## Mount your magnolia checkout in it in /build. You can check whether it would build with this image
	(cd ~/vpro/magnolia/trunk ; \
	docker run -v `pwd`:/build -w /build --entrypoint bash -it $(TARGET))



clean:
	rm docker


# lets try to push a verison in docker.io, just to try out whether we then can  in gitlab'
# 'Enable the Dependency Proxy to cache container images from Docker Hub and automatically clear the cache.'
mmdocker: ## build image locally for upload in docker.io/mmbase
	docker buildx  build --platform linux/amd64  -t $(MMIMAGE) .


mmpush:
	docker image push $(MMIMAGE)