FROM alpine:3.15

ARG ZIG_VERSION=0.8.1
ARG ZIG_URL=https://ziglang.org/download/${ZIG_VERSION}/zig-linux-x86_64-${ZIG_VERSION}.tar.xz

RUN wget $ZIG_URL -O zig.tar.xz \
    && mkdir -p zig \
    && tar -Jxf zig.tar.xz -C zig --strip-components=1 \
    && rm zig.tar.xz

ENV PATH "/zig:${PATH}"

ENTRYPOINT ["/zig/zig"]