FROM i386/ubuntu:artful as i386

COPY wine_patches /wine_patches

RUN sed -i 's/# deb-src/deb-src/' /etc/apt/sources.list && \
    apt-get update && \
    apt-get -y install tar git unzip dh-autoreconf flex bison curl

RUN mkdir /wine

WORKDIR /wine

# Get Wine Staging and Wine source code
RUN git clone -b v3.13.1 https://github.com/wine-staging/wine-staging.git && \
    git clone https://github.com/wine-mirror/wine && \
    cd wine && \
    git checkout 25cc380b8ed41652b135657ef7651beef2f20ae4

# Apply Patches for 8.16

COPY wine_patches /wine_patches

RUN ./wine-staging/patches/patchinstall.sh DESTDIR=./wine --all -W ntdll-futex-condition-var && \
    cd wine && \
    patch -p1 < /wine_patches/0003-Pretend-to-have-a-wow64-dll.patch && \
    patch -p1 < /wine_patches/0006-Refactor-LdrInitializeThunk.patch && \
    patch -p1 < /wine_patches/0007-Refactor-RtlCreateUserThread-into-NtCreateThreadEx.patch && \
    patch -p1 < /wine_patches/0009-Refactor-__wine_syscall_dispatcher-for-i386.patch && \
    patch -p1 < /wine_patches/0010-New-Patch.patch


# Install Wine build dependencies
RUN apt-get -y build-dep wine && \
    apt-get install -y pulseaudio:i386 libcanberra-pulse:i386 

# Build Wine
RUN mkdir lol-3.13.1-32 && \
    cd lol-3.13.1-32 && \
    ../wine/configure && \
    make -j8 && \
    make DESTDIR=/tmp/wine -j8 install

