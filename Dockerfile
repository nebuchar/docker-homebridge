ARG S6_ARCH
FROM oznu/s6-node:14.17.4-ubuntu-arm32v7

RUN apt-get update \
  && apt-get install -y git python make g++ libnss-mdns avahi-discover libavahi-compat-libdnssd-dev \
    bash net-tools iproute2 sudo nano vim \
    bluetooth bluez libbluetooth-dev libudev-dev \
    musl-dev \
  && apt-get clean \
  && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/* \
  && chmod 4755 /bin/ping \
  && mkdir /homebridge \
  && npm set global-style=true \
  && npm set audit=false \
  && npm set fund=false

RUN ln -s  /usr/lib/arm-linux-musleabihf/libc.so /lib/libc.musl-armhf.so.1

RUN case "$(uname -m)" in \
    x86_64) FFMPEG_ARCH='x86_64';; \
    armv6l) FFMPEG_ARCH='armv6l';; \
    armv7l) FFMPEG_ARCH='armv7l';; \
    aarch64) FFMPEG_ARCH='aarch64';; \
    *) echo "unsupported architecture"; exit 1 ;; \
    esac \
    && set -x \
    && curl -Lfs https://github.com/oznu/ffmpeg-for-homebridge/releases/download/v0.0.9/ffmpeg-debian-${FFMPEG_ARCH}.ta$
ENV PATH="${PATH}:/homebridge/node_modules/.bin"

ENV HOMEBRIDGE_VERSION=1.3.4
RUN npm install -g --unsafe-perm homebridge@${HOMEBRIDGE_VERSION}

ENV CONFIG_UI_VERSION=4.41.2 HOMEBRIDGE_CONFIG_UI=1 HOMEBRIDGE_CONFIG_UI_PORT=8581
RUN npm install -g --unsafe-perm homebridge-config-ui-x@${CONFIG_UI_VERSION}

RUN sudo setcap cap_net_raw+eip $(eval readlink -f `which node`)

WORKDIR /homebridge
VOLUME /homebridge

COPY root /

ARG AVAHI
ENV ENABLE_AVAHI="${AVAHI:-0}"
