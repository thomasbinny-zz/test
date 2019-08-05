FROM alpine:3.8

ARG PROJECT_NAME

RUN addgroup www
RUN adduser -D -g 'www' nginx

RUN apk update && apk add nginx curl



RUN mkdir /www && mkdir /www/${PROJECT_NAME} && \
	mkdir /run/nginx && \
    chown -R nginx:www /var/lib/nginx && \
    chown -R nginx:www /www/${PROJECT_NAME} && \
    chown -R nginx:www /run/nginx

RUN rm -rf /etc/nginx/conf.d/default.conf

COPY www/* /www/${PROJECT_NAME}/

COPY nginx/default1.conf /etc/nginx/conf.d/${PROJECT_NAME}.conf

EXPOSE 80

ENTRYPOINT nginx -g 'daemon off;'
