#!/bin/bash

set -euo pipefail

PACKAGE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
i="$PACKAGE_DIR"/source/python/c.dpp
o="$PACKAGE_DIR"/source/python/c.d

if [[ $(which clang) ]]; then
    # Using clang as the linker will cause libclang to be linked even if installed somewhere "weird"
    clinker=clang
else
    # echo "clang not installed, attempting to find libclang.so"
    # clinker=cc # just use the default
    # # If clang isn't installed, we still try to find the location of libclang.so
    # libclang=$(find / -name 'libclang.so' 2> /dev/null)
    # if [[ "$?" == 0 && $libclang != "" ]]; then
    #     echo "Found libclang at $libclang"
    #     libclang_dir=$(dirname "$libclang")
    #     LIBRARY_PATH="${LIBRARY_PATH:-''}:$libclang_dir"
    #     LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-''}:$libclang_dir"
    # else
    #     echo 'Could not find clang or libclang, please install them'
    #     exit 1
    # fi
    echo "clang must be installed otherwise d++ can't run"
    exit 1
fi

if [[ ! -f $o || $i -nt $o ]]; then
    PYTHON_INCLUDE_PATH=$(python3 "$PACKAGE_DIR"/include.py)
    echo "Translating Python headers in $PYTHON_INCLUDE_PATH"
    CC="$clinker" dub run dpp@0.5.1 --build=release -- --ignore-cursor=stat64 --ignore-cursor=PyType_HasFeature --ignore-cursor=_Py_IS_TYPE  --ignore-cursor=_PyObject_TypeCheck --function-macros --preprocess-only --include-path "$PYTHON_INCLUDE_PATH" "$i"
fi
