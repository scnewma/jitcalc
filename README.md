# jitcalc

A basic calculator that is JIT-compiled. See https://ochagavia.nl/blog/the-jit-calculator-challenge/.

## Usage

```
# compile
$ gcc -o jitcalc main.c -Wall -Werror

# execute
$ ./jitcalc '+ + - * /'
2
```

Summary of instructions:

- `+` adds 1
- `-` subtracts 1
- `*` multiplies by 2
- `/` divides by 2
