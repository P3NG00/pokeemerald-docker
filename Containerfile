FROM docker.io/gcc:latest

# Commit Hashes
# Declared as separate ARG lines, not one combined "ARG A= B= C=" line: podman/buildah's
# "build args were not consumed" check has a bug where it only ever credits the first variable
# in a combined ARG line as used, and always (falsely) flags the rest even when they are
# genuinely referenced below.
ARG POKEEMERALD_COMMIT_HASH=
ARG AGBCC_COMMIT_HASH=
ARG BUILD_BUGFIX=false

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

# Setup agbcc compiler
# Built before pokeemerald is cloned (and installed as a separate step below) so this expensive
# compile only re-runs when AGBCC_COMMIT_HASH actually changes, instead of on every build where
# pokeemerald's much-more-frequently-updated commit would otherwise force it to rebuild too
# (Docker/Podman cache invalidation cascades to every following layer, regardless of whether
# that layer's command references the value that changed).
RUN git clone --no-checkout https://github.com/pret/agbcc \
    && cd /agbcc \
    && git checkout ${AGBCC_COMMIT_HASH:-$(git rev-parse HEAD)} \
    && ./build.sh

# Clone PokeEmerald Repo
RUN git clone --no-checkout https://github.com/pret/pokeemerald \
    && cd /pokeemerald \
    && git checkout ${POKEEMERALD_COMMIT_HASH:-$(git rev-parse HEAD)}

# Install the compiled agbcc into the pokeemerald tree. Cheap, so it's fine for this step to
# re-run whenever either commit changes.
RUN cd /agbcc && ./install.sh ../pokeemerald

# Setup workspace
WORKDIR /pokeemerald
# Setup BUGFIX building
RUN if [ "$BUILD_BUGFIX" = "true" ]; then \
        sed -i "s|^//#define BUGFIX|#define BUGFIX|" include/config.h; \
    fi

# Build command
ENTRYPOINT make -j$(nproc) ${MAKE_ARGS}
