FROM ubuntu:focal
MAINTAINER John Radley "jradxl@gmail.com"
ARG DEBIAN_RELEASE=focal
ARG DEBIAN_FRONTEND=noninteractive
ENV DEBIAN_FRONTEND=noninteractive
ENV NGINX_VERSION 1.18.0-1~eoan

USER root

COPY ./docker-cleanup.sh /usr/local/sbin/
COPY ./insecure.pub /tmp/

RUN \
    useradd -s /bin/bash -m -r ubuntu; \
    useradd -s /bin/bash -m  jradley; \
    useradd -s /usr/sbin/nologin -r nginx; \
    useradd -s /usr/sbin/nologin -r mysql; \
    echo "APT::Install-Recommends "false";"  > /etc/apt/apt.conf.d/zzzzz-norecommends; \
    echo "APT::Install-Suggests "false";"   >> /etc/apt/apt.conf.d/zzzzz-norecommends; \
    apt-get update; \
    apt-get -y install apt-utils; \
    apt-get upgrade; \
    apt-get -y install language-pack-en curl git openssh-server locales supervisor gnupg ca-certificates iproute2 nano net-tools python3-pip; \
    echo "=== Setting locale =================================";   \
    locale-gen en_GB.UTF-8 ;  \
    update-locale LC_ALL=en_GB.UTF-8 LANG=en_GB.UTF-8 ;  \
    echo "LC_ALL=en_GB.UTF-8" >> /etc/environment ;  \
    echo "LANG=en_GB.UTF-8"   >> /etc/environment ; \
	echo "=== Setting up 'supervisor' ========================";   \
    mkdir -p /var/log/supervisor;   \
	echo "=== Setting up 'openssh-server' ====================" ;   \
	mkdir -p /root/.ssh  chmod 700 /root/.ssh; \
    mkdir -p /run/sshd;   \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd ;   \
    echo "export VISIBLE=now in user profile" >> /etc/profile ;   \
    ssh-keygen -q -t dsa -f /root/.ssh/id_dsa -N '' -C 'keypair generated during docker build'; \
    cat /root/.ssh/id_dsa.pub > /root/.ssh/authorized_keys;  \
    chmod 600 /root/.ssh/authorized_keys; \
    echo "root:changeme"    | chpasswd ; \
    echo "ubuntu:changeme"  | chpasswd ; \
    echo "jradley:changeme" | chpasswd ; \
    cat /tmp/insecure.pub >> /root/.ssh/authorized_keys ; \    
    mkdir -p /usr/local/etc/docker/prestart-init.d;
        
RUN \
	echo "=== Setting up 'nginx' ====================" ;   \
    curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add - ; \
    echo "deb-src http://nginx.org/packages/ubuntu eoan nginx" > /etc/apt/sources.list.d/nginx-src.list ;\
    mkdir -p /var/cache/nginx ; \
    mkdir -p /var/www/nginx ; \
    apt-get update; apt-get -y install libexpat1-dev dpkg-dev libgeoip-dev libgd-dev libxslt1-dev libxml2-dev; \
    apt-get build-dep -y nginx=${NGINX_VERSION} ; \
    apt-get source nginx=${NGINX_VERSION} ;\
    cd ./nginx-[0-9]* ;\
    ./configure \
		--prefix=/etc/nginx \
		--sbin-path=/usr/sbin/nginx \
		--modules-path=/usr/lib/nginx/modules \
		--conf-path=/etc/nginx/nginx.conf \
		--error-log-path=/var/log/nginx/error.log \
		--http-log-path=/var/log/nginx/access.log \
		--pid-path=/run/nginx.pid \
		--lock-path=/run/nginx.lock \
		--http-client-body-temp-path=/var/cache/nginx/client_temp \
		--http-proxy-temp-path=/var/cache/nginx/proxy_temp \
		--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
		--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
		--http-scgi-temp-path=/var/cache/nginx/scgi_temp \
		--user=nginx \
		--group=nginx  \
		--with-compat  \
		--with-file-aio  \
		--with-threads \
		--with-http_addition_module  \
		--with-http_auth_request_module \
		--with-http_dav_module  \
		--with-http_flv_module \
		--with-http_gunzip_module \
		--with-http_gzip_static_module \
		--with-http_mp4_module  \
		--with-http_random_index_module \
		--with-http_realip_module  \
		--with-http_secure_link_module \
		--with-http_slice_module  \
		--with-http_ssl_module \
		--with-http_stub_status_module \
		--with-http_sub_module \
		--with-http_v2_module \
		--with-mail  \
		--with-mail_ssl_module \
		--with-stream  \
		--with-stream_realip_module \
		--with-stream_ssl_module  \
		--with-stream_ssl_preread_module \
		--with-cc-opt=""  \
		--with-ld-opt="" \
		--with-http_xslt_module  \
		--with-http_image_filter_module \
		--with-http_geoip_module \
		--with-pcre \
		--with-debug ; \
		make; \
		make install ; \
		cd /;

RUN \
	echo "=== Setting up 'mariadb' ====================" ;   \
    apt-get -y install software-properties-common; \
    apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc' ; \
    add-apt-repository 'deb [arch=amd64] http://mirrors.ukfast.co.uk/sites/mariadb/repo/10.5/ubuntu focal main' ; \
    apt-get update; apt -y install mariadb-server; \
    sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf ;\
    chown -R mysql:mysql /var/lib/mysql/ ; \
    mkdir -p /run/mysql ; \
    chown -R mysql:mysql /run/mysql/ ;

RUN \
    echo "=== Cleaning up ========================";  \
    /usr/local/sbin/docker-cleanup.sh ;
    
ENV LC_ALL=en_GB.UTF-8
ENV LANG=en_GB.UTF-8
ENV LANGUAGE=en_GB:en
ENV LC_MESSAGES=en_GB.UTF-8

COPY ./supervisord.conf          /etc/supervisor/
COPY ./sshd_config               /etc/ssh/
COPY ./my.cnf                    /etc/mysql/
COPY ./docker-entrypoint.sh      /usr/local/sbin/
COPY ./docker-mysql-start.sh     /usr/local/sbin/
COPY ./docker-mysql-poststart.sh /usr/local/sbin/
COPY ./docker-mysql-prestart.sh  /usr/local/etc/docker/prestart-init.d/
#COPY ./docker-mysql-prestart.sh  /usr/local/sbin/
COPY ./execstartpost-listener.py /usr/local/sbin/
COPY ./su-exec                   /usr/local/sbin/

EXPOSE 22 80 443 3306

VOLUME /var/lib/mysql
VOLUME /var/www

ENTRYPOINT ["/usr/local/sbin/docker-entrypoint.sh"]
CMD ["supervisor"]

