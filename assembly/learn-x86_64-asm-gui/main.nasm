%define SYSCALL_EXIT 60

; Comments start with a semicolon
BITS 64 ; 64 bit binary
CPU X64 ; Target x86_64 arch

section .text
global _start
_start:
    ; xor rax, rax ; Set rax to 0. NoOp. Just filler code for now.

    ; exit(0) -- syscall(SYS_EXIT, 0)
    mov rax,    SYSCALL_EXIT
    mov rdi,    0
    syscall
