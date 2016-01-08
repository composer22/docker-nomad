FROM sdurrheimer/alpine-glibc:latest

ENV GOSU_VERSION=1.7 \
    NOMAD_VERSION=0.2.3 \
    NOMAD_SHA256=0f3a7083d160893a291b5f8b4359683c2df7991fa0a3e969f8785ddb40332a8c

ADD entrypoint.sh .

RUN apk add --update -t build-deps wget unzip ca-certificates \
    && wget -O /nomad_${NOMAD_VERSION}_linux_amd64.zip https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip \
    && echo "${NOMAD_SHA256}  nomad_${NOMAD_VERSION}_linux_amd64.zip" > /nomad.sha256 \
    && sha256sum -c /nomad.sha256 \
    && wget --no-check-certificate https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64 \
    && unzip nomad_${NOMAD_VERSION}_linux_amd64.zip \
    && rm -f nomad_${NOMAD_VERSION}_linux_amd64.zip \
    && rm -f nomad.sha256 \
    && mv nomad /usr/bin/nomad \
    && chmod +x /usr/bin/nomad \
    && mv gosu-amd64 /usr/bin/gosu \
    && chmod +x /usr/bin/gosu \
    && addgroup nomad \
    && adduser -s /bin/false -G nomad -S -D nomad \
    && mkdir /data \
    && chown -R nomad:nomad /data \
    && chmod a+x ./entrypoint.sh \
    && apk del --purge build-deps wget unzip ca-certificates \
    && rm -rf /var/cache/apk/*

EXPOSE      4646/tcp 4646/udp 4647/tcp 4647/udp 4648/tcp 4648/udp
VOLUME      ["/data"]
WORKDIR     /data
ENTRYPOINT  ["/entrypoint.sh"]
CMD         ["-h"]
