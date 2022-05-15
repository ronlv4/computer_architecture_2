extern printf
extern c_checkValidity

section .bss
	;op_stack: resd 10
	op_stack_ptr: resd 1
	op_stack_cap: resd 1

section .data
	prompt_msg:    db "calc: ", 0 ; printf format string follow by a newline(10) and a null terminator(0), "\n",'0'
	over_flow_error: db "Error: Operand Stack Overflow", 10, 0;
	arguments_error: db "Error: Insufficient Number of Arguments on Stack", 10, 0;

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

get_input:

prompt:
    push dword [prompt_msg]
    call printf
    add esp, 4
    ret

insert:
    pop eax
    cmp ecx, [op_stack_cap]
    jne exe_insert
    push dword [over_flow_error]
    call printf
    ret
    exe_insert:
	mov [op_stack_ptr], eax
	sub op_stack_ptr, 4
	inc ecx
	ret


addition:
    ; attemp to pop 2 operands from stack and perform addition, then insert
    cmp ecx, 2
    jge exe_addition
    push dword [arguments_error]
    call printf
    add esp, 4
    ret
    exe_addition:
        pop eax
        pop ebx
        add eax, ebx
        push eax
	call insert

pnp:
    ; attemp to pop an operand from the stack, if available then print
    cmp ecx, 1
    jge exe_pnp
    push dword [arguments_error]
    call printf
    add esp, 4
    ret
    exe_pnp:
	mov eax
	push 

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
