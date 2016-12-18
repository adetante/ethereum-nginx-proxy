FROM debian:jessie

MAINTAINER Antoine Detante "antoine.detante@gmail.com"

RUN apt-get update && apt-get install -y build-essential curl libssl-dev libluajit-5.1-dev libpcre3-dev zlib1g-dev

RUN mkdir /var/log/nginx

RUN mkdir /opt/src \
  && curl -L http://nginx.org/download/nginx-1.11.7.tar.gz 2> /dev/null > /opt/src/nginx-1.11.7.tar.gz \
  && curl -L https://github.com/simpl/ngx_devel_kit/archive/v0.3.0.tar.gz 2> /dev/null > /opt/src/ngx_devel_kit-0.3.0.tar.gz \
  && curl -L https://github.com/openresty/lua-nginx-module/archive/v0.10.7.tar.gz 2> /dev/null > /opt/src/lua-nginx-module-0.10.7.tar.gz \
  && curl -L https://github.com/mpx/lua-cjson/archive/2.1.0.tar.gz 2> /dev/null > /opt/src/lua-cjson-2.1.0.tar.gz

RUN cd /opt/src && tar xfz lua-cjson-2.1.0.tar.gz && cd lua-cjson-2.1.0 \
  && sed -i.bak 's/LUA_INCLUDE_DIR =.*/LUA_INCLUDE_DIR = \/usr\/include\/luajit-2.0/g' Makefile \
  && sed -i.bak 's/LUA_MODULE_DIR =.*/LUA_MODULE_DIR = \/usr\/share\/luajit-2.0.3\/jitg/g' Makefile \
  && make && make install

RUN cd /opt/src && tar xfz nginx-1.11.7.tar.gz && tar xfz ngx_devel_kit-0.3.0.tar.gz && tar xfz lua-nginx-module-0.10.7.tar.gz

RUN cd /opt/src/nginx-1.11.7 && ./configure --prefix=/opt/nginx --with-ld-opt="-Wl,-rpath,/usr/local/lib" --add-module=/opt/src/ngx_devel_kit-0.3.0 --add-module=/opt/src/lua-nginx-module-0.10.7 --with-http_ssl_module \
  && make && make install \
  && rm /opt/src/*.tar.gz

ADD nginx.conf /etc/nginx.conf
ADD eth-jsonrpc-access.lua /opt/nginx/eth-jsonrpc-access.lua

EXPOSE 80 443

CMD ["/opt/nginx/sbin/nginx", "-c", "/etc/nginx.conf"]
