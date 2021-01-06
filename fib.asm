global main
extern strtol
extern malloc
extern printf
extern free

section .data
format db "%d", 0xA
prev1 dd 0
prev2 dd 1
node_sz dd 12
prev_ptr dq 0
head dq 0

section .bss

section .text

main:
	push rbx			; save rbx before start
	push rbp			; Set up stack frame for debugger
	mov  rbp, rsp
	push rdi			; Program must preserve
	push rsi
	push rdx
	push r12
	push r13
	push r14
	push r15
	;;; Everything before this is boilerplate; use it for all ordinary apps!

	xchg rdi, rsi			; rdi == &argv[0]
	add rdi, 8			; rdi == &argv[1]
	mov rdi, [rdi]			; rdi == argv[1]
	xor rsi, rsi
	xor rdx, rdx
	xor rax, rax
	call strtol wrt ..plt		; strtol(argv[1], 0, 0)
	mov rcx, rax			; cntr = argv[1]

	mov r8, prev1
	mov r8d, dword [r8]		; r8 = prev1
	mov r9, prev2
	mov r9d, dword [r9]		; r9 = prev2
	mov r10, prev_ptr		; r10 = prev_ptr
	mov r10, [r10]

.again:
	cmp rcx, 0
	je .break			; if (cntr == 0) break;
	dec rcx				; cntr--;

	push rcx
	push r8
	push r9
	push r10			; cause malloc
	push r11

	mov rdi, node_sz
	mov edi, dword [rdi]
	call malloc wrt ..plt		; rax = malloc(sizeof(node));

	pop r11
	pop r10
	pop r9
	pop r8				; cause malloc
	pop rcx

	mov dword [rax], r8d
	add dword [rax], r9d		; node->num += prev1 + prev2
	mov qword [rax + 4], 0		; node->next = NULL

	cmp r10, 0
	je .ifnull
	mov [r10 + 4], rax		; prev->next = rax
.continue:
	mov r10, rax			; saved rax in prev_ptr

	mov r8d, r9d
	mov r9d, dword [rax]		; updated prev1, prev2
	jmp .again

.ifnull:
	mov r11, head
	mov r11, [r11]
	mov r11, rax			; node is head
	jmp .continue

.break:
	push r11			; push head
	call .free_nodes
	pop r11

	;;; Everything after this is boilerplate; use it for all ordinary apps!
	pop r15
	pop r14
	pop r13
	pop r12
	pop rdx				; Restore saved registers
	pop rsi
	pop rdi
	mov rsp, rbp			; Destroy stack frame before returning
	pop rbp
	pop rbx
	xor rax, rax
	ret				; Return control to Linux

.free_nodes:
	push rbp
	mov rbp, rsp

	mov r12, qword [rbp + 16]	; node
	mov r12, qword [r12 + 4]	; node->next
	cmp r12, 0
	jne .not_last			; if node isn't last
.not_last_ret:

	push qword [rbp + 16]		; push node
	call .last_node
	pop qword [rbp + 16]

	mov rsp, rbp
	pop rbp
	ret

.not_last:
	push r12			; push node->next
	call .free_nodes		; free_nodes(node->next)
	pop r12				; pop node->next

	jmp .not_last_ret

.last_node:
	push rbp
	mov rbp, rsp

	push qword [rbp + 16]		; node

	call .print_node

	pop qword [rbp + 16]

	mov rdi, [rbp + 16]
	call free wrt ..plt

	mov rsp, rbp
	pop rbp
	ret
;
.print_node:
	push rbp
	mov rbp, rsp
	push rdi
	push rsi

	mov rdi, format
	mov rsi, qword [rbp + 16]
	mov esi, dword [rsi]
	xor rax, rax			; cause printf is va_args
	call printf wrt ..plt

	pop rsi
	pop rdi
	mov rsp, rbp
	pop rbp
	ret
