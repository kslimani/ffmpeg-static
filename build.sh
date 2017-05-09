#!/bin/bash

__FILE__=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)/`basename "${BASH_SOURCE[0]}"`
__DIR__=$(dirname "${__FILE__}")
PRJ_DIR=$__DIR__ && . $__DIR__/scripts/common.inc

install_dependencies()
{
  info "Install dependencies ..."
  run apt-get update
  run apt-get -y install autoconf automake build-essential libass-dev libfreetype6-dev \
    libsdl1.2-dev libtheora-dev libtool libva-dev libvdpau-dev libvorbis-dev libxcb1-dev libxcb-shm0-dev \
    libxcb-xfixes0-dev pkg-config texinfo zlib1g-dev cmake mercurial libnuma-dev
  info "Install dependencies complete"
}

run_script()
{
  if ! $__DIR__/scripts/$*; then
    exit 1
  fi
}

duccic()
{
  ACTIONS="download unpack configure compile install clean"
  for ACTION in $ACTIONS; do
    run_script $1 $ACTION
  done
}

all()
{
  log_to_file $BUILD_LOG_FILENAME
  install_dependencies

  # Build order matters
  LIB_SCRIPTS="yasm libx264 libx265 libfdk-aac libmp3lame libopus libvpx ffmpeg"
  for LIB_SCRIPT in $LIB_SCRIPTS; do
    duccic $LIB_SCRIPT
  done

  run_script chbuild $BUILD_VERSION
}

usage()
{
  SCRIPT_NAME=$(basename "$__FILE__")
  printf "Usage: $SCRIPT_NAME <OPTION> \n\n"
  printf "OPTIONS :\n"
  printf "   all      download, compile and install all libraries\n"
  printf "   setup    install dependencies\n"
  printf "   yasm     download, compile and install yasm\n"
  printf "   x264     download, compile and install libx264\n"
  printf "   x265     download, compile and install libx265\n"
  printf "   aac      download, compile and install libfdk-aac\n"
  printf "   mp3      download, compile and install libmp3lame\n"
  printf "   opus     download, compile and install libopus\n"
  printf "   vpx      download, compile and install libvpx\n"
  printf "   ffmpeg   download, compile and install FFmpeg\n"
  exit 3
}

case "$1" in
  all)
    all
  ;;
  setup)
    install_dependencies
  ;;
  yasm)
    duccic yasm
  ;;
  x264)
    duccic libx264
  ;;
  x265)
    duccic libx265
  ;;
  aac)
    duccic libfdk-aac
  ;;
  mp3)
    duccic libmp3lame
  ;;
  opus)
    duccic libopus
  ;;
  vpx)
    duccic libvpx
  ;;
  ffmpeg)
    duccic ffmpeg
  ;;
  *)
    usage
  ;;
esac
