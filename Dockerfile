FROM node:16 as js-build
WORKDIR /gotty
COPY /assests/gotty-1.5.0/js /gotty/js
COPY /assests/gotty-1.5.0/Makefile /gotty/
RUN make bindata/static/js/gotty.js.map

FROM golang:1.16 as go-build
WORKDIR /gotty
ADD /assests/gotty-1.5.0 /gotty
COPY --from=js-build /gotty/js/node_modules /gotty/js/node_modules
COPY --from=js-build /gotty/bindata/static/js /gotty/bindata/static/js
RUN CGO_ENABLED=0 make

FROM alpine:3.17 AS builder

RUN apk add --no-cache \
        build-base \
        libmaxminddb-dev \
        ncurses-dev \
        musl-locales \   
        gettext-dev

# set up goacess
WORKDIR /goaccess
COPY /assests/goaccess/goaccess-1.7.tar.gz goaccess.tar.gz
RUN tar --strip-components=1  -xzvf goaccess.tar.gz
RUN ./configure --enable-utf8 --enable-geoip=mmdb --with-getline
RUN make
RUN make install

FROM golang:alpine
RUN apk add --no-cache \
        ca-certificates \
        bash \
        tini \
        wget \
        curl \
        libmaxminddb \
        tzdata \        
        gettext \
        musl-locales \
        ncurses && \
    rm -rf /var/lib/apt/lists/*

# begin - gotty
COPY --from=go-build /gotty/gotty /usr/bin/
ADD /assests/gotty/.gotty /root/.gotty
# end - gotty

COPY --from=builder /goaccess /goaccess
COPY --from=builder /usr/local/share/locale /usr/local/share/locale

COPY /resources/goaccess/goaccess.conf /goaccess-config/goaccess.conf.bak
COPY /assests/maxmind/GeoLite2-City.mmdb /goaccess-config/GeoLite2-City.mmdb
COPY /assests/maxmind/GeoLite2-ASN.mmdb /goaccess-config/GeoLite2-ASN.mmdb
COPY /assests/maxmind/GeoLite2-Country.mmdb /goaccess-config/GeoLite2-Country.mmdb

# goaccess logs
WORKDIR /goaccess-logs

WORKDIR /goan
ADD /resources/scripts/funcs funcs
ADD /resources/scripts/logs logs
COPY /resources/scripts/start.sh start.sh
RUN chmod +x start.sh

VOLUME ["/opt/log"]
EXPOSE 7880
ENTRYPOINT ["tini", "--", "/goan/start.sh"]