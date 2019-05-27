%macro print_t 2
    push %1
    push %2
    call printf
    add esp, 8
%endmacro

%macro print_float 0
    fld qword [res]
    sub esp,8
    fstp qword [esp]
    push format_string_2f
    call printf
    add esp,12
    %endmacro


%macro create_random 1
        push dword %1
        call random_number 
        add esp, 4
%endmacro

%macro allocateCo_routine 1
	push STKSZ
	call malloc                     ; Allocate stack size
	add esp, 4
	mov ebx, dword [CORS]
	add ebx, edi
	mov ebx, [ebx]
	;add ebx, dword SPP
	add eax, STKSZ 					; set in eax the address of the end of the stack
	mov esi, dword %1
	mov [ebx], %1
    mov dword [ebx + 4], eax        ; Set  cell in Cors array to point to  alocated stack
%endmacro

%macro callscanf 3
    push dword %1                   ; arg3
    push dword %2                   ; arg2
    push dword %3                   ; arg1
    call sscanf
    add esp, 12
%endmacro

%macro startFunction 0
        push    ebp
        mov     ebp, esp
        sub     esp, 4
        pusha
        mov     ebx, dword[ebp + 8]
%endmacro

%macro endFunction 0
        popa
        mov     esp, ebp
        pop     ebp
        ret
%endmacro
    
%macro endFunctionParameter 0
        mov     eax, dword[ebp-4]
        mov     esp, ebp
        pop     ebp
        ret
%endmacro


section .data
    format_string_s : db "%s",0 
    format_string : db "%d",10,0 
    down :db '',10,0
    format_string_int: db "%d", 10, 0   ; format string int
    format_string_float: db "%f", 10, 0 ; format string float
    format_string_floatl: db "%lf", 10, 0 ; format string float
    format_string_2f: db "%.2f",10,0 ; float 2 numbers after dot
    degree equ 360
    distance equ 100
    maxint: dd 0xffff
    bignum: DD 0
    res : dd 0
	struct_len equ 8
	SPP equ 4 							; offset of pointer to co-routine stack in co-routine struct 



section .bss
    N : resd 1                          ; Number of drones
    T : resd 1                          ; Number of targets to destroy to win the game
    K : resd 1                          ; How many drone steps between game board printings
    beta : rest 1                       ; Angle of drone field-of-view
    d : rest 1                          ; Maximum distance that allows to destroy a target
    seed : resd 1                       ; Seed for initialization of LFSR shift register
    CORS : resd 1                       ; Number of all the co-routines in the program
	schedulerCo : resd 1 				; Pointer to scheduler co-routine
	targetCo : resd 1 					; Pointer to target co-routine
	printerCo : resd 1					; Pointer to printer co-routine

    ;------------Co-routines fields------------;
    CURR: resd 1
    SPT: resd 1 						; temporary stack pointer
    SPMAIN: resd 1						; stack pointer of main
    STKSZ equ 16*1024					; co-routine stack size
    CODEP equ 0 						; offset of pointer to co-routine function in co-routine struct 
    
    




section .text                           ; functions from c libary
  align 16
     global main 
     global random_number
	 extern drone
	 extern target
	 extern scheduler
	 extern printer
     extern printf 
     extern fprintf
     extern sscanf
     extern malloc
     extern free
main:
    mov eax, dword [esp + 8]
    getArgsValues:
        pushad
        callscanf N, format_string_int, dword [eax + 4]     ; Number of drones
        popad

        pushad
        callscanf T, format_string_int,dword [eax + 8]      ; Number of targets to destroy to win the game
        popad

        pushad
        callscanf K, format_string_int, dword [eax + 12]        ; How many drone steps between game board printings
        popad

        pushad
        callscanf beta, format_string_float, dword [eax + 16]  ; Angle of drone field-of-view
        popad

        pushad
        callscanf d, format_string_float, dword [eax + 20]  ; Maximum distance that allows to destroy a target
        popad

        pushad
        callscanf seed, format_string_int, dword [eax + 24] ; Seed for initialization of LFSR shift register
        popad
	call AlcCoRoutins
	;call initCoLoop
	call preInitCoLoop
	call startCo
	jmp endAss3

            
     
    ;set the number of co-routins in CORS to be N+3
    AlcCoRoutins:
        xor ecx, ecx
        xor ebx, ebx
        mov ecx, [N]                    ; Number of co-routins
        add ecx, dword 3                ; Plus the printer and schedual co-routines
        cmp dword [N], 0                ; Check the Co-routine number > 0
        je endAlcCoRou
        pushad

		shl ecx, 2 						; multiply by 4
        push ecx                        ; allocate array of (4*N) bytes
        call malloc
        add esp, 4
        mov dword [CORS], eax           ; eax keeps the address to the alocated memory
        popad                           ; rerieve the state of the registers

        xor edi, edi
        xor ebx, ebx
		mov edi, [CORS]

		allocStructsLoop:
			pushad
			push struct_len 			; malloc with 8 bytes
			call malloc
			add esp, 4 			
			mov [edi + ebx], eax		; in the i'th cell of CORS array put the new allocated address
			popad
			add ebx, dword 4
		loop allocStructsLoop, ecx
		
		saveCoNumbers:
		mov esi, dword [N]
		inc esi
		shl esi, 2
		mov dword [schedulerCo], esi	; save the co-routine number of scheduler
		shr esi, 2
		inc esi
		shl esi, 2
		mov dword [targetCo], esi		; save the co-routine number of target
		shr esi, 2
		inc esi
		shl esi, 2
		mov dword [printerCo], esi		; save the co-routine number of printer

		xor edi, edi
		mov ecx, dword [N]
        allocDroneLoop:
            pushad
            allocateCo_routine dword drone 	; macro to create drone co-routine
            popad
            add edi, dword 4
        loop allocDroneLoop, ecx
		
		xor ebx, ebx
		allocScheduler:
			pushad
			allocateCo_routine dword scheduler 	; macro to create scheduler co-routine
			popad
		add edi, dword 4
		
		allocTarget:
			pushad
			allocateCo_routine dword target 	; macro to create target co-routine
			popad
		add edi, dword 4
		
		allocPrinter:
			pushad
			allocateCo_routine dword printer 	; macro to create printer co-routine
			popad
		
        endAlcCoRou:
		ret

	preInitCoLoop:
	xor ecx, ecx
	xor edi, edi
	mov ecx, dword [N]
	add ecx, dword 3
		
	initCoLoop:
		pushad
		push edi
		call initCo 			; for every co-routine performe a initialization
		add esp, 4
		popad
		inc edi
	loop initCoLoop, ecx
	ret



    create_random distance
    print_float
	create_random degree
    print_float
    jmp endAss3
    
    ;----------initCo Function---------;
    initCo:
        startFunction               ; get co-routine ID number
		mov edx, dword[CORS]
        mov ebx, [4*ebx + edx]      ; get pointer to COi struct
        mov eax, [ebx+CODEP]        ; get initial EIP value – pointer to COi function
        mov [SPT], esp              ; save ESP value
		mov esi, dword [ebx + SPP]
        mov esp, [ebx+SPP]          ; get initial ESP value – pointer to COi stack
        push eax                    ; push initial “return” address
        pushfd                      ; push flags
        pushad                      ; push all other registers
        mov [ebx+SPP], esp          ; save new SPi value (after all the pushes)
        mov esp, [SPT]              ; restore ESP value
        endFunction
    ;----------end initCo Function---------;
    
	;----------initCo Function---------;
    startCo:
		pushad 							; save registers of main ()
		mov [SPMAIN], esp 				; save ESP of main ()
		mov ebx, dword [CORS] 			; gets ID of a scheduler co-routine
		add ebx, dword [schedulerCo] 	; gets a pointer to a scheduler struct
				;sub ebx, dword 4
				mov esi, [ebx]
				mov esi, [esi]
				mov ebx, [ebx]
		jmp do_resume 					; resume a scheduler co-routine

	endCo:
		mov esp, [SPMAIN] 				; restore ESP of main()
		popad							; restore registers of main()
		ret

	resume:  							; save state of current co-routine
		pushfd
		pushad
		mov edx, [CURR]
		mov [edx+SPP], esp 				; save current ESP
    
	do_resume: 							; load ESP for resumed co-routine
		mov esp, [ebx + SPP]
		mov [CURR], ebx
		popad
		popfd
		ret
	
	;----------random_number Function---------;
    random_number:
        startFunction
        mov dword [bignum],ebx

 		LFSR:  
        mov edi,16
        looplfsr:
        cmp edi,0
        je end1
        mov eax, 1
        mov esi, 1
        xor ebx, ebx
        mov ebx, [seed]
        and eax, ebx                ;find the 16 bit
        shr  ebx, 2
        and esi, ebx                ;find the 14 bit
        xor eax, esi                ;xor 16's bit with 14's bit
        shr  ebx, 1
        mov esi, 1
        and esi, ebx                ;find the 13 bit
        xor eax, esi                ;xor previos xor result of bit with 13s bit
        shr  ebx, 2
        mov esi, 1
        and esi, ebx                 ;find the 11 bit
        xor eax, esi                ;xor previos xor result of bit with 11s bit
        shl eax,  15
        shr dword[seed], 1
        xor dword [seed], eax       ;genatate the new seed number
        dec edi
        jmp looplfsr
        end1:
        

		scaling:
			finit
			fild dword [bignum]
			fild dword [maxint]
			fdiv
			fild dword [seed]
			fmul
			fstp qword [res] 
		endFunction
	;----------end random_number Function---------;
    
	freeMemoryBeforeExit:


endAss3: