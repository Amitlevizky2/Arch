
%macro print_t 1
	push %1
	push format_string
	call printf
	add esp, 8
%endmacro

%macro callscanf 3
	push dword %1 					; arg3
	push dword %2					; arg2
	push dword %3					; arg1
	call sscanf
	add esp, 12
%endmacro

section .data
	format_string_s : db "%s",0 
	format_string : db "%d",10,0 
	down :db '',10,0
	format_string_int: db "%d", 0	; format string int
	format_string_float: db "%f", 0	; format string float



section .bss
N : resd 1							; Number of drones
T : resd 1							; Number of targets to destroy to win the game
K : resd 1 							; How many drone steps between game board printings
beta : rest 1 						; Angle of drone field-of-view
d : rest 1 							; Maximum distance that allows to destroy a target
seed : resd 1 						; Seed for initialization of LFSR shift register


section .text						; functions from c libary
  align 16
     global main 
     extern printf 
     extern fprintf
	 extern sscanf
	 extern malloc
	 extern free
	 extern mayDestroy

main:
	mov eax, dword [esp + 8]

	getArgsValues:
		pushad
		callscanf N, format_string_int, dword [eax + 4]		; Number of drones
		popad

		pushad
		callscanf T, format_string_int,dword [eax + 8] 		; Number of targets to destroy to win the game
		popad

		pushad
		callscanf K, format_string_int, dword [eax + 12]		; How many drone steps between game board printings
		popad

		pushad
		callscanf beta, format_string_float, dword [eax + 16]  ; Angle of drone field-of-view
		popad

		pushad
		callscanf d, format_string_float, dword [eax + 20] 	; Maximum distance that allows to destroy a target
		popad

		pushad
		callscanf seed, format_string_int, dword [eax + 24]	; Seed for initialization of LFSR shift register
		popad
	 
	
	
	
	
	;print_t dword [N]
	;print_t dword [T]
	;print_t dword [K]
	 
	