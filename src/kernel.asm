bits 32

section .text
global start
extern k_main

start:
    cli

    mov esp, 0x90000

    call k_main

hang:
    hlt
    jmp hang
