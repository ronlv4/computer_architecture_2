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
	num_fmt: db "%d", 10, 0;

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
	sub op_stack_ptr, 4
	mov [op_stack_ptr], eax
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
	mov eax, [op_stack_ptr]
	mov ebx, [op_stack_ptr+4]
	add op_stack_ptr, 8
	sub ecx, 2
        add eax, ebx
        push eax
	call insert
	add esp, 4
	ret

pnp:
    ; attemp to pop an operand from the stack, if available then print
    cmp ecx, 1
    jge exe_pnp
    push dword [arguments_error]
    call printf
    add esp, 4
    ret
    exe_pnp:
	mov eax, [op_stack_ptr]
	add op_stack_ptr, 4
	dec ecx
	push eax
	push dword [num_fmt]
	call printf
	add esp, 8
	ret
d:
    ; check if there is an argument to duplicate, if not error, else insert a copy
    cmp ecx, 1
    jge exe_dup
    push dword [arguments_error]
    call printf
    add esp, 4
    ret
    exe_dup:
	mov eax, [op_stack_ptr]
	push eax
	call insert
	add esp, 4
	ret

bit_and:
	


bit_or:

n:

q:
	mov esp, ebp
	pop ebp
	mov eax, 0
	ret
