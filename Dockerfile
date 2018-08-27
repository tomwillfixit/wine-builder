FROM i386/ubuntu:artful as i386

COPY wine_patches /wine_patches

RUN sed -i 's/# deb-src/deb-src/' /etc/apt/sources.list && \
    apt-get update && \
    apt-get -y install tar git unzip dh-autoreconf flex bison curl

RUN mkdir /wine

WORKDIR /wine

# Get Wine Staging and Wine source code
RUN git clone -b v3.14 https://github.com/wine-staging/wine-staging.git && \
    git clone -b wine-3.14 https://github.com/wine-mirror/wine && \

# Apply Patches for 8.16

COPY wine_patches /wine_patches

RUN ./wine-staging/patches/patchinstall.sh DESTDIR=./wine --all -W ntdll-futex-condition-var && \
    cd wine && \
    patch -p1 < /wine_patches/0003-Pretend-to-have-a-wow64-dll.patch && \
    patch -p1 < /wine_patches/0010-New-Patch.patch


# Install Wine build dependencies
RUN apt-get -y build-dep wine && \
    apt-get install -y pulseaudio:i386 libcanberra-pulse:i386 

# Build Wine
RUN mkdir lol-3.14-32 && \
    cd lol-3.14-32 && \
    ../wine/configure && \
    make -j8 && \
    make DESTDIR=/tmp/wine -j8 install

