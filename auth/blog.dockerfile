FROM golang:alpine AS builder
ARG GCSFUSE_VERSION=0.27.0
ENV GO111MODULE=off
RUN apk --update --no-cache add git fuse fuse-dev;
RUN go get -d github.com/googlecloudplatform/gcsfuse
RUN go install github.com/googlecloudplatform/gcsfuse/tools/build_gcsfuse
RUN build_gcsfuse ${GOPATH}/src/github.com/googlecloudplatform/gcsfuse /tmp ${GCSFUSE_VERSION}



FROM nginx:alpine

ARG ENVIRONMENT=production

COPY "auth/blog.$ENVIRONMENT.nginx.conf" /etc/nginx/blog.conf.template

RUN apk add --no-cache ca-certificates fuse

# COPY --from=builder /go/bin/gcsfuse /usr/local/bin

COPY --from=builder /tmp/bin/gcsfuse /usr/bin
COPY --from=builder /tmp/sbin/mount.gcsfuse /usr/sbin
RUN ln -s /usr/sbin/mount.gcsfuse /usr/sbin/mount.fuse.gcsfuse


# Bucket files will be mounted here
RUN mkdir -p /usr/share/nginx/news

# Or any other port you use in nginx.cong
# EXPOSE 80

# CMD ["nginx", "-g", "daemon off;"]

CMD REAL_IP_CONFIG=$([ -z "${PROXY_IPS:-}" ] || echo "$PROXY_IPS" | awk 'BEGIN { RS="," } { print "set_real_ip_from " $1 ";" }') \
  envsubst "\$REAL_IP_CONFIG" < /etc/nginx/blog.conf.template > /etc/nginx/conf.d/default.conf && \
  nginx -g "daemon off;"
