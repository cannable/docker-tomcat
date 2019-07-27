#!/bin/sh

./build_standard.sh micro 7.0
./build_standard.sh micro 8.5
./build_standard.sh micro 9.0

./build_standard.sh mega 8.5
./build_standard.sh mega 9.0

./build_log4j2.sh micro 8.5
./build_log4j2.sh micro 9.0
./build_log4j2.sh mega 8.5
./build_log4j2.sh mega 9.0