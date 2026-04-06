FROM swift:6.3-noble AS build

RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && apt-get install -y libjemalloc-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

COPY ./Package.* ./
RUN swift package resolve

COPY . .

RUN swift build -c release --product crane --static-swift-stdlib -Xlinker -ljemalloc

WORKDIR /staging

RUN cp "$(swift build --package-path /build -c release --show-bin-path)/crane" ./

RUN cp "/usr/libexec/swift/linux/swift-backtrace-static" ./

FROM ubuntu:noble

RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && apt-get -q install -y libjemalloc2 \
    && rm -r /var/lib/apt/lists/*

RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /app crane

WORKDIR /app

COPY --from=build --chown=crane:crane /staging /app

ENV SWIFT_BACKTRACE=enable=yes,sanitize=yes,threads=all,images=all,interactive=no,swift-backtrace=./swift-backtrace-static

USER crane:crane

ENTRYPOINT [ "./crane" ]
CMD [ "--help" ]
