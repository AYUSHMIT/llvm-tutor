#!/usr/bin/env bash
set -euo pipefail

LLVM_VERSION="${1:-17}"
OUT_DIR="demo/out"
SAMPLES_DIR="demo/samples"

# Tools with version suffix for consistency on CI
CLANG="clang-${LLVM_VERSION}"
OPT="opt-${LLVM_VERSION}"
LLVMDIS="llvm-dis-${LLVM_VERSION}"

mkdir -p "${OUT_DIR}"

echo "[*] Building samples to bitcode..."
${CLANG} -O0 -emit-llvm -c "${SAMPLES_DIR}/hello.c" -o "${OUT_DIR}/hello.bc"
${CLANG} -O0 -emit-llvm -c "${SAMPLES_DIR}/loop.c" -o "${OUT_DIR}/loop.bc"

echo "[*] Disassembling to human-readable IR..."
${LLVMDIS} "${OUT_DIR}/hello.bc" -o "${OUT_DIR}/hello.ll"
${LLVMDIS} "${OUT_DIR}/loop.bc" -o "${OUT_DIR}/loop.ll"

# Example pass usage: adjust names to match passes provided by llvm-tutor
# Common tutorial pass pattern:
#   ${OPT} -load-pass-plugin build/lib/libHelloWorld.so -passes=hello-world -disable-output ${OUT_DIR}/hello.bc
echo "[*] Running tutorial passes (adjust plugin and pass names as needed)..."
if [ -f "build/lib/libHelloWorld.so" ]; then
  echo "[*] Running HelloWorld pass..."
  ${OPT} -load-pass-plugin build/lib/libHelloWorld.so -passes=hello-world -disable-output "${OUT_DIR}/hello.bc" 2>&1 | tee "${OUT_DIR}/hello_pass.log"
fi

if [ -f "build/lib/libStaticCallCounter.so" ]; then
  echo "[*] Running StaticCallCounter pass..."
  ${OPT} -load-pass-plugin build/lib/libStaticCallCounter.so -passes="print<static-cc>" -disable-output "${OUT_DIR}/hello.bc" 2>&1 | tee "${OUT_DIR}/static_cc_pass.log"
fi

# Generate CFG graphs (DOT -> PNG)
echo "[*] Generating CFG graphs..."
pushd "${OUT_DIR}" >/dev/null
${OPT} -passes=dot-cfg hello.bc -disable-output 2>/dev/null || true
${OPT} -passes=dot-cfg loop.bc -disable-output 2>/dev/null || true
# Convert all .dot to .png
for f in *.dot; do
  if [ -f "$f" ]; then
    echo "  Converting $f to PNG..."
    dot -Tpng "$f" -o "${f%.dot}.png"
  fi
done
popd >/dev/null

echo "[*] Done. See ${OUT_DIR} for IR, logs, and graphs."
