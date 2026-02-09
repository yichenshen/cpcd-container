# Silabs components are readily packaged for debian and requires bookworm deps
FROM debian:bookworm-slim

# Setup installation and DOCKER env
ARG DEBIAN_FRONTEND=noninteractive
ENV DOCKER=1

# Update packages
RUN apt-get update

# Dependencies for setup
RUN apt-get install -y \
    lsb-release \
    wget \
    unzip \
    make

# Download Silabs packages
WORKDIR /tmp/silabs
RUN wget https://github.com/SiliconLabsSoftware/sisdk-release/releases/download/v2025.12.0/debian-bookworm.zip
RUN unzip debian-bookworm.zip -d multiprotocol-packages

# Install cpcd
RUN ARCH=$(dpkg --print-architecture) && \
    echo "Detected architecture: $ARCH" && \
    apt-get install -y \
    ./multiprotocol-packages/debian-bookworm/deb/libcpc3_*_${ARCH}.deb \
    ./multiprotocol-packages/debian-bookworm/deb/cpcd_*_${ARCH}.deb

# CPCd configuration
COPY --chmod=666 ./cpcd.conf /etc/cpcd.conf

# Start from root homedir
WORKDIR /cpcd
RUN chmod 777 /cpcd

# Copy the startup script
COPY --chmod=755 ./start.sh /cpcd/start.sh

# Cleanup
RUN apt-get remove -y \
    lsb-release \
    wget \
    unzip \
    make
RUN apt-get autoremove -y
RUN rm -rf /var/lib/apt/lists/*
RUN rm -rf /tmp/silabs

CMD ["/cpcd/start.sh"]
