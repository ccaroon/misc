%define SYSCALL_EXIT 60

; Comments start with a semicolon
BITS 64 ; 64 bit binary
CPU X64 ; Target x86_64 arch


section .text
global _start
_start:
    ; allocate space on stack
    sub rsp, 16

    mov BYTE [rsp], 42

    mov rax, 0
    mov rax, rsp

    mov rax, 0
    mov rax, [rsp]

    ; deallocate space
    add rsp, 16

    ; exit(0) -- syscall(SYS_EXIT, 0)
    mov rax,    SYSCALL_EXIT
    mov rdi,    0
    syscall
