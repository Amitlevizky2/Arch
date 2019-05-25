%macro startFunction 0
	push 	ebp
	mov 	ebp, esp
	sub 	esp, 4
	pusha
	mov 	eax, dword[ebp + 8]
%endmacro

%macro startFunctionTwoParams 0
	push ebp
	mov ebp, esp
	sub esp, 4
	mov ebx, [ebp + 8]
	mov ecx, [ebp + 12]
%endmacro

%macro endFunction 0
	popa
	mov 	esp, ebp
	pop 	ebp
	ret
%endmacro

%macro endFunctionParameter 0
	;popa
	mov 	eax, dword[ebp-4]
	mov 	esp, ebp
	pop 	ebp
	ret
%endmacro

%macro printError 1
	push format_string
	push %1
	call printf
	add esp, 8
%endmacro

%macro createLinkMacro 0
	
	xor ecx, ecx
	push dword [linkSize]
	call calloc
	add esp, 4
	;mov byte [eax], %1
	cmp byte [isFirstLink], 0 			; create Link with the value in ebx
	jne %%notFirst1

	%%isFirst1:
	xor ecx, ecx 		
	mov [lastLink], eax		
	add [isFirstLink], byte 1
	jmp %%endFirst
	
	%%notFirst1:
	xor ecx, ecx
	
	mov ecx, [lastLink] 					; if the number was not the first, update lastLink
	inc ecx
	mov dword [ecx], eax
	mov [lastLink], eax
	%%endFirst:
%endmacro

%macro freeOperand 1
	xor edx, edx
	xor eax, eax
	mov dword eax, [%1]
	mov dword edx, [eax + 1] 
	cmp edx, 0
	je %%lastLink

	%%checkLast:
	xor ebx, ebx 
	mov edx, [eax + 1]
	cmp dword edx, 0
	je %%lastLink
	mov ebx, eax
	jmp %%notLastLink

	%%lastLink:
	pushad
	push eax
	call free
	add esp, 4
	popad
	jmp %%end

	%%notLastLink:
	mov eax, [ebx + 1]
	pushad
	push ebx
	call free
	add esp, 4
	popad
	jmp %%checkLast
	%%end:	
%endmacro

%macro removeZero 0 
	push eax
	mov edx, 0
	mov esi , 0
	%%zeros:
	cmp byte[buffer+edx],'0'
	jne %%jump_left
	inc edx
	inc esi
	jmp %%zeros

	%%jump_left:
	cmp esi, 80
	je %%fin_app
	mov edi,esi
	sub edi,edx
	mov al ,[buffer+esi]
	mov [buffer+edi],al
	inc esi
	jmp %%jump_left
	%%fin_app:
	xor eax,eax
	mov al ,byte [buffer]
	cmp al , byte 0xA
	jne %%finish1
	mov [buffer],byte '0'
	mov [buffer+1],byte 0xA
	%%finish1:
	pop eax
%endmacro		

%macro backtoString 1
	cmp %1 , 9
	jle %%lowernumbers
	add %1 , 55
	jmp %%finishloop
	%%lowernumbers:
	add %1 ,48
	%%finishloop:
%endmacro	

%macro clearBuff 0
 	xor eax,eax
  	%%loopbuff:
  	cmp eax,80
 	je %%endmacrobuff
 	mov [buffer+eax], byte 0x00
 	inc eax
 	jmp %%loopbuff
 	%%endmacrobuff:
%endmacro

%macro calculateNumberToPower 1					;TO CALCULATE
	xor eax, eax
	mov eax, 2
	xor ebx, ebx
	mov ecx, [%1]
	dec ecx
	%%Yloop:
	add eax, eax
	loop %%Yloop
%endmacro

%macro popTwoOperands 0
	xor esi, esi
	mov esi, [operandStackPointer]
	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	%%firstOperand:
	sub dword esi, 4
	mov ebx, [operandStack + esi]
	%%secondOperand:
	sub dword esi, 4
	mov ecx, [operandStack + esi]
	sub dword [operandStackPointer], 8
%endmacro

%macro checkLegOperandStack 0
	cmp dword [operandStackPointer], 8
	jl %%printInsu
	jmp %%end
	%%printInsu:
	printError errMsgIns
	jmp printCalc
	%%end:
%endmacro

%macro putReturndValueHeadStack 1
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx
	mov ebx, [operandStackPointer]
	mov [operandStack + ebx], %1
	add dword [operandStackPointer], 4
%endmacro

%macro checkYvalue 1
	jne wrongYValue
	%%checkSize:
	xor edx, edx
	xor esi, esi
	mov byte dl, %1
	add edx, 0
	mov dword esi, 0xC8
	cmp dword edx, esi
	jg %%wrongYValue
	jmp %%end
	%%wrongYValue:
	printError errMsgY
	jmp printCalc
	%%end:
%endmacro

section .data
	format_string: db "%s", 0	; format string
	errMsgOver: db 'Error: Operand Stack Overflow', 10,0	;string in case of too many arguments
	errMsgIns: db 'Error: Insufficient Number of Arguments on Stack', 10,0	;string in case of Insufficient number of arguments in Stack
	errMsgY: db 'wrong Y value', 10,0	;string in case of wrong Y value
	lenOver: equ $ - errMsgOver		; length of the message
	lenIns: equ $ - errMsgIns		; length of the message
	calc: db "calc: ", 0
	down: db '',10,0
	linkSize: DD 5

section .bss
	buffer: resb 80					; store my input
	operandStack: resb 20			; store the stack of the operands
	counter: resb 20
	count: resb 4                   ; input length
	operandStackPointer: resd 1		; pointer to the head of the stack
	temp: resd 1
	lastLink: resd 1
	isFirstLink: resb 1
	tempOdd: resb 1
	firstLinkOperation: resd 1
	carry: resb 1
	carry1: resb 1
	isMoreFirst: resb 1
	isMoreSecond: resb 1
	incPointer: resb 1
	firstLastLinkAddress: resd 1
	secondLastLinkAddress: resd 1
	newLinkToPushAddress: resd 1
	firstLastLinkAddressToDelete: resd 1
	secondLastLinkAddressToDelete: resd 1
	isFirstToDup: resb 1
	numofOnes: resd 1
	powerNumber: resd 1
	XnumberPower: resd 1

section .text						; functions from c libary
  align 16
     global main 
     extern printf 
     extern fflush
     extern malloc 
     extern calloc 
     extern free 
     extern gets 
     extern fgets
     extern stdin
     extern stdout

main:
	mov dword [operandStackPointer], 0
	call myCalc						; call to myCalc function

	mov eax, 1
	int 0x80

	myCalc:							; myCalc function
		

		push ebp					; beckup ebp
		mov ebp, esp				; set ebp to Func activation frame
		;sub esp, 4					; allocate space for local variable sum
		pushad

			xor ebx, ebx
			mov dword ebx, operandStack
			mov dword [lastLink], ebx

		printCalc:
			mov byte [isFirstLink], 0
			mov byte [tempOdd], 0
			push dword calc 				; push calc string to the stack
			push format_string
			call printf						; call tofgets printf func to print "calc:"
			add esp, 8
			jmp getInput

		getInput:
			push dword [stdin]			; first parameter
			push dword 80				; second parameter
			push dword buffer			; third parameter
			call fgets					; call fgets, using the three parameters
			add esp, 12					; clear the parameters from the stack
			push buffer
			call cDeleteLine
			add esp, 4
			

		checkInput:
			mov dword[ebp-4], 0
			mov ecx, [buffer]
		
		lable1:
			mov edx,[count]
			cmp byte [buffer], 0x71
			je end
			cmp byte [buffer], '+'
			je jmpAddition
			cmp byte [buffer], 'p'
			je jmpPopAndPrint
			cmp byte [buffer], 'd'
			je jmpDuplicate
			cmp byte [buffer], '^'
			je jmpPower
			cmp byte [buffer], 'v'
			je jmpSqrtPower
			cmp dword [operandStackPointer], 16
			jg Insufficient
			jmp cont

			jmpAddition:
			mov dword [carry], 0
			cmp dword [operandStackPointer], 8
			jl printInsu
			jmp legalAdd
			printInsu:
			printError errMsgIns
			jmp printCalc							; if there are too few argument, print error

			legalAdd:
			xor eax, eax
			xor ebx, ebx
			mov dword eax, [operandStackPointer]
			sub eax, 4
			mov dword ebx, [operandStack + eax] 				; first cell of operand stack
			push ebx
			sub eax, 4
			mov dword ecx, [operandStack + eax]
			push ecx
			mov dword [operandStackPointer], eax
			call Addition
			xor ebx, ebx
			xor ecx, ecx
			xor edx, edx
			mov dword ebx, operandStack
			mov dword edx, [operandStackPointer]
			mov dword ecx, [newLinkToPushAddress]
			mov dword [ebx + edx], ecx
			add dword [operandStackPointer], 4

			pushad
			freeOperand dword firstLastLinkAddressToDelete
			popad

			pushad
			freeOperand dword secondLastLinkAddressToDelete
			popad
			jmp printCalc
		

			jmpPopAndPrint:
			xor ebx,ebx
			xor ecx,ecx
			cmp dword [operandStackPointer], 4
			jl Insufficient
			sub dword [operandStackPointer],4
			call PopAndPrint
			xor edx,edx
			mov edx,[operandStackPointer]
			mov ebx, dword [operandStack+edx]
			add dword [operandStackPointer], 4
			push ebx
			call free
			add esp, 4
			sub dword [operandStackPointer], 4
			jmp printCalc
			

			jmpDuplicate:
			mov byte [isFirstToDup], 0
			cmp dword [operandStackPointer], 16
			jle checkNotEmpty
			push format_string
			push errMsgOver
			call printf
			add esp, 8
			jmp printCalc 
			checkNotEmpty:
			cmp dword [operandStackPointer], 4
			jge legalDup
			push format_string
			push errMsgIns
			call printf
			add esp, 8
			jmp printCalc
			
			legalDup:
			mov eax, [operandStackPointer]
			sub eax, 4 										;get the last operand that was inserted to the operand stack
			mov ebx, [operandStack + eax]
			push ebx
			call Duplicate
			add esp, 4
			mov ecx, [operandStackPointer]
			mov dword [operandStack + ecx], eax
			add dword[operandStackPointer], 4
			jmp printCalc
			

			jmpPower:
			mov dword [powerNumber], 0
			cmp dword [operandStackPointer], 8
			jl printIns
			jmp legalPow
			printIns:
			printError errMsgIns
			
			legalPow:
			mov dword eax, [operandStackPointer]
			sub eax, 4
			mov dword ebx, [operandStack + eax] 				; X
			;push ebx
			sub eax, 4
			mov dword ecx, [operandStack + eax]					; Y
			cmp dword [ecx + 1], 0
			jne wrongYValue
			jmp checkSize
			checkSize:
			xor edx, edx
			xor esi, esi
			mov byte dl, [ecx]
			add edx, 0
			mov dword esi, 0xC8
			cmp dword edx, esi
			jg wrongYValue
			jmp keepPow
			wrongYValue:
			printError errMsgY
			jmp printCalc
			;push ecx

			keepPow:
			xor edx, edx
			mov dword edx, [ecx]
			mov dword [powerNumber], edx
			;pushad
			;calculateNumberToPower powerNumber    				; get the power
			;mov dword [powerNumber], eax
			;popad
			mov dword [operandStackPointer], eax
			push ebx 											; push X
			push ecx											; push Y
			call Power
			jmp printCalc
			

			jmpSqrtPower:
			checkLegOperandStack
			popTwoOperands
			checkYvalue byte [ecx]
			xor esi, esi
			mov esi, [ecx]
			mov [powerNumber], esi
			push ebx 											; push x
			push ecx											; push y
			call SqrtPower
			jmp printCalc
			

			jmpNumberOfOnes:
			call NumberOfOnes
			jmp printCalc


			


			Insufficient:
			push dword errMsgIns
			push format_string
			call printf
			add esp, 8
			jmp printCalc

			cont:
			call cInsertNumberToStack
			jmp printCalc


		 cDeleteLine:
		 	startFunction
		 	mov dword [count],0         ; intiate counter to count length of checkInput   
			mov ecx,80					; buffer size
			mov edx, buffer				; buffer address
			
			deleteLoop:					; serch for new line in the buffer, and delete it
			cmp byte [edx],0xa
			je l1 					; if finds a new line, replace him with 0
			add byte [count],1
			inc edx
			loop deleteLoop
			
			l1:
			mov byte [edx],0 
			inc edx
			endFunctionParameter

		
		cInsertNumberToStack:
			startFunction
			and ecx,0			

			CheckIfOver:
				cmp dword [count], 0
				je numberWasAdded
				call cCreateLink
				sub dword [count], 2
				jmp CheckIfOver

				numberWasAdded:
				add dword [operandStackPointer], 4
				jmp finish

		cCreateLink:					; Creates link
			startFunction
			xor ebx, ebx
			xor ecx, ecx

			cmp dword [count], 1
			je addZero
			jmp getNumber

			addZero:
			mov al, [buffer]
			mov [buffer],byte  '0'
			mov [buffer + 1], al
			add byte [count],1



			getNumber:
				xor edx, edx
				xor ecx, ecx
				add ecx, [count]
				dec ecx
				add edx, [buffer + ecx]		; Extract the first number to be convert
				mov dword [ebp-4], eax
				push edx					
				call makeInt
				add esp, 4
				
				mov byte [buffer+ecx], 0
											; move the the next char at the buffer
				add ebx, eax
				

				dec ecx
				xor edx, edx
				add edx, [buffer + ecx]			;
				push edx
				mov dword [ebp-4], eax
				call makeInt
				add esp, 4
				shl eax, 4
				add ebx, eax
				mov byte [buffer+ecx], 0		; convert the last digit in the buffer to null (0)


			createLink:
				xor edx, edx
				xor ecx, ecx


				pusha
				push dword [linkSize]
				call calloc
				add esp, 4
				;pusha
				mov dword [eax], ebx
				cmp byte [isFirstLink], 0 			; create Link with the value in ebx
				jne notFirst

				isFirst:
				xor ecx, ecx 		
				mov [lastLink], eax		
				mov ecx, [operandStackPointer]			; if first tell the operand where to point
				mov [operandStack + ecx], eax
				add [isFirstLink], byte 1
				jmp endFirst

				notFirst:
				xor ecx, ecx
				xor ebx, ebx
				mov ecx, [lastLink] 					; if the number was not the first, update lastLink
				inc ecx
				mov dword [ecx], eax
				mov [lastLink], eax


				endFirst:
				endFunction


			cmp dword [operandStackPointer], 16
			jg Insufficient
			jmp cont
				

				makeInt:
					startFunction
					makeNum:
						cmp eax, 57
						jg changeUpper
						cmp eax, 48
						jl endInt
						sub eax, 48
						jmp endInt


					changeUpper:
						cmp eax, 65
						jl endInt
						cmp eax, 70
						jg changeLower
						sub eax, 55
						jmp endInt

					changeLower:
						cmp eax, 97
						jl endInt
						cmp eax, 102
						jg endInt
						sub eax, 87

					endInt:

			finish:
				mov dword [temp], eax
				popa
				mov eax, dword [temp]
				mov esp, ebp
				pop ebp 
				ret


		end:
			;popad
			mov esp, ebp
			pop ebp
			ret



Addition:
	startFunctionTwoParams
	mov dword [carry], 0
	mov dword [carry1], 0


	checkFirst:
	xor eax, eax
	xor edx, edx

	mov dword [firstLastLinkAddressToDelete], ebx
	mov dword [secondLastLinkAddressToDelete], ecx
	mov dword [firstLastLinkAddress], ebx
	mov dword [secondLastLinkAddress], ecx
	cmp byte [isFirstLink], 0
	je atLeastTwoFirst
	jmp notFirstLinks1

	atLeastTwoFirst:
	mov byte al, [ebx] 							; put in al the value of the first link
	mov byte dl, [ecx] 							; || second
	add al, [carry]
	setc [carry1]
	add al, dl										; al and ab
	setc [carry]
	cmp byte [isFirstLink], 0
	je putNewLinkToPushAddress
	jmp notPutNewLinkToPushAddress
	
	putNewLinkToPushAddress:					; update the last link pointers
	pushad
	createLinkMacro
	mov dword [newLinkToPushAddress], eax
	popad
	xor edx, edx
	mov dword edx ,[newLinkToPushAddress]
	mov byte [edx], al
		

	jmp notFirstLinks1

	notPutNewLinkToPushAddress:
	pushad
	createLinkMacro
	popad
	xor edx, edx
	mov dword edx ,[lastLink]
	mov byte [edx], al




	notFirstLinks1:
	cmp dword [ebx + 1], 0						; check if there are more links of the first number
	je noMoreFirstLinks
	xor edx, edx
	mov edx, [ebx + 1]
	mov dword [firstLastLinkAddress], edx 
	
	jmp notFirstLinks2

	noMoreFirstLinks:
	mov byte [isMoreFirst], 1 					; mark by 1 if there are no more first
	jmp notFirstLinks2
	
	notFirstLinks2:
	cmp dword [ecx + 1], 0						; checks if there are more links of the second number
	je noMoreSecondLinks
	xor edx, edx
	mov edx, [ecx + 1]
	mov dword [secondLastLinkAddress], edx
	jmp isBothOver

	noMoreSecondLinks:
	mov byte [isMoreSecond], 1 					; mark by 1 if there are no more second
	jmp isBothOver

	isBothOver:
	xor edx, edx
	xor ebx, ebx
	mov bl, [isMoreFirst]
	mov dl, [isMoreSecond]
	
		compare1:
		cmp byte bl, 0
		je checkDl
		jmp compare2
		checkDl:
		cmp byte dl, 0
		je bothHaveCont

		compare2: 
		cmp byte bl, 1
		je checkDl2
		jmp compare3
		checkDl2:
		cmp byte dl, 0
		je onlySecondLeft

		compare3:
		cmp byte bl, 0
		je checkDl3
		jmp checkCarry
		checkDl3:
		cmp byte dl, 1
		je onlyFirstLeft
		jmp checkCarry

	bothHaveCont:
	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx
	mov dword ebx, [firstLastLinkAddress]
	mov dword ecx, [secondLastLinkAddress]
	jmp atLeastTwoFirst

	
	
	
	onlySecondLeft:
	cmp byte [isMoreSecond], 1
	je checkCarry
	xor edx, edx
	xor ebx, ebx
	xor eax, eax
	mov dword ebx, [secondLastLinkAddress]
	mov byte al, [ebx]
	add al, [carry]
	setc [carry]
	pushad
	createLinkMacro
	popad
	xor edx, edx
	mov dword edx ,[lastLink]
	mov byte [edx], al
	cmp dword [ebx + 1], 0 						; NEED TO TAKE CARE TO CARRY CASE
	je checkCarry
	xor edx, edx
	mov edx, [ebx+1]
	mov dword [secondLastLinkAddress], edx
	jmp onlySecondLeft


	onlyFirstLeft:
	cmp byte [isMoreFirst], 1
	je checkCarry
	xor edx, edx
	xor ebx, ebx
	xor eax, eax
	mov dword ebx, [firstLastLinkAddress]
	mov byte al, [ebx]
	add al, [carry]
	setc [carry]
	pushad
	createLinkMacro
	popad
	xor edx, edx
	mov dword edx ,[lastLink]
	mov byte [edx], al
	cmp dword [ebx + 1], 0						; NEED TO TAKE CARE TO CARRY CASE
	je checkCarry
	xor edx, edx
	mov edx, [ebx+1]
	mov dword [firstLastLinkAddress], edx
	JMP onlyFirstLeft

	checkCarry:
	cmp byte [carry], 1
	je createCarryLink
	cmp byte [carry1], 1
	je createCarryLink
	jmp endAddition

	createCarryLink:
	pushad
	createLinkMacro
	popad
	xor edx, edx
	mov dword edx ,[lastLink]
	mov byte [edx], 1
	
	endAddition:
	cmp byte [isFirstLink], 1
	je updateStack
	

	updateStack:
	xor ecx, ecx
	mov ecx, [newLinkToPushAddress]
	mov dword [ebp - 4], ecx
	
	endFunctionParameter

PopAndPrint:
	startFunction
	clearBuff
	p1:
	xor ebx,ebx
	xor ecx,ecx
	xor edx,edx
	mov edx,[operandStackPointer]
	mov dword ebx, [operandStack+edx]
	mov esi,[ebx]
	xor edx,edx
	xor esi,esi
	mov esi, dword [ebx]
	runTotheEnd:
		inc edx
		push ebx
		mov ebx , dword [ebx+1]
		cmp ebx,0
		jnz runTotheEnd
		xor esi,esi
	printTheStack:
		xor edi,edi
		xor eax,eax
		
		xor ebx,ebx
		cmp edx,0
		je endPopAndPrint
		xor ecx,ecx
		pop ecx
		mov al, [ecx]
		mov bl, [ecx]
		shr bl, 4	
		backtoString ebx
		mov [buffer+esi], bl
		xor ebx, ebx
		mov ebx,eax
		shl bl, 4
		shr bl, 4
		backtoString ebx
		inc esi
		mov [buffer+esi], bl
		inc esi
		dec edx
		jmp printTheStack

	endPopAndPrint:
		removeZero
		push dword buffer
		push format_string
		call printf
		add esp, 8
		clearBuff
		push down
		push format_string
		call printf
		add esp ,8
		endFunction

Duplicate:
	startFunction							;first, check if there is any operands, or too much
	
	startDup:
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx
	
	dupLink:
	pushad
	createLinkMacro
	cmp byte [isFirstToDup], 0
	je putNewLinkToPushAddressDup
	jmp notPutNewLinkToPushAddressDup
	putNewLinkToPushAddressDup:
	mov dword [newLinkToPushAddress], eax
	mov byte [isFirstToDup], 1
	notPutNewLinkToPushAddressDup:
	popad
	mov byte cl, [eax]
	mov edx, [lastLink]
	mov byte [edx], cl
	cmp dword [eax + 1], 0
	jne incSourceAddressPointer
	jmp doneDup
	incSourceAddressPointer:
	mov eax, [eax + 1]
	jmp dupLink

	doneDup:
	mov edx, [newLinkToPushAddress]

	endDuplicate:
	mov [ebp - 4], edx
	endFunctionParameter

Power:
	startFunctionTwoParams
	mov byte [isFirstToDup], 0
	xor eax, eax
	xor edx, edx
	mov dword [XnumberPower], ecx
							pushad
							xor edx, edx
							mov byte dl, [ecx]
							popad
	pushad
	push dword [XnumberPower]
	call Duplicate
	add esp, 4
	mov [XnumberPower], eax
	popad
	mov dword [firstLastLinkAddress], 0
	mov [firstLastLinkAddress], ebx
	freeOperand firstLastLinkAddress
	mov dword [firstLastLinkAddress], 0
	mov eax, [operandStackPointer]
	mov [operandStack + eax], ecx
	add dword [operandStackPointer], 4
	mov edx, ecx
	multWithDupAndAdd:
	mov ecx, [powerNumber]
	mov edx, [XnumberPower]
	
	loop1:
	mov byte [isFirstToDup], 0
	mov byte [isFirstLink], 0
	dupPow:
	pushad
	push edx
	call Duplicate
	add esp, 4
	mov ecx, [operandStackPointer]
	mov dword [operandStack + ecx], eax
	add dword[operandStackPointer], 4 			;Duplicate
	popad

	mov byte [isFirstLink], 0
	addPow:
	pushad
	mov dword eax, [operandStackPointer]
	sub eax, 4
	mov dword ebx, [operandStack + eax] 				
	sub eax, 4
	mov dword ecx, [operandStack + eax]
	mov dword [operandStackPointer], eax				
	push ebx
	push ecx
	call Addition
	add esp, 8

	xor ebx, ebx
	xor ecx, ecx
  	xor edx, edx
	mov dword ebx, operandStack
	mov dword edx, [operandStackPointer]
	mov dword ecx, [newLinkToPushAddress]
	mov dword [ebx + edx], ecx
	pushad
	freeOperand dword firstLastLinkAddressToDelete
	popad

	pushad
	freeOperand dword secondLastLinkAddressToDelete
	popad

	popad
	mov eax, [operandStackPointer]
	mov edx ,[operandStack + eax]
	add dword [operandStackPointer], 4
	dec ecx
	jnz loop1
	endPow:
	endFunctionParameter

SqrtPower:
	startFunctionTwoParams
	mov dword [isFirstLink], 0
	mov [firstLastLinkAddress], ebx
	pushad
	freeOperand firstLastLinkAddress
	popad
	mov dword [firstLastLinkAddress], 0 		; free the list that kept the y value
	xor eax, eax
	xor edx, edx
	mov eax, [operandStackPointer]
	mov [operandStack + eax], ecx

	negPowLoop:
	cmp dword [powerNumber], 0
	je endNegPower
	dec dword [powerNumber]
	mov eax, [operandStackPointer]
	mov ecx, [operandStack + eax]

	firstLink:
	xor ebx, ebx
	mov ebx, [ecx]
	mov edx, [ecx]
	shr byte dl, 1
	mov [ecx], edx
	cmp dword [ecx + 1] , 0
	je negPowLoop
	mov ebx, ecx
	mov dword ecx , [ecx + 1]

	subNegPowerLoop:
	xor eax, eax
	mov byte al, [ecx]
	and byte al, 1
	shl byte al, 7
	xor byte [ebx], al
	;shr byte [ecx], 1
	xor eax, eax
	mov byte al, [ecx]
	shr byte al, 1
	mov byte [ecx], al
	cmp dword [ecx + 1] , 0
	je negPowLoop
	mov dword ecx, [ecx + 1]
	mov dword ebx, [ebx + 1]
	jmp subNegPowerLoop

	endNegPower:
	add dword [operandStackPointer], 4
	mov eax, [operandStackPointer]
	endFunctionParameter
NumberOfOnes: