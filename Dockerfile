FROM nginx

MAINTAINER Germain GAU <germain.gau@c-s.fr>

RUN rm -rf /usr/share/nginx/html

ADD container_init.sh /
ADD src /usr/share/nginx/html


CMD ["bash", "/container_init.sh"]
