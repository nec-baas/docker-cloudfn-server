NAME = necbaas/cloudfn-server

VOLUME_OPTS = -v $(PWD)/logs:/var/log/cloudfn:rw

all: download cloudfn-server

download:
	@./download.sh

cloudfn-server:
	docker build -t $(NAME) .

clean:

rmi:
	docker rmi $(NAME)

bash:
	docker run -it --rm $(NAME) /bin/bash

start:
	docker run -d $(VOLUME_OPTS) $(NAME)
