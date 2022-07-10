shields=sofle_left sofle_right
config=${PWD}/config
mountpoint=/media/psf/NICENANO
zmk_image=zmkfirmware/zmk-dev-arm:3.0-branch

docker_options= \
	--interactive \
	--tty \
	--name zmk-$@ \
	--workdir /zmk \
	--volume zmk:/zmk \
	--volume "${config}:/zmk-config:Z" \
	${zmk_image}

board=nice_nano_v2

codebase:
	docker run ${docker_options} sh -c '\
		git clone https://github.com/zmkfirmware/zmk /zmk/; \
		west init -l /zmk/app/; \
		west update'

$(shields):
	docker run --rm ${docker_options} \
		west build -s /zmk/app --board "${board}" -- -DSHIELD="$@" -DZMK_CONFIG="/zmk/config"
	docker cp zmk-codebase:/zmk/build/zephyr/zmk.uf2 $@.uf2

shell:
	docker run --rm ${docker_options} /bin/bash

clean:
	docker ps -aq --filter name='^zmk' | xargs -r docker container rm
	docker volume list -q --filter name='zmk' | xargs -r docker volume rm
	find *.uf2 -type f -delete
