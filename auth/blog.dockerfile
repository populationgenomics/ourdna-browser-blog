FROM golang:alpine AS builder
RUN apk --update --no-cache add git fuse fuse-dev;
RUN go install github.com/googlecloudplatform/gcsfuse/v2@master

FROM nginx:alpine

COPY "auth/blog.nginx.conf" /etc/nginx/blog.conf.template

RUN apk add --no-cache ca-certificates fuse

COPY --from=builder /go/bin/gcsfuse /usr/local/bin

# Bucket files will be mounted here
RUN mkdir -p /usr/share/nginx/news

CMD REAL_IP_CONFIG=$([ -z "${PROXY_IPS:-}" ] || echo "$PROXY_IPS" | awk 'BEGIN { RS="," } { print "set_real_ip_from " $1 ";" }') \
  envsubst "\$REAL_IP_CONFIG" < /etc/nginx/blog.conf.template > /etc/nginx/conf.d/default.conf && \
  nginx -g "daemon off;"
