FROM ubuntu:20.04 AS buildimg
RUN apt-get update && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y \
    cmake \
    g++ \
    libsnmp-dev \
&& rm -rf /var/lib/apt/lists/*

WORKDIR /src
COPY . /src
RUN mkdir docker-build \
    && cd docker-build \
    && cmake .. \
    && make

FROM ubuntu:20.04 AS runimg
LABEL license="AGPLv3" \
      vendor="The OpenNMS Group, Inc." \
      name="udpgen"
RUN apt-get update && apt-get install -y \
    iputils-ping \
    libsnmp35 \
    net-tools \
    tcpdump \
&& rm -rf /var/lib/apt/lists/*
COPY --from=buildimg /src/docker-build/udpgen udpgen
CMD ["/udpgen", "-i", "-r", "1",  "-t", "1", "-h", "127.0.0.1", "-p", "514"]
