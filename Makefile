############################### change if needed ###############################
CONTAINER=pzserver
VOLUME=/data/dockers/${CONTAINER}
IMAGE=fingerland/${CONTAINER}
OPTIONS=-v ${VOLUME}:/server -p 8766:8766 -p 16261:16261/udp -p 16262:16262 -p 16263:16263 -p 16264:16264 -p 16265:16265 -p 16266:16266 -p 16267:16267 -p 16268:16268 -p 16269:16269 -p 16270:16270
################################ computed data #################################
SERVICE_ENV_FILE=${PWD}/${CONTAINER}.env
SERVICE_FILE=${PWD}/${CONTAINER}.service
################################################################################

help:
	@echo "Fingerland Project Zomboid (docker builder)"

build:
	@docker build -t ${IMAGE} .

volume:
	@mkdir -p ${VOLUME}
	@chown -R 1000:1000 ${VOLUME}

stop:
	@docker kill ${CONTAINER} || echo ""
	@docker rm ${CONTAINER} || echo ""

run: volume stop
	@docker run --restart=always -d -ti ${OPTIONS} --name=${CONTAINER} ${IMAGE}
	@docker logs -f ${CONTAINER}

systemd-service:
	@cp service.sample ${SERVICE_FILE}
	@sed -i -e "s;ExecStartPre=-/usr/bin/docker pull.*$$;ExecStartPre=-/usr/bin/docker pull ${IMAGE};"  ${SERVICE_FILE}
	@sed -i -e "s;ExecStartPre=-/usr/bin/docker rm.*$$;ExecStartPre=-/usr/bin/docker rm ${CONTAINER};"  ${SERVICE_FILE}
	@sed -i -e "s;ExecStartPre=-/usr/bin/docker kill.*$$;ExecStartPre=-/usr/bin/docker kill ${CONTAINER};"  ${SERVICE_FILE}
	@sed -i -e "s;ExecStart=.*$$;ExecStart=/usr/bin/docker run -i --name=${CONTAINER} ${OPTIONS} ${IMAGE};"  ${SERVICE_FILE}
	@sed -i -e "s;ExecStop=.*$$;ExecStop=/usr/bin/docker stop ${CONTAINER};"  ${SERVICE_FILE}
	@systemctl enable ${SERVICE_FILE}
	@systemctl daemon-reload

install: build volume systemd-service
	@sudo systemctl start ${CONTAINER}.service
