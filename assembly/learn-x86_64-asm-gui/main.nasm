%define AF_UNIX 1
%define SOCK_STREAM 1
%define SIZEOF_SOCKETADDR_UN 2+108

%define SYSCALL_CONNECT 42
%define SYSCALL_EXIT 60
%define SYSCALL_READ 0
%define SYSCALL_SOCKET 41
%define SYSCALL_WRITE 1

; Comments start with a semicolon
BITS 64 ; 64 bit binary
CPU X64 ; Target x86_64 arch

; ReadOnly Data
section .rodata
sun_path: db "/tmp/.X11-unix/X0"
static sun_path:data

; Writable data
section .data
id: dd 0
static id:data

id_base: dd 0
static id_base:data

id_mask: dd 0
static id_mask:data

root_visual_id: dd 0
static root_visual_id:data

; Text/Code
section .text
global _start
_start:
    ; connect to x11 server
    call x11_connect_to_server

    ; The End
    ; exit(0) -- syscall(SYS_EXIT, 0)
    mov rax,    SYSCALL_EXIT
    mov rdi,    0
    syscall

; Create a UNIX domain socket & connect to the X11 server
; @returns The socket file desc
x11_connect_to_server:
static x11_connect_to_server:function
    ; prologue
    push rbp
    mov rbp, rsp

    ; socket(AF_UNIX, SOCK_STREAM, 0) -- syscall(SYSCALL_SOCKET, ...)
    ; open a socket
    mov rax,    SYSCALL_SOCKET
    mov rdi,    AF_UNIX
    mov rsi,    SOCK_STREAM
    mov rdx,    0
    syscall

    ; Check that socket() return value is NOT <= 0
    cmp rax, 0
    jle die

    mov rdi, rax    ; Store socket file desc in `rdi`

    sub rsp, 112    ; Allocate space on stack for sockaddr_un (16-byte aligned)
                    ; rsp points to block of mem for sockadd_un struct

    mov WORD [rsp], AF_UNIX     ; Set sockaddr_un.sun_family to AF_UNIX
                                ; First 2 bytes (word) of allocated mem

    ; Copy `sun_path` into allocated mem for sockaddr_un.sun_path
    ; movsb - copy 1 byte from rsi to rdi
    lea rsi,        sun_path    ; Memory addr to copy FROM
    mov r12,        rdi         ; Save socket file desc from `rdi` into `r12`
                                ; B/c we need to use `rdi` for movsb instruction
    lea rdi,        [rsp + 2]   ; Memory addr to copy TO ... stack space alloc'd
                                ; +2 b/c first 2 bytes are for AF_UNIX value
    cld                         ; Move forward (below `movsb`)...clear dir flag
    mov ecx,        19          ; Length of `sun_path` with null
    rep movsb                   ; Copy 19 bytes

    ; Connect to the server with connect(2)
    mov rax,    SYSCALL_CONNECT
    mov rdi,    r12     ; P1: Move socket file desc back to `rdi`
    lea rsi,    [rsp]   ; P2: Ptr to sockeraddr_un struct on stack alloc'd mem
    mov rdx,    SIZEOF_SOCKETADDR_UN    ; Param3: sizeof(struct)
    syscall

    cmp rax, 0      ; Return value should be 0
    jne die         ; "die" if return value NOT 0

    ; return(socket file desc)
    mov rax, rdi

    ; epilogue
    add rsp, 112 ; deallocate memory on stack
    pop rbp
    ret

x11_send_handshake:
static x11_send_handshake:function
    ; ---
    ; P1 to this function is the socket file desc in `rdi` (like normal)
    ; Below, we see `mov rdi, rdi` <-- just a no-op to "show" that we are
    ; setting P1 of each write or read call properly.
    ; ---

    ; prologue
    push    rbp
    mov     rbp, rsp

    sub rsp, 1<<15  ; Allocate 32k on stack

    ; Populate x11 connect request struct
    mov BYTE [rsp + 0], '1' ; Set order to 'l'
    mov WORD [rsp + 2], 11  ; Set major version to 11

    ; Send the handshake to the server with write(2)
    mov rax,    SYSCALL_WRITE
    mov rdi,    rdi     ; P1: WHAT????
    lea rsi,    [rsp]   ; P2: Struct data from stack
    mov rdx,    12      ; P3: Write length
    syscall

    ; Check return value
    cmp rax,    12  ; should have written 12 bytes
    jnz die         ; jump if not zero

    ; Read the server response with read(2)
    ; Use the stack as the read buffer.
    ; X11 server first replies with 8 bytes. Once those are read, it replies
    ; with a much bigger response.
    mov rax,    SYSCALL_READ
    mov rdi,    rdi
    lea rsi,    [rsp]   ; Use stack as read buffer
    mov rdx,    8       ; Read 8 bytes
    syscall

    ; Check return value
    cmp rax,    8
    jnz die

    ; Check response
    cmp BYTE [rsp], 1   ; First byte should be 1 == 'success'
    jnz die

    mov rax,    SYSCALL_READ
    mov rdi,    rdi
    lea rsi,    [rsp]   ; Use stack as read buffer
    mov rdx,    1<<15   ; Read 32Kb
    syscall

    ; Check response
    cmp rax,    0   ; Check that server replied with something
    jle die

    ; Read parts of response what we care about into "variables"
    ; X11 fields are padded to 4 bytes each
    ; Set id_base globally
    mov edx,                DWORD [rsp + 4]
    mov DWORD [id_base],    edx

    ; Set id_mask globally
    mov edx,               DWORD [rsp + 8]
    mov DWORD [id_mask],   edx

    ; Read the info we need & skip over the rest
    lea rdi,    [rsp]   ; Ptr that we'll use to skip data (below)

    mov     cx, WORD [rsp + 16] ; Vendor length (v).
    movzx   rcx, cx

    mov     al,     BYTE [rsp + 21] ; Number of formats (n).
    movzx   rax,    al
    imul    rax,    8               ; Num Formats (n) * sizeof(format) == n*8

    ; Remember `rdi` points to the 32Kb of the response on the stack
    add rdi,    32  ; Skip 32 bytes -- the connection setup
    add rdi,    rcx ; Skip over the vendor info (v)

    ; Skip padding -- X11 ROUNDUP macro
    add rdi,    3
    and rdi,    -4

    add rdi,    rax     ; Skip over format info (n*8)

    ; Return Value
    mov eax,    DWORD [rdi] ; Store/Return the window root it

    ; Set the root_visual_id globally
    mov edx,                    DWORD [rdi + 32]
    mov DWORD [root_visual_id], edx

    ; Dealloc space
    add rsp, 1<<15

    ; epilogue
    pop rbp
    ret















die:
    ; exit(1)
    mov rax,    SYSCALL_EXIT
    mov rdi,    1
    syscall
