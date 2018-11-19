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

direct:
	docker build -t $(NAME_DIRECT) --build-arg SYSTEM_TYPE="direct" .

docker:
	docker build -t $(NAME_DOCKER) --build-arg SYSTEM_TYPE="docker" .

clean:

rmi:
	docker rmi $(NAME_DIRECT) $(NAME_DOCKER)

bash-direct:
	docker run -it --rm $(DIRECT_VOLUME_OPTS) $(NAME_DIRECT) /bin/bash

bash-docker:
	docker run -it --rm $(DIRECT_VOLUME_OPTS) $(NAME_DOCKER) /bin/bash

start-direct:
	docker run -d $(DIRECT_VOLUME_OPTS) $(NAME_DIRECT)

start-docker:
	docker run -d $(DIRECT_VOLUME_OPTS) $(NAME_DOCKER)

push-direct:
	docker push $(NAME_DIRECT)

push-docker:
	docker push $(NAME_DOCKER)
