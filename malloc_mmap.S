section .text
global foo

; Andrew C Mattson
; CS F301
; 12/13/2022 
; 
; Proof-of-concept code for simple malloc using mmap

%define BYTE_NUM  40 ; Number of allocated bytes.
%define PAGE_SIZE 4096

; mmap(nullptr, rounded BYTE_NUM, PROT_READ|PROT_WRITE, MAP_PRIVATE)
malloc_mmap:
	;((BYTE_NUM + PAGE_SIZE - 1) / PAGE_SIZE) * PAGE_SIZE
	add rdi, PAGE_SIZE - 1 ; rdi = BYTE_NUM + (PAGE_SIZE - 1)
	shr rdi, 12 ; rdi /= PAGE_SIZE
	mov rsi, rdi
	shl rsi, 12 ; rdi *= PAGE_SIZE
	; rsi now contains the requested number of
	; bytes, rounded to the nearest page.
	
	mov rax, 0x9  ; syscall ID for mmap
	mov rdi, 0x0  ; Give me any address
	;mov rsi, rsi ; (Rounded) User specified byte number.
	mov rdx, 0x2  ; PROT_WRITE (Assumes PROT_READ too)
	mov r10, 0x22 ; MAP_ANONYMOUS|MAP_PRIVATE 
	mov r8,  0x0  ; No file descriptor
	mov r9,  0x0  ; No file offset
	syscall
	
	; Check if allocation worked
	cmp rax, -1 ; mmap returns (void*)-1 if allocation failed
	jne no_ret_0
	mov rax,0 ; malloc returns 0 if allocation failed
	
	no_ret_0:
	; Address for allocated memory in rax
	ret
	
foo:
	mov rdi, BYTE_NUM ; First argument for malloc_mmap (asking for BYTE_NUM bytes)
	call malloc_mmap
	mov rcx, rax ; move given address to rdx
	; At this point, in rax, we have an address with the number
	; of allocated bytes we requested. The rest of the file is
	; proving that the memory actually exists and is read/writable.
	
	; Set all elements of array to (i + 1) * 2
	
	mov r8,0 ; i = 0
	mov r9, BYTE_NUM / 4
	jmp loop_set_start_cmp
	loop_set_start:
		mov rax, r8
		add rax, 1 
		imul rax, 2 ; (i + 1) * 2
		mov DWORD[rcx + r8*4], eax 
		add r8,1 ; ++i
		loop_set_start_cmp:
		cmp r8,r9
		jl loop_set_start ; i < BYTE_NUM / 4
	
	; print all elements in allocated array.
	extern printf
	mov rdi, formatStr
	mov r8,0 ; i = 0
	mov rax, 0 ; No vector registers
	mov r9, BYTE_NUM / 4
	jmp loop_get_start_cmp
	loop_get_start:
		mov esi, r8d               ; Arg 1: index i
		mov edx, DWORD[rcx + r8*4] ; Arg 2: Value at arr[i]
		
		push r9
		push rax
		push r8  
		push rdi
		push rcx
		call printf ; Thanks, printf, for trashing my registers.
		pop rcx
		pop rdi
		pop r8
		pop rax
		pop r9
		
		add r8,1 ; ++i
		loop_get_start_cmp:
		cmp r8,r9
		jl loop_get_start ; i < BYTE_NUM / 4
	
	mov rax, rcx ; return the address to allocated memory
	ret

section .data
formatStr:
	db `Array element %d: %d\n`,0

