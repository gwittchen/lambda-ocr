FROM lambci/lambda:build-python3.6

# define env
ENV LEPTONICA_VERSION=leptonica-1.76.0
ENV TESSERACT_VERSION=4.0.0
ENV PYTHON_VERSION=3.6.1

# tesseract data parameters
ARG TESSERACT_LANG
ARG TESSERACT_MODE

## install dependencies
RUN yum -y clean expire-cache && yum -y makecache fast && yum -y update && yum -y install tar xz gcc gcc-c++ make autoconf aclocal automake libtool findutils \
libjpeg-devel libpng-devel libtiff-devel zlib-devel \
libzip-devel freetype-devel lcms2-devel libwebp-devel \
tcl-devel tk-devel wget tar diffutils autoconf automake \
libjpeg8-devel libtiff5-devel zlib1g-devel zip

## build python
RUN curl -O https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.xz
RUN tar xf Python-${PYTHON_VERSION}.tar.xz
RUN mkdir -p /var/task/python
WORKDIR Python-${PYTHON_VERSION}
RUN ./configure --prefix=/var/task/python
RUN make -j9 && make altinstall

## build leptonica
RUN mkdir -p "/tmp/${LEPTONICA_VERSION}-build"
WORKDIR "/tmp/${LEPTONICA_VERSION}-build"
RUN curl -L -o "${LEPTONICA_VERSION}.tar.gz" "http://www.leptonica.org/source/${LEPTONICA_VERSION}.tar.gz" \
&& tar -zxvf ${LEPTONICA_VERSION}.tar.gz \
&& cd ${LEPTONICA_VERSION} && ./configure && make && make install

# build tesseract
RUN mkdir -p "/tmp/tesseract-${TESSERACT_VERSION}-build"
WORKDIR "/tmp/${TESSERACT_VERSION}-build"
RUN wget https://github.com/tesseract-ocr/tesseract/archive/${TESSERACT_VERSION}.tar.gz && tar -zxvf ${TESSERACT_VERSION}.tar.gz \
&& cd tesseract-${TESSERACT_VERSION} && ./autogen.sh && \
LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/lib" \
LIBLEPT_HEADERSDIR="/usr/local/include/leptonica" \
PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/usr/local/lib/pkgconfig" ./configure \
&& LDFLAGS="-L/usr/local/lib" CFLAGS="-I/usr/local/include" make && make install

RUN pip install \
  --target=/var/task/python \
  --global-option=build_ext --global-option="-L/var/lang/lib:/var/task/lib" \
  --global-option=build_ext --global-option="-I/var/lang/include/python3.6m:/var/task/lib" \ tesserocr==2.3.1

RUN pip install \
  --target=/var/task/python/ pytesseract==0.2.5
RUN pip install \
  --target=/var/task/python/ --upgrade cython==0.29.1
RUN pip install \
  --target=/var/task/python/ --upgrade pillow==5.4.0

RUN mkdir -p /var/task/tessdata
RUN for lang in $TESSERACT_LANG; do wget https://github.com/tesseract-ocr/tessdata_${TESSERACT_MODE}/raw/master/$lang.traineddata -P /var/task/tessdata; done

RUN rm -rf /var/task/Python-3.6.1*
RUN ls /var/task/python/bin
