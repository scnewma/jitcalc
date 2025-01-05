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
