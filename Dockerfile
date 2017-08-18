# Creates docker container that runs dcm2niix
#
# Example usage:
#   docker run --rm -ti \
#       -v <someDirWithDicoms>:/flywheel/v0/input/dcm2niix \
#       -v <emptyOutputFolder>:/flywheel/v0/output \
#       scitran/dcm2niix <optional_flags>
#
#

# Start with neurodebian image
FROM neurodebian:trusty
MAINTAINER Michael Perry <lmperry@stanford.edu>

# Install packages
RUN apt-get update -qq \
    && apt-get install -y \
    git \
    curl \
    build-essential \
    cmake \
    pkg-config \
    libgdcm-tools=2.2.4-1.1ubuntu4 \
    bsdtar \
    unzip \
    pigz \
    gzip \
    wget \
    jq

# Compile DCM2NIIX from source
ENV DCMCOMMIT=efeddd8e06050599159e78dba43e33b3b58dce12
RUN curl -#L  https://github.com/rordenlab/dcm2niix/archive/$DCMCOMMIT.zip | bsdtar -xf- -C /usr/local
WORKDIR /usr/local/dcm2niix-${DCMCOMMIT}/build
RUN cmake -DUSE_OPENJPEG=ON ../ && \
    make && \
    make install

# Make directory for flywheel spec (v0)
ENV FLYWHEEL /flywheel/v0
WORKDIR ${FLYWHEEL}

# Add executables
COPY run ${FLYWHEEL}/run

# Add manifest
COPY manifest.json ${FLYWHEEL}/manifest.json

# Configure entrypoint
ENTRYPOINT ["/flywheel/v0/run"]
