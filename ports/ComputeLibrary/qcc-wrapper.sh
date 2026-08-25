#!/bin/bash

for arg in "$@"; do
    if [[ "$arg" == @*.rsp ]]; then
        rsp_file="${arg:1}"

        if [[ -f "$rsp_file" ]]; then
            sed -i -E 's/"([^"]+\.o)"/\1/g' "$rsp_file"
        fi
    fi
done

exec qcc "$@"
