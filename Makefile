TARGET=vpro-maven:dev
.PHONY: help explore magnolia

help:     ## Show this help.
	@sed -n 's/^##//p' $(MAKEFILE_LIST)
	@grep -E '^[/%a-zA-Z._-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


docker: Dockerfile  ## Build the docker file
	docker build -t $(TARGET) .
	touch $@

explore: docker    ## Just give bash on it
	docker run --entrypoint bash -it $(TARGET)

magnolia:          ## Mount your magnolia checkout in it in /build. You can check whether it would build with this image
	(cd ~/vpro/magnolia/trunk ; \
	docker run -v `pwd`:/build -w /build --entrypoint bash -it $(TARGET))





