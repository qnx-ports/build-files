#!/usr/bin/env bash
set -e

# Script directory: build-files/ports/openvino
S="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Base directory's openvino folder: 3 levels up from the script
O="$(cd "$S/../../../openvino" && pwd)"

# Patches folder
P="$S/patches"

patches=(
  "mlas.patch|src/plugins/intel_cpu/thirdparty/mlas"
  "onednn.patch|src/plugins/intel_cpu/thirdparty/onednn"
  "onednn_gpu.patch|src/plugins/intel_gpu/thirdparty/onednn_gpu"
  "protobuf.patch|thirdparty/protobuf/protobuf"
)

for p in "${patches[@]}"; do
  patch -p1 -d "$O/${p#*|}" -i "$P/${p%|*}"
done
