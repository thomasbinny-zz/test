FROM alpine:3.8

RUN addgroup www
RUN adduser -D -g 'www' nginx

RUN apk update && apk add nginx

RUN mkdir -p /run/nginx

RUN mkdir /www && \
    chown -R nginx:www /var/lib/nginx && \
    chown -R nginx:www /www&& \
    chown -R nginx:www /run/nginx

COPY nginx/default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

ENTRYPOINT nginx -g 'daemon off;'
