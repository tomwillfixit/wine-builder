#!/bin/bash

set -e
timestamp=$(date +"%T")

echo "Prebuild cleanup"

    docker rm -f wine_builder ||true

echo "Build Patched version of Wine inside Docker Container"

    docker build -t patched_wine:latest -f Dockerfile .

echo "Wine exists inside the patched_wine:latest container image under the /tmp/wine directory"

    docker run -it --name wine_builder patched_wine:latest /bin/true

if [ -d `pwd`/wine ];then
    echo "Wine directory already exists in `pwd`"
    echo "Moving wine to wine_${timestamp}" 
    mv wine wine_${timestamp}
fi

echo "Copy Wine from wine_builder container to `pwd`/wine"

    docker cp wine_builder:/tmp/wine .


