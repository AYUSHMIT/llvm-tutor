# LLVM Tutor Demo

This demo compiles small C programs to LLVM bitcode, runs out-of-tree tutorial passes, and generates IR and CFG visualizations.

## Prerequisites

- LLVM/Clang (21 or later recommended; 18+ may work with some passes)
- CMake, Ninja
- Graphviz (`dot`)

## Quickstart (Local)

```bash
cmake -G Ninja -S . -B build -DLT_LLVM_INSTALL_DIR=/usr/lib/llvm-21
cmake --build build
bash demo/run.sh 21
```

Artifacts will be in `demo/out/`:
- `hello.ll`, `loop.ll`: human-readable IR
- `*.dot`, `*.png`: CFG graphs
- `hello_pass.log`: pass output from HelloWorld plugin
- `static_cc_pass.log`: pass output from StaticCallCounter plugin

## Running in GitHub Codespaces

Open the repo in Codespaces and wait for the Dev Container to finish provisioning. It will build automatically. Then run:

```bash
bash demo/run.sh 21
code demo/out
```

## Notes on Pass Names

The exact pass plugin names in `llvm-tutor` are:

- `libHelloWorld.so` with `-passes=hello-world` - Prints function names and argument counts
- `libStaticCallCounter.so` with `-passes="print<static-cc>"` - Counts static function calls
- `libDynamicCallCounter.so` with `-passes=dynamic-cc` - Instruments code to count dynamic calls
- `libInjectFuncCall.so` with `-passes=inject-func-call` - Injects function calls
- `libMBAAdd.so` with `-passes=mba-add` - Mixed Boolean-Arithmetic obfuscation for addition
- `libMBASub.so` with `-passes=mba-sub` - Mixed Boolean-Arithmetic obfuscation for subtraction
- `libRIV.so` with `-passes="print<riv>"` - Reachable Integer Values analysis
- `libDuplicateBB.so` with `-passes=duplicate-bb` - Duplicates basic blocks
- `libMergeBB.so` with `-passes=merge-bb` - Merges basic blocks
- `libOpcodeCounter.so` with `-passes="print<opcode-counter>"` - Counts LLVM IR opcodes
- `libFindFCmpEq.so` with `-passes="print<find-fcmp-eq>"` - Finds floating-point equality comparisons
- `libConvertFCmpEq.so` with `-passes=convert-fcmp-eq` - Converts floating-point equality comparisons

General invocation pattern:

```bash
opt-21 -load-pass-plugin build/lib/lib<PassName>.so -passes=<pass-pipeline> -disable-output demo/out/hello.bc
```

Examples:
```bash
# Run HelloWorld pass
opt-21 -load-pass-plugin build/lib/libHelloWorld.so -passes=hello-world -disable-output demo/out/hello.bc

# Run StaticCallCounter analysis
opt-21 -load-pass-plugin build/lib/libStaticCallCounter.so -passes="print<static-cc>" -disable-output demo/out/hello.bc

# Run DynamicCallCounter transformation
opt-21 -load-pass-plugin build/lib/libDynamicCallCounter.so -passes=dynamic-cc demo/out/hello.bc -o demo/out/hello_dcc.bc
```

## Visualizing CFG

```bash
opt-21 -passes=dot-cfg demo/out/hello.bc -disable-output
dot -Tpng .square.dot -o square.png
dot -Tpng .main.dot -o main.png
```

This produces CFG images for each function in your sample. The pass generates one `.dot` file per function.

## Understanding the Output

### IR Files (`.ll`)
Human-readable LLVM IR showing:
- Function definitions
- Basic blocks
- Instructions (load, store, arithmetic, control flow)
- Type information

### CFG Graphs (`.png`)
Control Flow Graph visualizations showing:
- Basic blocks as nodes
- Control flow edges (branches, jumps)
- Loop structures
- Function call relationships

### Pass Logs
Output from analysis and transformation passes showing:
- Function analysis results
- Statistics (call counts, opcode frequencies)
- Transformation actions performed

## Troubleshooting

- Ensure `LT_LLVM_INSTALL_DIR` or `LLVM_DIR` points to the correct CMake package path.
- Match LLVM versions across `clang`, `opt`, and the LLVM libraries.
- If a pass plugin fails to load, verify the `.so` path and the pass pipeline name.
- On older LLVM versions (< 17), some pass names or flags may differ.

## Examples with Different Passes

### Example 1: MBA Obfuscation
Transform arithmetic operations using Mixed Boolean-Arithmetic:

```bash
# Original addition
clang-21 -O0 -emit-llvm -c demo/samples/loop.c -o demo/out/loop.bc
opt-21 -passes=dot-cfg demo/out/loop.bc -disable-output
dot -Tpng .sum_n.dot -o demo/out/loop_before.png

# Apply MBA obfuscation
opt-21 -load-pass-plugin build/lib/libMBAAdd.so -passes=mba-add demo/out/loop.bc -o demo/out/loop_mba.bc
opt-21 -passes=dot-cfg demo/out/loop_mba.bc -disable-output
dot -Tpng .sum_n.dot -o demo/out/loop_after.png

# Compare the CFGs
```

### Example 2: Static Call Analysis
Analyze function call patterns:

```bash
clang-21 -O0 -emit-llvm -c demo/samples/hello.c -o demo/out/hello.bc
opt-21 -load-pass-plugin build/lib/libStaticCallCounter.so -passes="print<static-cc>" -disable-output demo/out/hello.bc
```

### Example 3: Basic Block Duplication
Duplicate basic blocks for code obfuscation:

```bash
opt-21 -load-pass-plugin build/lib/libDuplicateBB.so -passes=duplicate-bb demo/out/loop.bc -o demo/out/loop_dup.bc
llvm-dis-21 demo/out/loop_dup.bc -o demo/out/loop_dup.ll
diff -u demo/out/loop.ll demo/out/loop_dup.ll
```

## Additional Resources

- [LLVM Pass Writing Tutorial](https://llvm.org/docs/WritingAnLLVMPass.html)
- [LLVM Pass Manager](https://llvm.org/docs/NewPassManager.html)
- [LLVM Testing Infrastructure](https://llvm.org/docs/TestingGuide.html)
- [Original llvm-tutor Repository](https://github.com/banach-space/llvm-tutor)
