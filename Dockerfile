FROM alpine:3.9 as builder

ARG BIND_VERSION="9.11.18"

# get build dependencies and compile source
RUN apk --update --no-cache add alpine-sdk openssl-dev geoip-dev libxml2-dev json-c-dev perl linux-headers \
	&& mkdir -p /usr/local/src/bind \
    && wget -O /usr/local/src/bind.tar.gz https://downloads.isc.org/isc/bind9/${BIND_VERSION}/bind-${BIND_VERSION}.tar.gz \
	&& tar -xf /usr/local/src/bind.tar.gz -C /usr/local/src \
	&& cd /usr/local/src/bind-* \
	&& ./configure \
		--build=x86_64-alpine-linux-musl \
		--host=x86_64-alpine-linux-musl \
		--prefix=/usr/local/src/bind \
		--sysconfdir=/etc/bind \
		--localstatedir=/var \
		--with-openssl=/usr \
		--enable-linux-caps \
		--with-libxml2 \
		--with-libjson \
		--with-geoip \
		--enable-threads \
		--enable-filter-aaaa \
		--enable-ipv6 \
		--enable-shared \
		--enable-static \
		--with-libtool \
		--without-python \
		--with-randomdev=/dev/random \
		--mandir=/usr/share/man \
		--infodir=/usr/share/info \
	&& make \
	&& make install

# use clean image
FROM alpine:3.9

LABEL maintainer="lukas.steiner@steinheilig.de"
LABEL repository="github.com/lu1as/docker-named"
LABEL version=${BIND_VERSION}

# copy compiled stuff and geoip databases
COPY --from=builder /usr/local/src/bind /usr
COPY --from=builder /etc/bind /etc/bind

# install dependencies
RUN apk --update --no-cache add libgcc geoip libxml2 json-c libcap libcrypto1.1 musl zlib \
	&& addgroup -S -g 101 named \
	&& adduser -S -h /etc/bind -s /sbin/nologin -D -H -u 100 named \
	&& mkdir /var/bind /var/run/named \
	&& chown named:named /var/bind /var/run/named

COPY named.conf /etc/bind/named.conf
EXPOSE 53
CMD ["/usr/sbin/named", "-g", "-u", "named", "-c", "/etc/bind/named.conf"]
