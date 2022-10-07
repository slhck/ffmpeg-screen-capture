#!/usr/bin/env bash
#
# Record the screen via x11grab and embed a timecode.
#
# Author: Werner Robitza
#
# License: MIT
#
# Version: 1.3.1
#
# History of changes:
#
# - 1.3.1: Exec the command to allow stdin redirection
# - 1.3.0: Output progress
# - 1.2.1: Remove bc dependency
# - 1.2.0: Add option for maximum time
# - 1.1.0: Set default output size to input size, and use 25 fps
# - 1.0.0: Initial release.

set -e

# ==============================================================================
# Checks

for cmd in xrandr ffmpeg; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Error: '$cmd' is not installed."
    exit 1
  fi
done

# ==============================================================================
# fetch the display resolution of $DISPLAY with x11

DISPLAY="${DISPLAY:-:0}"
inputSize=$(xrandr --display "$DISPLAY" 2>/dev/null | tail -n 1 | awk '{print $1}')

if [ -z "$inputSize" ]; then
 echo "Error: Unable to determine input size of display $DISPLAY."
 echo "Make sure you've set the \$DISPLAY environment variable."
 exit 1
fi

# ==============================================================================
# Set default variables

inputFps=25
# calculate aspect ratio by dividing the input size which is a string of the form "WxH" by the width
outHeight=${inputSize#*x}
padding=10
quality=23
preset=faster

fontSize=$((outHeight/20))
# minimum font size is 24
if [ $fontSize -lt 24 ]; then
  fontSize=24
fi

boxHeight=$((fontSize+padding))
boxWidth=$((fontSize*15))

outputDir="$PWD"
output="recording-$(date +%Y%m%d-%H%M%S).mkv"
outputTime=""

# ==============================================================================
# Option parsing

usage() {
  echo "Usage: $0 [options]"
  echo
  echo "Record the display at \$DISPLAY and save to file."
  echo
  echo "Options:"
  echo
  echo "  Input:"
  echo "    -s, --input-size <size>         Input size (default: $inputSize)"
  echo "    -r, --input-fps <fps>           Input fps (default: $inputFps)"
  echo "    --text-padding <padding>        Padding (default: $padding)"
  echo "    --font-size <font size>         Font size (default: $fontSize)"
  echo
  echo "  Output:"
  echo "    -o, --output-file <output>      Output file (default: $output)"
  echo "    -d, --output-dir <outputDir>    Output dir (default: $outputDir)"
  echo "    -t, --output-time <outputTime>  Output time (default: none)"
  echo
  echo "  Encoding:"
  echo "    -q, --quality <quality>         x264 CRF value (default: $quality)"
  echo "    -p, --preset <preset>           x264 preset (default: $preset)"
  echo "    --output-height <height>        Output height (default: $outHeight)"
  echo
  echo "  General:"
  echo "    -h, --help                      Show this help and exit"
}

while [ $# -gt 0 ]; do
  case "$1" in
    -s|--input-size)
      inputSize="$2"
      shift 2
      ;;
    -r|--input-fps)
      inputFps="$2"
      shift 2
      ;;
    --text-padding)
      padding="$2"
      shift 2
      ;;
    --font-size)
      fontSize="$2"
      shift 2
      ;;
    -o|--output-file)
      output="$2"
      shift 2
      ;;
    -d|--output-dir)
      outputDir="$2"
      shift 2
      ;;
    -t|--output-time)
      outputTime="$2"
      shift 2
      ;;
    -q|--quality)
      quality="$2"
      shift 2
      ;;
    -p|--preset)
      preset="$2"
      shift 2
      ;;
    --output-height)
      outHeight="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Error: Unknown option '$1'."
      usage
      exit 1
      ;;
  esac
done

echo "Settings: "
echo
echo "  inputSize:  $inputSize"
echo "  inputFps:   $inputFps"
echo "  outHeight:  $outHeight"
echo "  padding:    $padding"
echo "  fontSize:   $fontSize"
echo "  boxHeight:  $boxHeight"
echo "  boxWidth:   $boxWidth"
echo "  output:     $output"
echo "  outputDir:  $outputDir"
echo "  outputTime: $outputTime"
echo

# ==============================================================================
# Main code

if [ -n "$outputTime" ]; then
  outputTime="-t $outputTime"
fi

outputFile="$outputDir/$output"

exec ffmpeg \
  -f x11grab -framerate "$inputFps" -video_size "$inputSize" -i "$DISPLAY" \
  -filter:v "
    settb=AVTB,
    setpts='trunc(PTS/1K)*1K+st(1,trunc(RTCTIME/1K))-1K*trunc(ld(1)/1K)',
    scale=-2:${outHeight},
    drawbox=x=0:y=ih-h:color=black@0.4:width=min(iw\,${boxWidth}):height=${boxHeight}:t=fill,
    drawtext=text='%{localtime}.%{eif\:1M*t-1K*trunc(t*1K)\:d}':fontcolor=white:fontsize=${fontSize}:x=${padding}:y=h-th-${padding},
    format=yuv420p" \
  -c:v libx264 \
  -crf "$quality" \
  -g 1 \
  -preset "$preset" \
  $outputTime \
  -progress - -nostats \
  "$outputFile"
