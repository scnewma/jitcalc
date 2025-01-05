#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>

#define SIZE 8192

#define EMIT(instr) \
    if (bytecode_idx + sizeof(instr) > SIZE) {\
        printf("ERR: program too large for allocated memory"); \
        exit(1); \
    }\
    memcpy(bytecode + bytecode_idx, instr, sizeof(instr)); \
    bytecode_idx += sizeof(instr);

void* alloc_executable_mem(size_t size) {
    void* ptr = mmap(0, size,
                     PROT_READ | PROT_WRITE | PROT_EXEC,
                     MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    if (ptr == (void*)-1) {
        perror("mmap");
        return NULL;
    }
    return ptr;
}

typedef long (*JitFunc)(long);

int main(int argc, char *argv[]) {
    if (argc != 2) {
        printf("Usage: jitcalc \"PROGRAM\"\n");
        return 1;
    }

    char *prg = argv[1];

    // NOTE: I don't bother reallocating this if the program is huge... so the
    // program will crash if that happens.
    void* bytecode = alloc_executable_mem(SIZE);

    unsigned char setup_rax[] = {
        0x48, 0x89, 0xf8,                   // mov %rdi, %rax
    };

    unsigned char ret[] = { 0xc3 };         // ret

    unsigned char add1[] = {
        0x48, 0x83, 0xc0, 0x01,             // add %rax, $1
    };

    unsigned char sub1[] = {
        0x48, 0xff, 0xc8,                   // sub %rax, $1
    };

    unsigned char mul2[] = {
        0x48, 0x01, 0xc0,                   // add %rax, %rax
    };

    unsigned char div2[] = {
        0x48, 0xd1, 0xf8,                   // sar rax, $1
    };

    size_t bytecode_idx = 0;

    EMIT(setup_rax);
    for (int i = 0; i < strlen(prg); i++) {
        if (prg[i] == ' ') {
            continue;
        }

        switch (prg[i]) {
            case '+':
                EMIT(add1);
                break;
            case '-':
                EMIT(sub1);
                break;
            case '*':
                EMIT(mul2);
                break;
            case '/':
                EMIT(div2);
                break;
        }
    }
    EMIT(ret);

    JitFunc f = bytecode;
    printf("%ld\n", f(1));
}
