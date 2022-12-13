section .text
global foo

; Andrew C Mattson
; CS F301
; 11/15/2022 
; 
; Proof-of-concept code for simple malloc using brk

%define BYTE_NUM  40 ; Number of allocated bytes.

malloc_brk:
	push rdi
	mov   rax, 12 ; 12 is syscall ID for brk
	mov   rdi, 0  ; Asking for current brk location
	syscall
	pop rdi ; Saved number of bytes
	
	mov   QWORD[brk_firstLoc], rax ; Store old breakpoint
	
	; sbrk(old_break + BYTE_NUM)
	lea   rdi, [rax + rdi] ; add rdi bytes to the break point
	mov   rax, 12
	syscall                ; set the new break point
	
	mov rax, [brk_firstLoc] ; return old break point
	ret

section .data
brk_firstLoc:
	dq 0
	
section .text
foo: ; Same exact foo used in mmap malloc (except this one uses malloc_brk)
	mov rdi, BYTE_NUM ; First argument for malloc_mmap (asking for BYTE_NUM bytes)
	call malloc_brk
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

