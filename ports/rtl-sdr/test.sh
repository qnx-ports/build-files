#!/bin/sh

./rtl_fm -f 93.5e6 -M wbfm -s 200000 -r 48000 - | aplay -r 48000 -f S16_LE

