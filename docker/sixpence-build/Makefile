help:
	@echo "* build - Build the Docker Image"
	@echo "* run - Start the Container"
	@echo "* shell - Connect to the container running 'bash'"
	@echo "* start - Start the container if stopped."
	@echo "* stop - Stop the container if running/started."
	@echo "* destroy - Stop and Remove the container."
	@echo "* status - Container status"
	@echo "* clean - Clean up a bit"
	@echo "* real-clean - Clean up **everything**"

user_files:
	mkdir -p user_files
	bin/user_file.sh ${HOME}/.bashrc ./user_files/dot-bashrc
	bin/user_file.sh ${HOME}/.bash_profile ./user_files/dot-bash_profile
	bin/user_file.sh ${HOME}/.ssh/id_rsa ./user_files/dot-ssh-id_rsa

build: user_files
	docker build . -t sixpence-build:latest \
		--build-arg user=${USER} \
		--build-arg git_user="$(shell git config --global --get user.name || echo "${USER}")" \
		--build-arg git_email=$(shell git config --global --get user.email || echo "craig@caroon.org")

run:
	docker run -d -it -v /var/run/docker.sock:/var/run/docker.sock --name sixpence-build sixpence-build:latest

shell:
	docker container exec -it sixpence-build bash

start:
	docker container start sixpence-build

stop:
	docker container stop sixpence-build || echo "sixpence-build ... Not Running"

destroy: stop
	docker container rm sixpence-build || echo

status:
	@docker container list | grep sixpence-build || echo "sixpence-build ... Not Running"

clean:
	rm -rf user_files
	docker system prune -f

real-clean: destroy clean
	docker container prune -f
	docker image rm sixpence-build:latest || echo
	docker image prune -f
