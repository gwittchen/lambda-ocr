FROM amazonlinux:1

##
ARG leptonica_version=leptonica-1.76.0
ARG tesseract_version=4.0.0
ARG lambda_name=lambda_tesseract
RUN yum -y install gcc gcc-c++ make autoconf aclocal automake libtool findutils \
libjpeg-devel libpng-devel libtiff-devel zlib-devel \
libzip-devel freetype-devel lcms2-devel libwebp-devel \
tcl-devel tk-devel wget tar diffutils autoconf automake \
libjpeg8-devel libtiff5-devel zlib1g-devel \
epel-release python36 python36-devel libicu-devel zip
RUN /usr/bin/pip-3.6 install --upgrade pip && pip3 --version && ln -s /usr/bin/pip3 /usr/bin/pip

## install leptonica
RUN mkdir leptonica && cd leptonica && wget http://www.leptonica.org/source/$leptonica_version.tar.gz \
&& tar -zxvf $leptonica_version.tar.gz \
&& cd $leptonica_version && ./configure && make && make install


RUN mkdir tesseract && cd tesseract && wget https://github.com/tesseract-ocr/tesseract/archive/$tesseract_version.tar.gz && tar -zxvf $tesseract_version.tar.gz \
&& cd tesseract-$tesseract_version && ./autogen.sh && \
LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/lib" \
LIBLEPT_HEADERSDIR="/usr/local/include/leptonica" \
PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/usr/local/lib/pkgconfig" ./configure \ 
&& LDFLAGS="-L/usr/local/lib" CFLAGS="-I/usr/local/include" make && make install

ADD build_lambda_env.sh /build_lambda_env.sh
RUN /bin/bash /build_lambda_env.sh $lambda_name
COPY ./src /src
ADD docker-entrypoint.sh /docker-entrypoint.sh

#ENTRYPOINT ["./docker-entrypoint.sh"]
#CMD ["output"]
