#
# Dockerfile - OpenResty
#
FROM ubuntu:14.04
MAINTAINER Robin Hos @ Everdune Mobile

# Set environment.
ENV \
  DEBIAN_FRONTEND=noninteractive \
  OPENRESTY_VERSION=1.7.7.2

# Install packages.
RUN apt-get update && apt-get -y install \
  build-essential \
  curl \
  libreadline-dev \
  libncurses5-dev \
  libpcre3-dev \
  libssl-dev \
  nano \
  perl \
  wget \
  supervisor

# Expose volume for externally linked configurations
VOLUME ["/etc/nginx/external-conf.d"]

# Compile openresty from source.
RUN \
  wget http://openresty.org/download/ngx_openresty-$OPENRESTY_VERSION.tar.gz && \
  tar -xzvf ngx_openresty-*.tar.gz && \
  rm -f ngx_openresty-*.tar.gz && \
  cd ngx_openresty-* && \
  ./configure --with-pcre-jit --with-ipv6 && \
  make && \
  make install && \
  make clean && \
  cd .. && \
  rm -rf ngx_openresty-*&& \
  ln -s /usr/local/openresty/nginx/sbin/nginx /usr/local/bin/nginx && \
  ldconfig

# Nginx
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Supervisor
RUN mkdir -p /var/log/supervisor
ADD conf/supervisord.conf /etc/supervisor/supervisord.conf
ADD conf/openresty.conf /etc/supervisor/conf.d/openresty.conf

# Port
EXPOSE 80

# Daemon
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
