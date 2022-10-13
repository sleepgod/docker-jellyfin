FROM lsiobase/ubuntu:focal

# set version label
# ARG BUILD_DATE
# ARG VERSION
# ARG JELLYFIN_RELEASE
LABEL build_version="sleepgod version:nightly Build-date:20221013111259"
LABEL maintainer="sleepgod"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV NVIDIA_DRIVER_CAPABILITIES="compute,video,utility"

RUN \
 echo "**** install packages ****" && \
 apt-get update && \
 apt-get install -y ca-certificates --no-install-recommends \
	gnupg curl apt-utils && \
 echo "**** install jellyfin *****" && \
 curl -s https://repo.jellyfin.org/ubuntu/jellyfin_team.gpg.key | apt-key add - && \
 echo 'deb [arch=amd64] https://repo.jellyfin.org/ubuntu focal main' > /etc/apt/sources.list.d/jellyfin.list && \
 echo 'deb [arch=amd64] https://repo.jellyfin.org/ubuntu focal unstable' >> /etc/apt/sources.list.d/jellyfin.list && \
 if [ -z ${JELLYFIN_RELEASE+x} ]; then \
        JELLYFIN="jellyfin"; \
 else \
        JELLYFIN="jellyfin=${JELLYFIN_RELEASE}"; \
 fi && \
 apt-get update && \
#	${JELLYFIN} \
apt-get install -y --no-install-recommends \
	at \
	xfonts-wqy \
	fonts-wqy-zenhei \
	fonts-wqy-microhei \
	jellyfin-ffmpeg \
	jellyfin-server \
	jellyfin-web \
	libfontconfig1 \
	libfreetype6 \
	libssl1.1 \
	vainfo \
	mesa-va-drivers \
	intel-media-va-driver-non-free && \
 echo "**** cleanup ****" && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

# add local files
COPY root/ / 

# ports and volumes
EXPOSE 8096 8920
VOLUME /config
