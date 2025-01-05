# jitcalc

A basic calculator that is JIT-compiled. See https://ochagavia.nl/blog/the-jit-calculator-challenge/.

## Usage

First compile either the C or the Zig version:

```
# compile (C)
$ gcc -o jitcalc main.c -Wall -Werror

# compile (Zig)
$ zig build-exe --name jitcalc main.zig
```

Then execute the program:

```
$ ./jitcalc '+ + - * /'
2
```

Summary of instructions:

- `+` adds 1
- `-` subtracts 1
- `*` multiplies by 2
- `/` divides by 2

## Benchmarking vs interpreted

In `interpreted.zig` there is a basic, non-JIT implementation. The benchmark
runs the program 10 million times. The basic JIT implementation is an order of magnitude faster.

```
$ hyperfine -w 10 "./jitcalc '+ + - * /'" "./interpreted '+ + - * /'"
Benchmark 1: ./jitcalc '+ + - * /'
  Time (mean ± σ):      34.2 ms ±   0.4 ms    [User: 32.6 ms, System: 0.7 ms]
  Range (min … max):    33.3 ms …  35.1 ms    73 runs

Benchmark 2: ./interpreted '+ + - * /'
  Time (mean ± σ):     333.9 ms ±   4.9 ms    [User: 331.1 ms, System: 1.4 ms]
  Range (min … max):   330.1 ms … 343.6 ms    10 runs

Summary
  ./jitcalc '+ + - * /' ran
    9.77 ± 0.19 times faster than ./interpreted '+ + - * /'
```
