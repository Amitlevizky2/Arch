section	.rodata			; we define (global) read-only variables in .rodata section
	format_string: db "%s", 10, 0	; format string

section .bss			; we define (global) uninitialized variables in .bss section
	an: resb 12		; enough to store integer in [-2,147,483,648 (-2^31) : 2,147,483,647 (2^31-1)]
	num: resb 4    ; define 4 bytes for number
	count: resb 4

	
section .text
	global convertor
	extern printf
convertor:
	push ebp
	mov ebp, esp	
	pushad			
	mov dword [an] ,0
	mov dword [an+4], 0
	mov dword [an+8], 0
	mov dword [num] ,0
	mov dword [count],0
	xor eax, eax
	xor edx,edx
	xor edi, edi
	mov edi, an
	mov ecx, dword [ebp+8]	; get function argument (pointer to string)

	createNumber:	
		cmp byte [ecx], 0x0A 	; checks if in ecx there is 0
		je checkminus1 	; if 0, jump to pushStack
		shl dword [num], 1 	
		mov eax,ecx
		inc ecx
		add byte [count],1
		cmp byte [eax] ,'1'
		je adder1
		cmp byte [eax], '0'
		je adder0

		checkminus1:
			cmp dword [count],0x20
			je checkminus
			jmp pushStack

	adder1:
		add dword [num], 1
		jmp createNumber
	adder0:
		add dword [num],0
		jmp createNumber

	checkminus:
		cmp [num], dword 0
		jl createMinus
		jmp pushStack
	

	createMinus:
		mov edi, an
		mov [edi], byte '-'
		inc edi
		neg dword [num]
		jmp pushStack

	pushStack:
		mov eax, [num]
		mov ebx, dword 10
		mov cl,0
		cmp eax,0
		je printzero


	pushJump:
		cmp eax, 0
		je prePopStack
		div ebx
		inc cl
		push edx
		xor edx, edx
		jmp pushJump

	prePopStack:
		xor eax, eax
		jmp popStack

	popStack:
		pop eax
		add eax, 48
		mov [edi], eax 
		inc edi
		dec cl
		cmp cl,0
		jnz popStack
		mov [edi+1], byte 0x00
		jmp toEnd	

	printzero:
		mov dword [edi], 0x30
	toEnd:

		


	push an			; call printf with 2 arguments -  
	push format_string			; pointer to str and pointer to format string
	call printf
	add esp, 8		; clean up stack after call

	popad			
	mov esp, ebp	
	pop ebp
	ret