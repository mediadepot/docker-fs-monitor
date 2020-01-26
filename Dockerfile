FROM alpine

RUN apk add --no-cache bash python3 curl git smartmontools

# install mergerfs-tools
RUN curl -L https://github.com/trapexit/mergerfs-tools/archive/master.tar.gz -o /tmp/mergerfs-tools.tar.gz && \
    tar xvf /tmp/mergerfs-tools.tar.gz mergerfs-tools-master/src/ -C /usr/local/bin --strip-components=2 && \
    chmod +x /usr/local/bin/mergerfs.* && \
    rm -rf /tmp/mergerfs-tools.tar.gz

# install scorch
RUN curl -L https://github.com/trapexit/scorch/archive/master.tar.gz -o /tmp/scorch.tar.gz && \
    tar xvf /tmp/scorch.tar.gz scorch-master/scorch -C /usr/local/bin --strip-components=1 && \
    chmod +x /usr/local/bin/scorch && \
    rm -rf /tmp/scorch.tar.gz && \
    scorch --help

# install s6overlay - we're going to run multiple services within this container
ADD https://github.com/just-containers/s6-overlay/releases/download/v1.21.8.0/s6-overlay-amd64.tar.gz /tmp/
RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C /

COPY /rootfs /

CMD ["/init"]
