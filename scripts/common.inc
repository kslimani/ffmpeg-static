#
# This file is included by all scripts
#
DEFAULT_BIN_SYMLINK_PATH=/usr/local/bin

__DATE__=$(date +%Y%m%d)
__LOG__=0

if [ -z "$PRJ_DIR" ]; then
  PRJ_DIR=$(cd $__DIR__/.. && pwd)
fi

BUILD_DIR=$PRJ_DIR/build/$__DATE__
BUILD_LINK=$PRJ_DIR/build/current
SRC_DIR=$BUILD_DIR/src
LOG_DIR=$BUILD_DIR/log
BIN_DIR=$BUILD_DIR/bin
BIN_LINK_PATH=$BUILD_LINK/bin

BUILD_LOG_FILENAME=build.log

PATH="$BIN_DIR:$PATH"

# echo "PATH=\"$BIN_LINK_PATH:$$PATH\"" > ~/.profile

if [ "$(tput colors)" -ge "8" ]; then
  C_ERROR='\E[31;40m'
  C_INFO='\E[32;40m'
  C_NONE='\E[0m'
  C_RUN='\E[35;40m'
fi

log_to_file()
{
  # Ensure function is run only once
  if [ "$__LOG__" -eq "1" ]; then
    return 0
  fi

  if [ ! -d "$LOG_DIR" ]; then
    run mkdir -p $LOG_DIR
  fi

  # Simple log rotate
  if [ -f "$LOG_DIR/$1" ]; then
    run mv $LOG_DIR/$1 $LOG_DIR/$1.$(date +%s)
  fi

  # Redirect all output to a tee child process
  exec > >(tee -a $LOG_DIR/$1) 2>&1
  __LOG__=1
}

cd_src()
{
  if [ ! -d "$SRC_DIR" ]; then
    run mkdir -p $SRC_DIR
  fi
  run cd $SRC_DIR/$*
}

date_time()
{
  date +%Y-%m-%d" "%H:%M:%S
}

info()
{
  printf "${C_INFO}$(date_time) [NOTICE] $*${C_NONE}\n"
}

error()
{
  printf "${C_ERROR}$(date_time) [ERROR] $*${C_NONE}\n"
  exit 1
}

run()
{
  if ! $*; then
    error "Failed to run: $*"
  fi
}

usage()
{
  SCRIPT_NAME=$(basename "$__FILE__")
  printf "Usage: $SCRIPT_NAME <download|unpack|configure|compile|install|clean> \n\n"
  exit 3
}

main()
{
  case "$1" in
    download)
      do_download
    ;;
    unpack)
      do_unpack
    ;;
    configure)
      do_configure
    ;;
    compile)
      do_compile
    ;;
    install)
      do_install
    ;;
    clean)
      do_clean
    ;;
    *)
      usage
    ;;
  esac
}
