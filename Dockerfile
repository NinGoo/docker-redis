FROM ningoo/ubuntu:latest
MAINTAINER ningoo@dtstack.com

RUN apt-get update && DEBIAN_FRONTEND=noninteractive && apt-get install -y make gcc libc6-dev\
 && wget http://download.redis.io/releases/redis-3.0.5.tar.gz \
 && tar zxvf redis-3.0.5.tar.gz \
 && cd redis-3.0.5 && make -j 2 \
 && cd src && cp redis-cli redis-server redis-sentinel /usr/bin/ \
 && mkdir /etc/redis && cd .. && cp redis.conf /etc/redis/redis.conf \
 && sed 's/^daemonize yes/daemonize no/' -i /etc/redis/redis.conf \
 && sed 's/^bind 127.0.0.1/bind 0.0.0.0/' -i /etc/redis/redis.conf \
 && sed 's/^# unixsocket /unixsocket /' -i /etc/redis/redis.conf \
 && sed 's/^# unixsocketperm 755/unixsocketperm 777/' -i /etc/redis/redis.conf \
 && sed '/^logfile/d' -i /etc/redis/redis.conf \
 && mkdir -p /var/lib/redis && mkdir -p /var/log/redis && mkdir -p /etc/service/redis \
 && echo "#!/bin/sh" > /etc/service/redis/run \
 && echo "sysctl -w file-max=65535" >> /etc/service/redis/run \
 && echo "ulimit -SHn 10240" >> /etc/service/redis/run \
 && echo "set -e" >> /etc/service/redis/run \
 && echo "exec /sbin/setuser redis /usr/bin/redis-server /etc/redis/redis.conf" >> /etc/service/redis/run \
 && chmod +x /etc/service/redis \
 && apt-get autoremove -y gcc make libc6-dev && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
 && cd && rm -rf redis-3.0.5.tar.gz && rm -rf redis-3.0.5

EXPOSE 6379/tcp

ENTRYPOINT ["/usr/bin/redis-server","/etc/redis/redis.conf"]
