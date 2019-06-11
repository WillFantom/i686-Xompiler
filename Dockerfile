FROM ubuntu:xenial

#Deps
RUN apt-get update && apt-get install -y \
    autoconf \
    automake \
    autopoint \
    bash \
    bison \
    bzip2 \
    flex \
    gettext \
    git \
    g++ \
    gperf \
    intltool \
    libffi-dev \
    libgdk-pixbuf2.0-dev \
    libtool \
    libltdl-dev \
    libssl-dev \
    libxml-parser-perl \
    lzip \
    make \
    openssl \
    p7zip-full \
    patch \
    perl \
    pkg-config \
    python \
    ruby \
    scons \
    sed \
    unzip \
    wget \
    xz-utils \
    libtool-bin \
    texinfo \
    g++-multilib
RUN apt-get clean

#Versions
ENV BU_VERSION=2.28
ENV GCC_VERSION=7.1.0
ENV GDB_VERSION=8.0

#Make
ENV MAKE_ARGS="-j$(getconf _NPROCESSORS_ONLN)"

#Dirs
ENV BASE_DIR=/root
RUN mkdir -p ${BASE_DIR}

#MXE
RUN git clone https://github.com/mxe/mxe.git ${BASE_DIR}/mxe && \
    cd ${BASE_DIR}/mxe && \
    make gcc && \
    mv ./usr/bin ${BASE_DIR}/mxe-bin && \
    rm -rf ${BASE_DIR}/mxe && \
    export PATH=${BASE_DIR}/mxe-bin:$PATH

#Downloads
RUN cd ${BASE_DIR} && \
    wget http://ftp.gnu.org/gnu/binutils/binutils-${BU_VERSION}.tar.gz && \
    tar -xf binutils-${BU_VERSION}.tar.gz
RUN cd ${BASE_DIR} && \
    wget http://ftp.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.gz && \
    tar -xf gcc-${GCC_VERSION}.tar.gz
RUN cd ${BASE_DIR}/gcc-${GCC_VERSION} && \
    ./contrib/download_prerequisites
RUN cd ${BASE_DIR} && \
    wget http://ftp.gnu.org/gnu/gdb/gdb-${GDB_VERSION}.tar.gz && \
    tar -xf gdb-${GDB_VERSION}.tar.gz
RUN cd ${BASE_DIR} && rm -rf *.tar.gz

#Build
RUN cd ${BASE_DIR}
RUN mkdir -p ${BASE_DIR}/out
RUN export PATH=${BASE_DIR}/out/bin:$PATH

#Build Binutils
RUN mkdir -p ${BASE_DIR}/binutils-build && cd ${BASE_DIR}/binutils-build
RUN ${BASE_DIR}/binutils-${BU_VERSION}/configure --target=i686-elf --with-sysroot --disable-nls --disable-werror --prefix=${BASE_DIR}/out
RUN make ${MAKE_ARGS}
RUN make ${MAKE_ARGS} install

#Build GCC
RUN mkdir -p ${BASE_DIR}/gcc-build && cd ${BASE_DIR}/gcc-build
RUN ${BASE_DIR}/gcc-${GCC_VERSION}/configure --target=i686-elf --disable-nls --enable-languages=c,c++ --without-headers --prefix=${BASE_DIR}/out
RUN make ${MAKE_ARGS} all-gcc
RUN make ${MAKE_ARGS} install-gcc
RUN make ${MAKE_ARGS} all-target-libgc
RUN make ${MAKE_ARGS} install-target-libgcc

#Build GDB
RUN mkdir -p ${BASE_DIR}/gdb-build && cd ${BASE_DIR}/gdb-build
RUN ${BASE_DIR}/gdb-${GDB_VERSION}/configure --target=i686-elf --disable-nls --disable-werror --prefix=${BASE_DIR}/out
RUN make ${MAKE_ARGS}
RUN make ${MAKE_ARGS} install
