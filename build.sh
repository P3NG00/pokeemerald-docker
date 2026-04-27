#!/bin/bash

# Help function
print_help() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  --help      Display options and exit."
    echo "  --bugfix    Build with BUGFIX preprocessor directive. Implements fixes for bugs defined in the code."
    echo "  --modern    Build using MODERN compiler instead of agbcc."
    exit 1
}

# Parse command-line arguments
BUILD_BUGFIX=false
BUILD_MODERN=false
for arg in "$@"; do
    case "$arg" in
        "--help")
            print_help
            ;;
        "--bugfix")
            BUILD_BUGFIX=true
            ;;
        "--modern")
            BUILD_MODERN=true
            ;;
        *)
            echo "Error: Unknown option '$arg'."
            print_help
            ;;
    esac
done

# IMAGE_TAG tracks the 4 unique build types to avoid overwriting images/containers.
# BUILD_NAME tracks the 2 internal compiler outputs (modern vs. agbcc) so 'podman cp' works.
IMAGE_TAG="pokeemerald"
BUILD_NAME="pokeemerald"
MAKE_ARGS=
# Check BUGFIX build
if [ "$BUILD_BUGFIX" = "true" ]; then
    IMAGE_TAG+="_bugfix"
fi
# Check MODERN build
if [ "$BUILD_MODERN" = "true" ]; then
    IMAGE_TAG+="_modern"
    BUILD_NAME+="_modern"
    MAKE_ARGS="modern"
fi

# Build the image
podman build \
    --build-arg BUILD_BUGFIX=${BUILD_BUGFIX} \
    --env MAKE_ARGS=${MAKE_ARGS} \
    --tag $IMAGE_TAG \
    .

# Run the image
podman run \
    --name $IMAGE_TAG \
    --replace \
    $IMAGE_TAG

# Create Output Directory
mkdir -p ./output/

# Copy built file to output directory
podman cp $IMAGE_TAG:/pokeemerald/${BUILD_NAME}.gba ./output/${IMAGE_TAG}.gba
