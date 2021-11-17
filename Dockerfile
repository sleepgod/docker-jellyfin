FROM debian:stable-slim

ADD https://github.com/just-containers/s6-overlay/releases/download/v2.2.0.3/s6-overlay-amd64.tar.gz /tmp/
RUN gunzip -c /tmp/s6-overlay-amd64.tar.gz | tar -xf - -C /
ENTRYPOINT ["/init"]

# set version label
# ARG BUILD_DATE
# ARG VERSION
# ARG JELLYFIN_RELEASE
LABEL build_version="sleepgod version:latest Build-date:20211113060955"
LABEL maintainer="sleepgod"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn
ENV NVIDIA_DRIVER_CAPABILITIES="compute,video,utility"

RUN \
 echo "**** install packages ****" && \
 apt-get update && \
 apt-get install -y ca-certificates --no-install-recommends \
	gnupg curl apt-utils wget && \
 echo "**** install jellyfin 1*****" && \
 curl -s https://repo.jellyfin.org/jellyfin_team.gpg.key | apt-key add - && \
 echo "**** install jellyfin 2*****" && \
 echo 'deb [arch=amd64] https://repo.jellyfin.org/debian bullseye main' > /etc/apt/sources.list.d/jellyfin.list && \
 if [ -z ${JELLYFIN_RELEASE+x} ]; then \
        JELLYFIN="jellyfin"; \
 else \
        JELLYFIN="jellyfin=${JELLYFIN_RELEASE}"; \
 fi && \
 apt-get update && \
 apt-get install -y --no-install-recommends \
	at \
	xfonts-wqy \
	fonts-wqy-zenhei \
	fonts-wqy-microhei \
	${JELLYFIN} \
	libfontconfig1 \
	libfreetype6 \
	vainfo \
	libssl1.1 && \
 echo "**** cleanup ****" && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/* \
  && mkdir intel-compute-runtime \
  && cd intel-compute-runtime \
  && wget https://github.com/intel/compute-runtime/releases/download/21.45.21574/intel-gmmlib_21.2.1_amd64.deb \
  && wget https://github.com/intel/intel-graphics-compiler/releases/download/igc-1.0.8744/intel-igc-core_1.0.8744_amd64.deb \
  && wget https://github.com/intel/intel-graphics-compiler/releases/download/igc-1.0.8744/intel-igc-opencl_1.0.8744_amd64.deb \
  && wget https://github.com/intel/compute-runtime/releases/download/21.45.21574/intel-opencl-icd_21.45.21574_amd64.deb \
  && wget https://github.com/intel/compute-runtime/releases/download/21.45.21574/intel-level-zero-gpu_1.2.21574_amd64.deb \
  && dpkg -i *.deb \
  && cd .. \
  && rm -rf intel-compute-runtime \
  && echo "**** create abc user and make our folders ****" \
  && useradd -u 911 -U -d /config -s /bin/false abc \
  && usermod -G users abc
 
# add local files
COPY root/ / 

# ports and volumes
EXPOSE 8096 8920
VOLUME /config
