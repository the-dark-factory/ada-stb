#!/usr/bin/env bash
# Compile csrc/stb_impl.c → vendor/stb/libstb.a
#
# STB is header-only C, so we just compile the one .c file that
# triggers all the STB_*_IMPLEMENTATION defines. No CMake, no
# autotools, no submodule build dance.

set -euo pipefail
cd "$(dirname "$0")/.."

VENDOR="vendor/stb"
SRC="csrc/stb_impl.c"
OBJ="csrc/stb_impl.o"
OUT="$VENDOR/libstb.a"

CFLAGS=(
  -O2
  -fPIC
  -I"$VENDOR"
)

UNAME="$(uname -s)"
case "$UNAME" in
  Darwin)
    CC=(xcrun clang)
    SDK_PATH="$(xcrun --show-sdk-path)"
    CFLAGS+=( -isysroot "$SDK_PATH" )
    AR=(ar -rc)
    ;;
  Linux)
    CC=(cc)
    AR=(ar -rc)
    ;;
  *)
    echo "Unsupported OS: $UNAME" >&2
    exit 1
    ;;
esac

echo "  cc   $SRC"
"${CC[@]}" "${CFLAGS[@]}" -c "$SRC" -o "$OBJ"

rm -f "$OUT"
echo "  ar   $OUT"
"${AR[@]}" "$OUT" "$OBJ"

ls -la "$OUT"
echo
echo "Done. Linker:  -L$VENDOR -lstb"
