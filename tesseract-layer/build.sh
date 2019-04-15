#!/bin/bash -x

showHelp() {
# `cat << EOF` This means that cat should stop reading when EOF is detected
cat << EOF  
Usage: ./build -vnc [-hvnc]

-h,             Display help

-c,             clean rebuild docker container using no-cache

EOF
# EOF is found above and hence cat command stops reading. This is equivalent to echo but much neater when printing out.
}



export DOCKER_ARG=""
while getopts ":hc" opt; do
  case ${opt} in
    h ) showHelp
		exit 0
      ;;
    c ) export DOCKER_ARG="--no-cache"
      ;;
    \? ) showHelp
      ;;
  esac
done
set -e

echo "$DOCKER_ARG"

# define required libs

libarray=(/usr/local/lib/libtesseract.so.4 \
/usr/local/lib/liblept.so.5 \
/usr/lib64/librt.so \
/usr/lib64/libz.so \
/usr/lib64/libm.so \
/usr/lib64/libpng12.so.0 \
/usr/lib64/libjpeg.so.62 \
/usr/lib64/libtiff.so.5 \
/usr/lib64/libpthread.so \
/usr/lib64/libstdc++.so.6 \
/usr/lib64/libjbig.so.2.0 \
/usr/lib64/libwebp.so.4)

pythondeps=(tesserocr.cpython-36m-x86_64-linux-gnu.so \
pytesseract-0.2.5.dist-info \
pytesseract \
Pillow-5.4.0.dist-info \
PIL \
Cython \
Cython-0.29.1.dist-info \
cython.py \
pyximport)

binaries=(/var/task/python/bin/cythonize \
/var/task/python/bin/cython \
/var/task/python/bin/cygdb )


LAMBDA_DIR=layer

rm -rf layer
mkdir -p layer/python/bin
mkdir -p layer/{lib,bin,data}
docker build $DOCKER_ARG -t tessleract-builder -f Dockerfile .
CONTAINER=$(docker run -d tessleract-builder false)

# copy libs
for lib in "${libarray[@]}"
do
    docker cp -L \
    $CONTAINER:$lib $LAMBDA_DIR/lib
done

# copy python dependencies
for dep in "${pythondeps[@]}"
do
    docker cp \
    $CONTAINER:/var/task/python/$dep $LAMBDA_DIR/python/.
done


# copy python binaries
for bin in "${binaries[@]}"
do
    docker cp -a \
    $CONTAINER:$bin $LAMBDA_DIR/python/bin
done


docker cp \
    $CONTAINER:/var/task/tessdata $LAMBDA_DIR/data/tessdata

docker cp \
    $CONTAINER:/usr/local/bin/tesseract $LAMBDA_DIR/bin/
    
docker rm $CONTAINER
