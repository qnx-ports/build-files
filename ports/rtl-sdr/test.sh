#!/bin/sh

./rtl_fm -f 93.5e6 -M wbfm -s 200000 -r 48000 - | aplay -r 48000 -f S16_LE
./rtl_t
./rtl_sdr /tmp/capture.bin -s 1.8e6 -f 392e6
./rtl_ads./rtl_adsb -V -S
./rtl_power -f 390M:395M:10k -g 20 output.csv
./rtl_eeprom
./rtl_biast -b 1
./rtl_tcp -a 0.0.0.0 -p 1234

