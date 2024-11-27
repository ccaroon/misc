; defines
%define SYSCALL_WRITE  1
%define STDOUT 1

; Function to print 'hello'
global print_hello
print_hello:
    ; prologue
    push rbp        ; Save rbp to Stack, restore at end of function
    mov  rbp, rsp   ; Create our frame pointer

    sub rsp, 16 ; Reserve 5 bytes on the Stack

    mov BYTE [rsp + 0], 'h'
    mov BYTE [rsp + 1], 'e'
    mov BYTE [rsp + 2], 'l'
    mov BYTE [rsp + 3], 'l'
    mov BYTE [rsp + 4], 'o'

    ; Make write syscall
    mov     rax,    SYSCALL_WRITE
    mov     rdi,    STDOUT
    lea     rsi,    [rsp]   ; Address on the stack of the string
    mov     rdx,    5       ; Length of string
    syscall

    call print_world

    add rsp, 16  ; Restore stack to orig value // deallocate memory

    ; epilogue
    pop rbp     ; Restore caller frame
    ret

; Function to print ' world'
print_world:
    push rbp
    mov rbp, rsp

    add rsp, 16

    mov BYTE [rsp + 0], ' '
    mov BYTE [rsp + 1], 'w'
    mov BYTE [rsp + 2], 'o'
    mov BYTE [rsp + 3], 'r'
    mov BYTE [rsp + 4], 'l'
    mov BYTE [rsp + 5], 'd'

    ; Make write syscall
    mov     rax,    SYSCALL_WRITE
    mov     rdi,    STDOUT
    lea     rsi,    [rsp]   ; Address on the stack of the string
    mov     rdx,    6       ; Length of string
    syscall

    add rsp, 16  ; Restore stack to orig value // deallocate memory

    ; epilogue
    pop rbp     ; Restore caller frame
    ret
