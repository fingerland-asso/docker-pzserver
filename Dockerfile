FROM fingerland/lgsm
MAINTAINER Caderrik <caderrik@gmail.com>

ENV SERVER=pzserver
USER root
RUN apt-get install -qq default-jre
USER lgsm
EXPOSE 8766 16261/udp 16262 16263 16264 16265 16266 16267 16268 16269 16270
