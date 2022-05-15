extern printf
extern c_checkValidity

section .bss
	;op_stack: resd 10
	op_stack_ptr: resd 1
	op_stack_cap: resd 1

section .data
	prompt_msg:    db "calc: ", 0 ; printf format string follow by a newline(10) and a null terminator(0), "\n",'0'

	operations: dd q, addition, pnp, d, bit_and, bit_or, n

section .rodata
    MAX_INPUT: dd 1024


section .text
	global main
	extern fgets

    
main:
	push ebp
	mov ebp, esp
	mov ecx, [ebp+8]
	mov op_stack_ptr, esp
	sub esp, eax

	call prompt
	call get_input




	push dword stdin
	push dword MAX_INPUT
	push op_stack
	call fgets
	add esp, 12







	mov eax, dword [ebp+8]
	mov [result], eax
	push eax
	call c_checkValidity
	add esp, 4

	cmp eax, 0
	je negative
	shl dword [result], 2
	jmp print
negative:
	shl dword [result], 3
print:
	push dword [result]
	push fmt
	mov al, 0
	call printf
	add esp, 8

get_input:

prompt:
    push dword [prompt_msg]
    call printf
    add esp, 4
    ret

insert:
    cmp ecx, [op_stack_cap]
    jne exe_insert
    push

    ; check for number of operands in stack
    ; if greater that capacity throw error
    ; else push into stack

addition:
    ; attemp to pop 2 operands from stack and perform addition, then insert

pnp:
    ; attemp to pop an operand from the stack, if available then print

d:
    ; check if there is an argument to duplicate, if not error, else insert a copy

bit_and:


bit_or:

n:

q:
	mov esp, ebp
	pop ebp
	mov eax, 0
	ret
