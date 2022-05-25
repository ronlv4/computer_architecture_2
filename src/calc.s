section .bss
	input_buffer:       resb 1024
    operations_count:   resd 1
    operands_count:     resd 1
	op_stack_ptr:       resd 1
	op_stack_cap:       resd 1

section .data
    set_cap_msg:        db "setting stack capacity to 0x%X", 10, 0
    debug_msg:          db "got here", 10, 0
	prompt_msg:         db "calc: ", 0;
	over_flow_error:    db "Error: Operand Stack Overflow", 10, 0;
	arguments_error:    db "Error: Insufficient Number of Arguments on Stack", 10, 0;
	arg_count_err_msg:  db "Error: invalid number of arguments", 10, 0;
	invalid_number_msg: db "Error: the number entered is invalid", 10, 0
	num_fmt:            db "%X", 10, 0;
	num_fmt_dec:        db "%d", 10, 0;
	str_fmt:            db "%s", 10, 0;
	chr_fmt:            db "%c", 10, 0;

	operations: db "q", "addition", "pnp", "dup", "bit_and", "bit_or", "n"

section .rodata
    MAX_INPUT: dd 1024


section .text
	global main
	extern fgets
	align 16
	extern printf
	extern fprintf 
	extern fflush
	extern malloc 
	extern calloc 
	extern free 
	extern getchar
	extern fgets 
	extern stdout
	extern stdin
	extern stderr

main:
    push ebp
    mov ebp, esp
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    xor edx, edx
    mov dword [operations_count], 0
    mov eax, 5          ; default stack capacity
    mov ebx, [ebp+8]        ; ebx = argc
    cmp ebx, 2
    jg arg_count_err
    jne default_capacity
    mov edi, [ebp+12]       ; edi = argv (char**)
    add edi, 4              ; edi = argv + 1
    mov edi, [edi]
    call string_to_hexa     ; eax = int value of (argv + 1)
    cmp eax, -1
    je q

default_capacity:
    mov dword [op_stack_cap], eax
    mov ecx, esp
    shl eax, 2
    sub esp, eax
    mov dword [operands_count], 0

iteration:
	call prompt
	call get_input          ; input_buffer filled with user input
	mov ebx, dword[input_buffer]
	cmp bl, "q"
    je q
	inc dword [operations_count]
	cmp bl, "+"
	je addition
	cmp bl, "p"
	je pnp
	cmp bl, "d"
	je dup
	cmp bl, "n"
	je n
	cmp bl, "&"
	je bit_and
	cmp bl, "|"
	je bit_or
	cmp bl, "*"
	je mult
	mov edi, input_buffer
	call string_to_hexa
	cmp eax, -1
	je iteration
	call insert
	jmp iteration

string_to_hexa:
    ; INPUT: edi - char* of the number
    ; OUTPUT: eax - int value of edi string, on error -1
    xor eax, eax
.next_digit:
    movzx ebx, byte[edi]
    inc edi
    cmp bl , '0'
    jb .invalid
    cmp bl, 'F'
    ja .invalid
    cmp bl, '9'
    jbe .valid_dec
    cmp bl, 'A'
    jae .valid_hex
    jmp .invalid
.valid_hex:
    sub bl, 7
.valid_dec:
    sub bl, '0'
    imul eax,16
    add eax,ebx
    cmp byte[edi], 0
    jne .next_digit
    ret
.invalid:
    pushad
    push dword invalid_number_msg
    push str_fmt
    call printf
    add esp, 8
    popad
    mov eax, -1
    ret

get_input:
    pushad
    mov eax, 3
    mov ebx, 0
    mov ecx, input_buffer
    mov edx, MAX_INPUT
    int 0x80
    dec eax
    mov byte[input_buffer + eax], 0
    popad
    ret

prompt:
    pushad
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_msg
    mov edx, 6
    int 0x80
    popad
    ret

insert:
    ; input: eax = number to insert
    mov edx, [op_stack_cap]
    cmp dword [operands_count], edx
    jne .exe_insert
    call print_of_err
    ret
.exe_insert:
    mov [ecx], eax
    sub ecx, 4
    inc dword [operands_count]
    ret

addition:
    cmp dword [operands_count], 2
    jge .exe_addition
    call print_arg_err
    jmp iteration
.exe_addition:
	mov eax, [ecx+4]
	mov ebx, [ecx+8]
	add ecx, 8
	sub dword [operands_count], 2
    add eax, ebx
	call insert
	jmp iteration

pnp:
    cmp dword [operands_count], 1
    jge .exe_pnp
    call print_arg_err
    jmp iteration
.exe_pnp:
    call remove_last_operand
    pushad
    push eax
    push num_fmt
    call printf
    add esp, 8
    popad
    jmp iteration

dup:
    ; check if there is an argument to duplicate, if not error, else insert a copy
    cmp dword [operands_count], 1
    jge .exe_dup
    call print_arg_err
    jmp iteration

.exe_dup:
	mov eax, [ecx+4]
	call insert
    jmp iteration

bit_and:
    cmp dword [operands_count], 2
    jge .exe_and
    call print_arg_err
    jmp iteration
.exe_and:
    call remove_last_two
    and eax, ebx
    call insert
    jmp iteration

bit_or:
    cmp dword [operands_count], 2
    jge .exe_or
    call print_arg_err
    jmp iteration
.exe_or:
    call remove_last_two
    or eax, ebx
    call insert
    jmp iteration

n:
    cmp dword [operands_count], 1
    jge .exe_n
    call print_arg_err
    ret
.exe_n:
    call remove_last_operand
    mov edx, eax
    xor eax, eax
.digit:
    inc eax
    shr edx, 4
    jnz .digit
    call insert
    jmp iteration

mult:
    cmp dword [operands_count], 2
    jge .exe_mult
    call print_arg_err
    jmp iteration
.exe_mult:
    call remove_last_two
    mul ebx
    call insert
    jmp iteration


arg_count_err:
    push arg_count_err_msg
    call printf
    add esp, 4
    jmp q

print_arg_err:
    pushad
    push arguments_error
    call printf
    add esp, 4
    popad
    ret

print_of_err:
    pushad
    push over_flow_error
    call printf
    add esp, 4
    popad
    ret

print_debug_msg:
    pushad
    push debug_msg
    call printf
    add esp, 4
    popad
    ret

remove_last_two:
    mov eax, [ecx+4]
    mov ebx, [ecx+8]
    add ecx, 8
    sub dword [operands_count], 2
    ret

remove_last_operand:
    mov eax, [ecx+4]
    add ecx, 4
    dec dword [operands_count]
    ret

print_operations_count:
    pushad
    push dword [operations_count]
    push num_fmt
    call printf
    add esp, 8
    popad
    ret

q:
    call print_operations_count
	mov esp, ebp
	pop ebp
	mov eax, 1
	mov ebx, 0
	int 0x80
