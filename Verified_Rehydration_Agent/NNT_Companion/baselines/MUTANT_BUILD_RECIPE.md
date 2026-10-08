# MUTANT_BUILD_RECIPE

> How to rebuild the compiled-paradigm (C/Rust) mutant binaries from the
> shipped sources under `baselines/<lang>/mutants/`. Each mutant `.exe` is
> reproducible from the `.c`/`.rs` beside it with the command below; the
> rebuilt per-PT vector must match the shipped mutation column cell-by-cell.

## C mutants

Toolchain: Clang targeting `x86_64-w64-mingw32` (LLD, UCRT64 sysroot) —
the toolchain that produced the frozen baseline.

```
clang --target=x86_64-w64-mingw32 -fuse-ld=lld --sysroot=<UCRT64_SYSROOT> \
      -o mutant_<ID>.exe baselines/c/mutants/mutant_<ID>.c
```

Sources shipped:
- `baselines/c/mutants/mutant_MS-01_a.c`
- `baselines/c/mutants/mutant_MS-01_b.c`
- `baselines/c/mutants/mutant_MS-02_a.c`
- `baselines/c/mutants/mutant_MS-03_a.c`
- `baselines/c/mutants/mutant_MS-04_a.c`
- `baselines/c/mutants/mutant_MS-05_a.c`
- `baselines/c/mutants/mutant_MS-06_a.c`

## Rust mutants

Toolchain: `rustc` (stable).

```
rustc -O -o mutant_<ID>.exe baselines/rust/mutants/mutant_<ID>.rs
```

Sources shipped:
- `baselines/rust/mutants/mutant_MS-01_a.rs`
- `baselines/rust/mutants/mutant_MS-01_b.rs`
- `baselines/rust/mutants/mutant_MS-02_a.rs`
- `baselines/rust/mutants/mutant_MS-03_a.rs`
- `baselines/rust/mutants/mutant_MS-05_a.rs`

