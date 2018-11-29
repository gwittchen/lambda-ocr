#!/bin/bash
set -e

if [[ -z $1 ]]; then
  OUTPUT_DIRECTORY="output"
else
  OUTPUT_DIRECTORY=$1
fi

if [[ -z $2 ]]; then
  INPUT_DIRECTORY="lambda-tesseract"
else
  INPUT_DIRECTORY=$2
fi
echo "Output: $OUTPUT_DIRECTORY"
echo "Input: $INPUT_DIRECTORY"

VIRTUAL_ENV=/tfenv
# create a python virtual env
pip install virtualenv
virtualenv -p python3 $VIRTUAL_ENV
source $VIRTUAL_ENV/bin/activate

# Install lambda requiements
CPPFLAGS=-I/usr/local/include pip install -r /src/requirements.txt

echo "zip lambda archive"
if ! [[ -d /$OUTPUT_DIRECTORY ]] ; then 
  mkdir -p /$OUTPUT_DIRECTORY 
fi

echo "Copy python"
#copy python env
cp -r $VIRTUAL_ENV/lib/python3.6/site-packages/* $INPUT_DIRECTORY
cp -r $VIRTUAL_ENV/lib64/python3.6/site-packages/* $INPUT_DIRECTORY

echo "Copy source from /src"
cd /src
cp -a /src/. /$INPUT_DIRECTORY/

#cleanup artefacts
if [ -f /$OUTPUT_DIRECTORY/$INPUT_DIRECTORY.zip ]; then
    echo "Cleanup output!"
    rm -rf /$OUTPUT_DIRECTORY/$INPUT_DIRECTORY.zip
fi

#package lambda and binaries
cd /$INPUT_DIRECTORY
ls /$INPUT_DIRECTORY/lambda_function.py
zip -r /$OUTPUT_DIRECTORY/$INPUT_DIRECTORY.zip ./* --exclude *.pyc