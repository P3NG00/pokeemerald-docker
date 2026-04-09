FROM docker.io/gcc:latest

# Commit Hashes
ARG POKEEMERALD_COMMIT_HASH="962442a51e25cb8d5c1c11460d42e0b3325059b4"
ARG AGBCC_COMMIT_HASH="da598c1d918402c42c0c0d7128ba14567f3175e9"

# Update, Install, and Clean Packages
# gcc-arm-none-eabi and libnewlib-arm-none-eabi are necessary for using modern compiler
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        binutils-arm-none-eabi \
        gcc-arm-none-eabi \
        git \
        libnewlib-arm-none-eabi \
        libpng-dev \
    && rm -rf /var/lib/apt/lists/*

# Clone PokeEmerald Repo
RUN git clone --no-checkout https://github.com/pret/pokeemerald \
    && cd /pokeemerald \
    && git checkout ${POKEEMERALD_COMMIT_HASH}

# Setup agbcc compiler
RUN git clone --no-checkout https://github.com/pret/agbcc \
    && cd /agbcc \
    && git checkout ${AGBCC_COMMIT_HASH} \
    && ./build.sh \
    && ./install.sh ../pokeemerald

# Setup workspace
WORKDIR /pokeemerald
# Setup BUGFIX building
ARG BUILD_BUGFIX=false
RUN if [ "$BUILD_BUGFIX" = "true" ]; then \
        sed -i "s|^//#define BUGFIX|#define BUGFIX|" include/config.h; \
    fi

# Build command
ENTRYPOINT make -j$(nproc) ${MAKE_ARGS}
