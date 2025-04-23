FROM golang:1.10.0-alpine AS gcsfuse

RUN apk add --no-cache git
ENV GOPATH /go
RUN go get -u github.com/googlecloudplatform/gcsfuse

FROM nginx:alpine

ARG ENVIRONMENT=production

RUN apk add --no-cache ca-certificates fuse

COPY --from=gcsfuse /go/bin/gcsfuse /usr/local/bin

COPY "auth/blog.$ENVIRONMENT.nginx.conf" /etc/nginx/blog.conf.template

# Bucket files will be mounted here
RUN mkdir -p /usr/share/nginx/news

# Or any other port you use in nginx.cong
# EXPOSE 80

# CMD ["nginx", "-g", "daemon off;"]

CMD REAL_IP_CONFIG=$([ -z "${PROXY_IPS:-}" ] || echo "$PROXY_IPS" | awk 'BEGIN { RS="," } { print "set_real_ip_from " $1 ";" }') \
  envsubst "\$REAL_IP_CONFIG" < /etc/nginx/blog.conf.template > /etc/nginx/conf.d/default.conf && \
  nginx -g "daemon off;"
