FROM ubuntu:20.04 as builder

ENV THRIFT_VERSION v0.15.0

RUN buildDeps=" \
		automake \
		bison \
		curl \
		flex \
		g++ \
		libboost-dev \
		libboost-filesystem-dev \
		libboost-program-options-dev \
		libboost-system-dev \
		libboost-test-dev \
		libevent-dev \
		libssl-dev \
		libtool \
		make \
		pkg-config \
	"; \
	apt-get update && apt-get install -y --no-install-recommends $buildDeps

RUN curl -k -sSL "https://github.com/apache/thrift/archive/${THRIFT_VERSION}.tar.gz" -o thrift.tar.gz \
	&& mkdir -p /usr/src/thrift \
	&& tar zxf thrift.tar.gz -C /usr/src/thrift --strip-components=1

WORKDIR /usr/src/thrift
RUN ./bootstrap.sh \
	&& ./configure --disable-libs \
	&& make \
	&& make install

FROM gcr.io/distroless/base

WORKDIR /usr/local/bin

COPY --from=builder /usr/local/bin/thrift /usr/local/bin/thrift
COPY --from=builder /usr/lib/*-linux-gnu/libstdc++.so* /usr/lib
COPY --from=builder /usr/lib/*-linux-gnu/libgcc_s.so* /usr/lib

ENTRYPOINT [ "thrift" ]
