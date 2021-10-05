TARGET=vpro-maven:dev
.PHONY: run

docker: Dockerfile
	docker build -t $(TARGET) .
	touch $@

explore: docker
	docker run -it $(TARGET) bash





