# named

docker image for a location aware bind DNS server with GeoIP support

Docker Hub: [hub.docker.com/r/lu1as/named](https://hub.docker.com/r/lu1as/named)

# How to start

Make sure that you clone the repository with git-lfs enabled, otherwise the database files won't be downloaded correctly.

The GeoIP databases aren't part of the image. They have to be mounted to `/usr/share/GeoIP` at container start. This allows using commercial non-free databases and reduces the image size.

```shell
docker run -v $PWD/geoip:/usr/share/GeoIP \
    -v $PWD/named.conf:/etc/bind/named.conf \
    -p 53:53/udp lu1as/named
```

## GeoIP

GeoIP databases in `./geoip` and are extracted from [ubuntu package](https://packages.ubuntu.com/bionic/geoip-database-extra) `geoip-database-extra`
