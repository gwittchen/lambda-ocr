#!/bin/bash

if [[ -n $1 ]]; then
  echo "no lambda name provided use default name lambda-tesseract"
  LAMBDA_DIR=lambda-tesseract
else
  LAMBDA_DIR=$1
fi
echo $LAMBDA_DIR

# prepare the zip package
LAMBDA_LIB_DIR=$LAMBDA_DIR/lib

cd / && mkdir -p $LAMBDA_DIR $LAMBDA_LIB_DIR

# copy tesseract binary
cp /usr/local/bin/tesseract $LAMBDA_DIR


libarray=(/usr/local/lib/libtesseract.so* \
/usr/local/lib/liblept.so* \
/usr/lib64/librt.so \
/usr/lib64/libz.so \
/usr/lib64/libpng12* \
/usr/lib64/libjpeg.so* \
/usr/lib64/libtiff.so* \
/usr/lib64/libpthread.so* \
/usr/lib64/libstdc++.so* \
/usr/lib64/libm.so* \
/usr/lib64/libjbig.so.2.0 \
/usr/lib64/libwebp.so.4)

#/usr/lib64/libgcc_s.so* \
#/usr/lib64/libc.so* \
#/usr/lib64/ld-linux-x86-64.so* \

for lib in "${libarray[@]}"
do
	cp $lib $LAMBDA_LIB_DIR
done

#add tessdata for ocr
mkdir $LAMBDA_DIR/tessdata
wget https://github.com/tesseract-ocr/tessdata_best/raw/master/eng.traineddata -P $LAMBDA_DIR/tessdata

# optional Orientation and script detection
#wget https://github.com/tesseract-ocr/tessdata/raw/3.04.00/osd.traineddata -P $LAMBDA_DIR/tessdata

# optional Math / equation detection
#wget https://github.com/tesseract-ocr/tessdata/raw/3.04.00/equ.traineddata -P $LAMBDA_DIR/tessdata
