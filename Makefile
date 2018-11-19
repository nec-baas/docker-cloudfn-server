NAME_DIRECT = necbaas/cloudfn-server:7.5-direct
NAME_DOCKER = necbaas/cloudfn-server:7.5-docker

VOLUME_LOG_OPTS = -v $(PWD)/logs:/var/log/cloudfn:rw
VOLUME_USER_CODE_OPTS = -v $(PWD)/usercode:/var/cloudfn/usercode
VOLUME_DOCKER_SOCKET_OPTS = -v /var/run/docker.sock:/var/run/docker.sock

DIRECT_VOLUME_OPTS = $(VOLUME_LOG_OPTS)
DOCKER_VOLUME_OPTS = $(VOLUME_LOG_OPTS) $(VOLUME_USER_CODE_OPTS) $(VOLUME_DOCKER_SOCKET_OPTS)

all: direct docker

#download:
#	@./download.sh

update: Dockerfile.direct Dockerfile.docker

Dockerfile.direct: Dockerfile.in
	@cat Dockerfile.in | sed "s/%%SYSTEM_TYPE%%/direct/" > $@

Dockerfile.docker: Dockerfile.in
	@cat Dockerfile.in | sed "s/%%SYSTEM_TYPE%%/docker/" > $@

direct:
	docker image build -t $(NAME_DIRECT) -f Dockerfile.direct .

docker:
	docker image build -t $(NAME_DOCKER) -f Dockerfile.docker .

clean:

rmi:
	docker image rm $(NAME_DIRECT) $(NAME_DOCKER)

bash-direct:
	docker container run -it --rm $(DIRECT_VOLUME_OPTS) $(NAME_DIRECT) /bin/bash

bash-docker:
	docker container run -it --rm $(DIRECT_VOLUME_OPTS) $(NAME_DOCKER) /bin/bash

start-direct:
	docker container run -d $(DIRECT_VOLUME_OPTS) $(NAME_DIRECT)

start-docker:
	docker container run -d $(DIRECT_VOLUME_OPTS) $(NAME_DOCKER)

push-direct:
	docker image push $(NAME_DIRECT)

push-docker:
	docker image push $(NAME_DOCKER)
