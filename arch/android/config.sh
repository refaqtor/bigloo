source config-local.sh

if ! [ -d "$ANDROIDROOT" -a -d "$BS_BIGLOO" ]; then
   echo "config seems wrong. check config file $conf_file"
   exit 1
fi

export ANDSRC=$ANDROIDROOT/eclair-git
export ANDSDK=$ANDROIDROOT/android-sdk-linux

# droid-wrapper
# http://github.com/tmurakam/droid-wrapper/
export DROID_ROOT=$ANDSRC
# 3 for cupcake
# 5 for eclair
export DROID_TARGET=5

# gcc
export CC=$ANDROIDROOT/droid-wrapper/bin/droid-gcc

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BS_BIGLOO/lib
